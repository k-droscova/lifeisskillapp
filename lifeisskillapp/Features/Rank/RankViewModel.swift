//
//  RankViewModel.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 03.08.2024.
//

import Foundation
import Combine

protocol RankViewModeling: BaseClass, ObservableObject {
    associatedtype categorySelectorVM: CategorySelectorViewModeling
    associatedtype settingBarVM: SettingsBarViewModeling
    
    var csViewModel: categorySelectorVM { get }
    var settingsViewModel: settingBarVM { get }
    
    // Loading state
    var isLoading: Bool { get }
    
    // User information
    var username: String { get }
    
    // Rankings
    var categoryRankings: [Ranking] { get } // The full list of rankings
    
    // Separated rankings
    var topRankings: [Ranking] { get }     // The top 20 rankings
    var middleRankings: [Ranking]? { get } // The middle rankings (5 above user, 5 below user)
    var bottomRankings: [Ranking] { get }  // The bottom 10 rankings
    
    // Separation Mode State
    var isListComplete: Bool { get set }       // Whether the list is currently in separated mode
    var isSeparationModeEnabled: Bool { get } // Whether separation mode is enabled (rankings > 50)
    
    // User index and total rankings
    var userRank: Int? { get }             // Rank of the logged in user in the rankings
    var totalRankings: Int { get }          // Total number of rankings
    
    // Actions
    func onAppear()
}

final class RankViewModel<csVM: CategorySelectorViewModeling, settingBarVM: SettingsBarViewModeling>: BaseClass, ObservableObject, RankViewModeling {
    typealias Dependencies = HasLoggerServicing & HasUserCategoryManager & HasUserRankManager & HasGameDataManager & HasUserManager & HasLocationManager & HasUserManager & HasNetworkMonitor
    
    // MARK: - Private Properties
    
    private weak var delegate: RankFlowDelegate?
    private let logger: LoggerServicing
    private var gameDataManager: GameDataManaging
    private let userCategoryManager: any UserCategoryManaging
    private let userRankManager: any UserRankManaging
    private let userManager: UserManaging
    private var selectedCategory: UserCategory? {
        getSelectedCategory()
    }
    private var cancellables = Set<AnyCancellable>()
    private var userId: String { (userManager.loggedInUser?.userId).emptyIfNil }
    
    // MARK: - Public Properties
    
    var csViewModel: csVM
    var settingsViewModel: settingBarVM
    @Published private(set) var isLoading: Bool = false
    @Published var username: String = ""
    @Published private(set) var categoryRankings: [Ranking] = [] // Full list of rankings for the selected category
    @Published private(set) var topRankings: [Ranking] = []      // Top 20 rankings
    @Published private(set) var middleRankings: [Ranking]? = nil // Middle rankings
    @Published private(set) var bottomRankings: [Ranking] = []   // Bottom 10 rankings
    
    @Published var isListComplete: Bool = false     // Whether the list is currently separated
    @Published private(set) var isSeparationModeEnabled: Bool = false // Whether the list can be separated (rankings > 50)
    
    @Published private(set) var userRank: Int? = nil            // Index of the user in the rankings
    @Published private(set) var totalRankings: Int = 0           // Total number of rankings
    
    
    // MARK: - Initialization
    
    init(
        dependencies: Dependencies,
        categorySelectorVM: csVM,
        delegate: RankFlowDelegate?,
        settingsDelegate: SettingsBarFlowDelegate?
    ) {
        self.logger = dependencies.logger
        self.userCategoryManager = dependencies.userCategoryManager
        self.userRankManager = dependencies.userRankManager
        self.gameDataManager = dependencies.gameDataManager
        self.userManager = dependencies.userManager
        self.delegate = delegate
        self.csViewModel = categorySelectorVM
        self.settingsViewModel = settingBarVM.init(
            dependencies: dependencies,
            delegate: settingsDelegate
        )
        
        super.init()
        self.setupBindings()
    }
    
    // MARK: - Deinitialization
    
    deinit {
        cancellables.forEach { $0.cancel() }
    }
    
    // MARK: - Public Interface
    
    func onAppear() {
        Task { @MainActor [weak self] in
            self?.isLoading = true
            self?.username = (self?.userManager.loggedInUser?.nick).emptyIfNil
            await self?.fetchData()
            self?.isLoading = false
        }
    }
    
    // MARK: - Private Helpers
    
    private func setupBindings() {
        userCategoryManager.selectedCategoryPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] category in
                Task { [weak self] in
                    await self?.getSelectedCategoryRanking()
                }
            }
            .store(in: &cancellables)
    }
    
    @MainActor
    private func fetchData() async {
        await gameDataManager.loadData(for: .ranks)
        await getSelectedCategoryRanking()
    }
    
    private func getAllUserRankData() -> [UserRank] {
        userRankManager.getAll()
    }
    
    private func getSelectedCategory() -> UserCategory? {
        userCategoryManager.selectedCategory
    }
    
    @MainActor
    private func getSelectedCategoryRanking() async {
        let data = userRankManager.getAll()
        guard data.isNotEmpty else {
            logger.log(message: "No user rank data available")
            delegate?.onNoDataAvailable()
            return
        }
        
        guard let selectedCategory = selectedCategory else {
            logger.log(message: "No selected category found")
            delegate?.selectCategoryPrompt()
            return
        }
        
        if let userRank = userRankManager.getById(id: selectedCategory.id) {
            let rankings = userRank.listUserRank.map { Ranking(from: $0) }
            categoryRankings = rankings
            divideRankingsIntoSections(rankings)
        } else {
            logger.log(message: "No ranking data found for the selected category")
            categoryRankings = []
            delegate?.onNoDataAvailable()
        }
    }
    
    @MainActor
    private func divideRankingsIntoSections(_ rankings: [Ranking]) {
        // Find the user's rank index
        guard let userInd = rankings.firstIndex(where: { $0.id == userId }) else {
            userRank = nil
            return
        }
        userRank = rankings[userInd].rank
        // Enable separation mode only if there are more than 50 rankings
        totalRankings = rankings.count
        isSeparationModeEnabled = totalRankings > RankConstants.minForSeparation
        
        guard isSeparationModeEnabled else {
            topRankings = []
            middleRankings = nil
            bottomRankings = []
            isListComplete = false
            return
        }
        topRankings = Array(rankings.prefix(RankConstants.topSection)) // Top 20
        bottomRankings = Array(rankings.suffix(RankConstants.bottomSection)) // Bottom 10
        
        // If the user is in the top 20 or bottom 10, then middle section is nil
        guard userInd >= RankConstants.topSection && userInd < rankings.count - RankConstants.bottomSection else {
            middleRankings = nil
            return
        }
        // Calculate the middle section (5 above and 5 below the user)
        let lowerBound = max(RankConstants.topSection, userInd - RankConstants.aboveUser)
        let upperBound = min(rankings.count - (RankConstants.aboveUser + 1 + RankConstants.belowUser), userInd + RankConstants.belowUser)
        middleRankings = Array(rankings[lowerBound...upperBound])
    }
}
