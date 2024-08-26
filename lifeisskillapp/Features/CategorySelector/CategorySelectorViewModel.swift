//
//  CategorySelectorViewModel.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 02.08.2024.
//

import Foundation
import Observation

protocol CategorySelectorViewModeling: BaseClass, ObservableObject {
    var selectedCategory: UserCategory? { get set }
    var userCategories: [UserCategory] { get }
}

final class CategorySelectorViewModel: BaseClass, ObservableObject, CategorySelectorViewModeling {
    typealias Dependencies = HasLoggerServicing & HasUserCategoryManager & HasGameDataManager
    
    // MARK: - Private Properties
    
    private let logger: LoggerServicing
    private let gameDataManager: GameDataManaging
    private var userCategoryManager: any UserCategoryManaging
    
    // MARK: - Public Properties
    
    @Published var selectedCategory: UserCategory? {
        didSet {
            updateSelectedCategory()
        }
    }
    @Published private(set) var userCategories: [UserCategory] = []
    
    // MARK: - Initialization
    
    init(dependencies: Dependencies) {
        self.logger = dependencies.logger
        self.userCategoryManager = dependencies.userCategoryManager
        self.gameDataManager = dependencies.gameDataManager
        super.init()
        /*
         Fetching of user categories is performed only after login when CS VM is initialized in MainFC.
         If online fetching fails then it falls back to the data that is loaded from Repo in userCategoryManager init
         */
        self.load()
    }
    
    // MARK: - Private Helpers
    
    private func load() {
        Task { @MainActor [weak self] in
            await self?.fetchData()
        }
    }
    
    private func fetchData() async {
        // TODO: ask martin if I should load new category data for every display of category selector or if it sufficed to keep the fetching limited to login
        //await gameDataManager.loadData(for: .categories)
        let categories = getAllUserCategories()
        await MainActor.run {
            self.userCategories = categories
            self.selectedCategory = userCategoryManager.selectedCategory ?? userCategoryManager.getAll().first
        }
    }
    
    private func updateSelectedCategory() {
        userCategoryManager.selectedCategory = selectedCategory
    }
    
    private func getAllUserCategories() -> [UserCategory] {
        userCategoryManager.getAll()
    }
}
