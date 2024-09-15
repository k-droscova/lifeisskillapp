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
    func onAppear()
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
    }
    
    func onAppear() {
        Task { @MainActor [weak self] in
            await self?.fetchData()
        }
    }
    
    // MARK: - Private Helpers
    
    private func fetchData() async {
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
