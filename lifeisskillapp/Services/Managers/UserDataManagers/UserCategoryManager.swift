//
//  UserCategoryManager.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 16.07.2024.
//

import Foundation

protocol UserCategoryManagerFlowDelegate: NSObject {
    func onUserCategoriesUpdated()
}

protocol HasUserCategoryManager {
    var userCategoryManager: UserCategoryManaging { get }
}

protocol UserCategoryManaging {
    var delegate: UserCategoryManagerFlowDelegate? { get set }
    var userCategoryData: UserCategoryData? { get set }
    func loadUserCategories() async throws
    func getMainCategory() -> UserCategory?
    func findCategoryById(id: String) -> UserCategory?
    func getAllCategories() -> [UserCategory]
}

public final class UserCategoryManager: UserCategoryManaging {
    typealias Dependencies = HasLoggerServicing & HasUserDataAPIService & HasUserDataStorage
    private var dependencies: Dependencies
    
    // MARK: - Initialization
    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }
    
    // MARK: - Public Properties
    weak var delegate: UserCategoryManagerFlowDelegate?
    
    var userCategoryData: UserCategoryData? {
        get {
            return dependencies.userDataStorage.userCategoryData
        }
        set {
            dependencies.userDataStorage.userCategoryData = newValue
        }
    }
    
    // MARK: - Public Interface
    func loadUserCategories() async throws {
        dependencies.logger.log(message: "Loading user categories")
        do {
            let response = try await dependencies.userDataAPI.getUserCategory(baseURL: APIUrl.baseURL)
            dependencies.userDataStorage.beginTransaction()
            userCategoryData = response.data
            dependencies.userDataStorage.commitTransaction()
            delegate?.onUserCategoriesUpdated()
        } catch {
            throw BaseError(
                context: .system,
                message: "Unable to load user categories",
                logger: dependencies.logger
            )
        }
    }
    
    func getMainCategory() -> UserCategory? {
        return userCategoryData?.main
    }
    
    func findCategoryById(id: String) -> UserCategory? {
        return userCategoryData?.data.first { $0.id == id }
    }
    
    func getAllCategories() -> [UserCategory] {
        return userCategoryData?.data ?? []
    }
}
