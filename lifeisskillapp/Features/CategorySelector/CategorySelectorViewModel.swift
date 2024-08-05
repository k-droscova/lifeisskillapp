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
    
    @Published var username: String = ""
    @Published var selectedCategory: UserCategory? {
        didSet {
            updateSelectedCategory()
        }
    }
    @Published private(set) var userCategories: [UserCategory] = []
    
    // MARK: - Initialization
    
    init(dependencies: Dependencies) {
        self.logger = dependencies.logger
        self.userDataManager = dependencies.userLoginManager
        self.userCategoryManager = dependencies.userCategoryManager
    }
    
    // MARK: - Public Interface
    
    func onAppear() {
        Task { @MainActor [weak self] in
            await self?.fetchNewDataIfNeccessary()
        }
    }
    
    // MARK: - Private Helpers
    
    private func fetchNewDataIfNeccessary() async {
        do {
            // Make sure all updates to @Published properties are done on the main thread
            await MainActor.run {
                self.username = userDataManager.userName ?? ""
            }
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
