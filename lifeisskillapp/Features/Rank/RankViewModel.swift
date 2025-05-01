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
    var categoryRankings: [Ranking] { get }
    var topRankings: [Ranking] { get }
    var middleRankings: [Ranking]? { get }
    var bottomRankings: [Ranking] { get }
    
    // Separation Mode State
    var isListComplete: Bool { get set }
    var isSeparationModeEnabled: Bool { get }
    
    // User index and total rankings
    var userRank: Int? { get }
    var totalRankings: Int { get }
    
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
    @Published private(set) var categoryRankings: [Ranking] = []
    @Published private(set) var topRankings: [Ranking] = []
    @Published private(set) var middleRankings: [Ranking]? = nil
    @Published private(set) var bottomRankings: [Ranking] = []
    @Published var isListComplete: Bool = false
    @Published private(set) var isSeparationModeEnabled: Bool = false
    @Published private(set) var userRank: Int? = nil
    @Published private(set) var totalRankings: Int = 0
    
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
        if self.selectedCategory == nil {
            await userCategoryManager.loadFromRepository()
        }
        await gameDataManager.loadData(for: .ranks)
        await userRankManager.loadFromRepository()
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
        
        // Case 1: User is in the top 20 -> No middle section
        if userInd < RankConstants.topSection {
            topRankings = Array(rankings.prefix(RankConstants.topSection))
            middleRankings = nil
            bottomRankings = Array(rankings.suffix(RankConstants.bottomSection))
            return
        }
        // Case 2: User is near the top (21-25), merge with top section
        if userInd < RankConstants.topSection + (RankConstants.aboveUser + RankConstants.belowUser + 1) {
            let extendedTopSection = userInd + RankConstants.belowUser
            topRankings = Array(rankings.prefix(extendedTopSection))
            middleRankings = nil
            bottomRankings = Array(rankings.suffix(RankConstants.bottomSection))
            return
        }
        
        // Case 3: User is in the bottom 10 -> No middle section
        if userInd >= totalRankings - RankConstants.bottomSection {
            topRankings = Array(rankings.prefix(RankConstants.topSection))
            middleRankings = nil
            bottomRankings = Array(rankings.suffix(RankConstants.bottomSection))
            return
        }
        
        // Case 4: User is near the bottom (within the range of belowUser + aboveUser + 1 from the bottomSection)
        if userInd >= totalRankings - RankConstants.bottomSection - (RankConstants.aboveUser + RankConstants.belowUser + 1) {
            topRankings = Array(rankings.prefix(RankConstants.topSection))
            middleRankings = nil

            // Start the bottom section from the user and include the `belowUser` users after them
            let extendedBottomStartIndex = userInd - RankConstants.aboveUser
            bottomRankings = Array(rankings[extendedBottomStartIndex..<totalRankings])
            return
        }
        
        // Case 5: User is in the middle section (normal case)
        let lowerBound = max(RankConstants.topSection, userInd - RankConstants.aboveUser)
        let upperBound = min(totalRankings - (RankConstants.belowUser + RankConstants.bottomSection + 1), userInd + RankConstants.belowUser)
        topRankings = Array(rankings.prefix(RankConstants.topSection))
        middleRankings = Array(rankings[lowerBound...upperBound])
        bottomRankings = Array(rankings.suffix(RankConstants.bottomSection))
        
        /*
        topRankings = Array(rankings.prefix(RankConstants.topSection)) // Top 20
        bottomRankings = Array(rankings.suffix(RankConstants.bottomSection)) // Bottom 10
        
        // If the user is in the top or bottom, then middle section is nil
        guard userInd >= RankConstants.topSection && userInd < rankings.count - RankConstants.bottomSection else {
            middleRankings = nil
            return
        }
        // Calculate the middle section
        let lowerBound = max(RankConstants.topSection, userInd - RankConstants.aboveUser)
        let upperBound = min(rankings.count - (RankConstants.aboveUser + 1 + RankConstants.belowUser), userInd + RankConstants.belowUser)
        middleRankings = Array(rankings[lowerBound...upperBound])
         */
    }
}
