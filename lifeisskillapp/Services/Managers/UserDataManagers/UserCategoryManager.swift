//
//  UserCategoryManager.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 16.07.2024.
//

import Foundation

protocol UserCategoryManagerFlowDelegate: UserDataManagerFlowDelegate {
}

protocol HasUserCategoryManager {
    var userCategoryManager: any UserCategoryManaging { get }
}

protocol UserCategoryManaging: UserDataManaging where DataType == UserCategory, DataContainer == UserCategoryData {
    var delegate: UserCategoryManagerFlowDelegate? { get set }
    func getMainCategory() -> UserCategory?
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
    
    var data: UserCategoryData? {
        get {
            return dependencies.userDataStorage.userCategoryData
        }
        set {
            dependencies.userDataStorage.userCategoryData = newValue
        }
    }
    
    // MARK: - Public Interface
    func fetch() async throws {
        dependencies.logger.log(message: "Loading user categories")
        do {
            let response = try await dependencies.userDataAPI.getUserCategory(baseURL: APIUrl.baseURL)
            dependencies.userDataStorage.beginTransaction()
            data = response.data
            dependencies.userDataStorage.commitTransaction()
            delegate?.onUpdate()
        } catch {
            throw BaseError(
                context: .system,
                message: "Unable to load user categories",
                logger: dependencies.logger
            )
        }
    }
    
    func getById(id: String) -> UserCategory? {
        return data?.data.first { $0.id == id }
    }
    
    func getAll() -> [UserCategory] {
        return data?.data ?? []
    }
    
    func getMainCategory() -> UserCategory? {
        return data?.main
    }
}
