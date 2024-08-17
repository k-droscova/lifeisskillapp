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
    var categoryRankings: [Ranking] { get }
    var isLoading: Bool { get }
    var username: String { get }
    var csViewModel: categorySelectorVM { get }
    var settingsViewModel: settingBarVM { get }
    func onAppear()
}

final class RankViewModel<csVM: CategorySelectorViewModeling, settingBarVM: SettingsBarViewModeling>: BaseClass, ObservableObject, RankViewModeling {
    typealias Dependencies = HasLoggerServicing & HasUserCategoryManager & HasUserRankManager & HasGameDataManager & HasUserLoginManager & HasLocationManager & HasUserDefaultsStorage & HasUserManager & HasNetworkMonitor
    
    // MARK: - Private Properties
    
    private weak var delegate: RankFlowDelegate?
    private let logger: LoggerServicing
    private var gameDataManager: GameDataManaging
    private let userCategoryManager: any UserCategoryManaging
    private let userRankManager: any UserRankManaging
    private let userDataManager: any UserLoginDataManaging
    private var selectedCategory: UserCategory? {
        getSelectedCategory()
    }
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Public Properties
    
    @Published private(set) var categoryRankings: [Ranking] = []
    @Published private(set) var isLoading: Bool = false
    @Published var username: String = ""
    var csViewModel: csVM
    var settingsViewModel: settingBarVM
    
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
        self.userDataManager = dependencies.userLoginManager
        gameDataManager.delegate = delegate
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
        logger.log(message: "RankViewModel deinitialized and cancellables invalidated")
    }
    
    // MARK: - Public Interface
    
    func onAppear() {
        Task { @MainActor [weak self] in
            self?.isLoading = true
            self?.username = self?.userDataManager.userName ?? ""
            await self?.fetchData()
            self?.isLoading = false
        }
    }
    
    // MARK: - Private Helpers
    
    private func setupBindings() {
        print("BINDINGS: Setting up bindings in RankViewModel")
        userCategoryManager.selectedCategoryPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] category in
                print("BINDINGS: Received new category in RankViewModel: \(String(describing: category?.id))")
                Task { [weak self] in
                    await self?.getSelectedCategoryRanking()
                }
            }
            .store(in: &cancellables)
    }
    
    @MainActor
    private func fetchData() async {
        do {
            try await userCategoryManager.fetch()
            await gameDataManager.fetchNewDataIfNeccessary(endpoint: .rank)
            await getSelectedCategoryRanking()
        } catch {
            delegate?.onError(error)
        }
    }
    
    private func getAllUserRankData() -> [UserRank] {
        userRankManager.getAll()
    }
    
    private func getSelectedCategory() -> UserCategory? {
        userCategoryManager.selectedCategory
    }
    
    @MainActor
    private func getSelectedCategoryRanking() async {
        guard let data = userRankManager.data?.data, data.isNotEmpty else {
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
            self.categoryRankings = rankings
        } else {
            logger.log(message: "No ranking data found for the selected category")
            self.categoryRankings = []
            delegate?.onNoDataAvailable()
        }
    }
}