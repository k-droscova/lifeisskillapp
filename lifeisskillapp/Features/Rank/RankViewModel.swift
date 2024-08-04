//
//  RankViewModel.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 03.08.2024.
//

import Foundation

protocol RankViewModeling: BaseClass, ObservableObject {
    var categoryRankings: [Ranking] { get }
    var isLoading: Bool { get }
    func onAppear()
}

final class RankViewModel: BaseClass, ObservableObject, RankViewModeling {
    typealias Dependencies = HasLoggerServicing & HasUserCategoryManager & HasUserRankManager & HasGameDataManager
    
    // MARK: - Private Properties
    
    private weak var delegate: RankFlowDelegate?
    private let logger: LoggerServicing
    private var gameDataManager: GameDataManaging
    private let userCategoryManager: any UserCategoryManaging
    private let userRankManager: any UserRankManaging
    private var selectedCategory: UserCategory? {
        getSelectedCategory()
    }
    
    // MARK: - Public Properties
    
    @Published private(set) var categoryRankings: [Ranking] = []
    @Published private(set) var isLoading: Bool = false
    
    // MARK: - Initialization
    
    init(dependencies: Dependencies, delegate: RankFlowDelegate?) {
        self.logger = dependencies.logger
        self.userCategoryManager = dependencies.userCategoryManager
        self.userRankManager = dependencies.userRankManager
        self.gameDataManager = dependencies.gameDataManager
        gameDataManager.delegate = delegate
        self.delegate = delegate
        
        super.init()
        self.setupBindings()
    }
    
    // MARK: - Public Interface
    
    func onAppear() {
        Task { @MainActor in
            isLoading = true
            await fetchData()
            isLoading = false
        }
    }
    
    // MARK: - Private Helpers
    
    private func setupBindings() {
        Task { [weak self] in
            guard let stream = self?.userCategoryManager.selectedCategoryStream else { return }
            for await _ in stream {
                guard let self = self else { return }
                self.getSelectedCategoryRanking()
            }
        }
    }
    
    @MainActor
    private func fetchData() async {
        do {
            try await userCategoryManager.fetch()
            await gameDataManager.fetchNewDataIfNeccessary(endpoint: .rank)
            getSelectedCategoryRanking()
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
    
    private func getSelectedCategoryRanking() {
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
            categoryRankings = rankings
        } else {
            logger.log(message: "No ranking data found for the selected category")
            delegate?.onNoDataAvailable()
        }
    }
}
