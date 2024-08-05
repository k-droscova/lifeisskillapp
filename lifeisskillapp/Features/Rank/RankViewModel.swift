//
//  RankViewModel.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 03.08.2024.
//

import Foundation

protocol RankViewModeling: BaseClass, ObservableObject {
    associatedtype categorySelectorVM: CategorySelectorViewModeling
    var categoryRankings: [Ranking] { get }
    var isLoading: Bool { get }
    var username: String { get }
    var csViewModel: categorySelectorVM { get }
    func onAppear()
}

final class RankViewModel<csVM: CategorySelectorViewModeling>: BaseClass, ObservableObject, RankViewModeling {
    typealias Dependencies = HasLoggerServicing & HasUserCategoryManager & HasUserRankManager & HasGameDataManager & HasUserLoginManager
    
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
    
    // MARK: - Public Properties
    
    @Published private(set) var categoryRankings: [Ranking] = []
    @Published private(set) var isLoading: Bool = false
    @Published var username: String = ""
    var csViewModel: csVM
    
    // MARK: - Initialization
    
    init(dependencies: Dependencies, categorySelectorVM: csVM, delegate: RankFlowDelegate?) {
        self.logger = dependencies.logger
        self.userCategoryManager = dependencies.userCategoryManager
        self.userRankManager = dependencies.userRankManager
        self.gameDataManager = dependencies.gameDataManager
        self.userDataManager = dependencies.userLoginManager
        gameDataManager.delegate = delegate
        self.delegate = delegate
        self.csViewModel = categorySelectorVM
        
        super.init()
        self.setupBindings()
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
        Task { [weak self] in
            guard let stream = self?.userCategoryManager.selectedCategoryStream else { return }
            for await _ in stream {
                guard let self = self else { return }
                await self.getSelectedCategoryRanking()
            }
        }
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
        
        // Find the user rank for the selected category
        if let userRank = userRankManager.getById(id: selectedCategory.id) {
            // Convert RankedUser instances to Ranking instances
            let rankings = userRank.listUserRank.map { Ranking(from: $0) }
            await MainActor.run {
                self.categoryRankings = rankings
            }
        } else {
            logger.log(message: "No ranking data found for the selected category")
            delegate?.onNoDataAvailable()
        }
    }
}
