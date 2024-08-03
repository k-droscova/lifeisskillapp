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
    typealias Dependencies = HasLoggerServicing & HasUserCategoryManager & HasUserRankManager
    
    // MARK: - Private Properties
    
    private weak var delegate: RankFlowDelegate?
    private let logger: LoggerServicing
    private let userCategoryManager: any UserCategoryManaging
    private var selectedCategory: UserCategory? {
        userCategoryManager.selectedCategory
    }
    private let userRankManager: any UserRankManaging
    private var userRankData: [UserRank] {
        fetchAllUserRankData()
    }
    
    // MARK: - Public Properties
    
    @Published private(set) var categoryRankings: [Ranking] = []
    @Published private(set) var isLoading: Bool = false
    
    // MARK: - Initialization
    
    init(dependencies: Dependencies, delegate: RankFlowDelegate?) {
        self.logger = dependencies.logger
        self.userCategoryManager = dependencies.userCategoryManager
        self.userRankManager = dependencies.userRankManager
        self.delegate = delegate
    }
    
    // MARK: - Public Interface
    
    func onAppear() {
        Task { @MainActor in
            isLoading = true
            await fetchNewDataIfNeccessary()
            getSelectedCategoryRanking()
            isLoading = false
        }
    }
    
    // MARK: - Private Helpers
    
    private func fetchNewDataIfNeccessary() async {
        do {
            try await userRankManager.fetch()
        } catch {
            logger.log(message: "ERROR: Unable to fetch new user rank data")
            delegate?.onError(error)
        }
    }
    
    private func fetchAllUserRankData() -> [UserRank] {
        userRankManager.getAll()
    }
    
    private func getSelectedCategoryRanking() {
        guard let selectedCategory = selectedCategory else {
            logger.log(message: "No selected category found")
            delegate?.selectCategoryPrompt()
            return
        }
        
        guard userRankData.isNotEmpty else {
            logger.log(message: "No user rank data available")
            delegate?.onNoDataAvailable()
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
