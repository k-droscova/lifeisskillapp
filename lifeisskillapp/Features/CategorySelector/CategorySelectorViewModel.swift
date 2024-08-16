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
    typealias Dependencies = HasLoggerServicing & HasUserCategoryManager
    
    // MARK: - Private Properties
    
    private let logger: LoggerServicing
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
        do {
            try await userCategoryManager.fetch()
            let categories = getAllUserCategories()
            await MainActor.run {
                self.userCategories = categories
                self.selectedCategory = userCategoryManager.selectedCategory ?? userCategoryManager.data?.data.first
            }
        } catch {
            logger.log(message: "ERROR: Unable to fetch new user category data")
        }
    }
    
    private func updateSelectedCategory() {
        userCategoryManager.selectedCategory = selectedCategory
    }
    
    private func getAllUserCategories() -> [UserCategory] {
        userCategoryManager.getAll()
    }
}
