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
            userCategoryManager.selectedCategory = selectedCategory
        }
    }
    var userCategories: [UserCategory] {
        userCategoryManager.getAll()
    }
    
    init(dependencies: Dependencies) {
        self.logger = dependencies.logger
        self.userDataManager = dependencies.userLoginManager
        self.userCategoryManager = dependencies.userCategoryManager
        self.username = dependencies.userLoginManager.userName ?? ""
        self.selectedCategory = dependencies.userCategoryManager.selectedCategory ?? dependencies.userCategoryManager.data?.data.first
    }
}
