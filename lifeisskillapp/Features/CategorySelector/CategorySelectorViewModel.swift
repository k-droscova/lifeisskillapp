//
//  CategorySelectorViewModel.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 02.08.2024.
//

import Foundation
import Observation

protocol CategorySelectorViewModeling: BaseClass, ObservableObject {
    var username: String { get }
    var selectedCategory: UserCategory? { get set }
    var userCategories: [UserCategory] { get }
    func onAppear()
}

final class CategorySelectorViewModel: BaseClass, ObservableObject, CategorySelectorViewModeling {
    typealias Dependencies = HasLoggerServicing & HasUserLoginManager & HasUserCategoryManager
    
    // MARK: - Private Properties
    
    private let logger: LoggerServicing
    private let userDataManager: UserLoginDataManaging
    private var userCategoryManager: any UserCategoryManaging
    
    // MARK: - Public Properties
    
    var username: String
    @Published var selectedCategory: UserCategory? {
        didSet {
            updateSelectedCategory()
        }
    }
    var userCategories: [UserCategory] {
        getAllUserCategories()
    }
    
    // MARK: - Initialization
    
    init(dependencies: Dependencies) {
        self.logger = dependencies.logger
        self.userDataManager = dependencies.userLoginManager
        self.userCategoryManager = dependencies.userCategoryManager
        self.username = dependencies.userLoginManager.userName ?? ""
        self.selectedCategory = dependencies.userCategoryManager.selectedCategory ?? dependencies.userCategoryManager.data?.data.first
    }
    
    // MARK: - Public Interface
    
    func onAppear() {
        Task { @MainActor in
            await fetchNewDataIfNeccessary()
        }
    }
    
    // MARK: - Private Helpers
    
    private func fetchNewDataIfNeccessary() async {
        do {
            try await userCategoryManager.fetch()
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
