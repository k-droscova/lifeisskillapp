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
    private var userDataStorage: UserDataStoraging
    private var logger: LoggerServicing
    private var userDataAPIService: UserDataAPIServicing
    
    // MARK: - Initialization
    init(dependencies: Dependencies) {
        self.userDataStorage = dependencies.userDataStorage
        self.logger = dependencies.logger
        self.userDataAPIService = dependencies.userDataAPI
    }
    
    // MARK: - Public Properties
    weak var delegate: UserCategoryManagerFlowDelegate?
    
    var data: UserCategoryData? {
        get {
            userDataStorage.userCategoryData
        }
        set {
            userDataStorage.userCategoryData = newValue
        }
    }
    
    // MARK: - Public Interface
    func fetch() async throws {
        logger.log(message: "Loading user categories")
        do {
            let response = try await userDataAPIService.getUserCategory(baseURL: APIUrl.baseURL)
            userDataStorage.beginTransaction()
            data = response.data
            userDataStorage.commitTransaction()
            delegate?.onUpdate()
        } catch {
            throw BaseError(
                context: .system,
                message: "Unable to load user categories",
                logger: logger
            )
        }
    }
    
    func getById(id: String) -> UserCategory? {
        data?.data.first { $0.id == id }
    }
    
    func getAll() -> [UserCategory] {
        data?.data ?? []
    }
    
    func getMainCategory() -> UserCategory? {
        data?.main
    }
}
