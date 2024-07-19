//
//  UserPointManager.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 16.07.2024.
//

import Foundation

protocol UserPointManagerFlowDelegate: UserDataManagerFlowDelegate {
}

protocol HasUserPointManager {
    var userPointManager: any UserPointManaging { get }
}

protocol UserPointManaging: UserDataManaging where DataType == UserPoint, DataContainer == UserPointData {
    var delegate: UserPointManagerFlowDelegate? { get set }
    func getPoints(byCategory categoryId: String) -> [UserPoint]
}

public final class UserPointManager: UserPointManaging {
    typealias Dependencies = HasLoggerServicing & HasUserDataAPIService & HasUserDataStorage & HasUserManager
    private var userDataStorage: UserDataStoraging
    private var logger: LoggerServicing
    private var userDataAPIService: UserDataAPIServicing
    private var userManager: UserManaging
    
    // MARK: - Initialization
    init(dependencies: Dependencies) {
        self.userDataStorage = dependencies.userDataStorage
        self.logger = dependencies.logger
        self.userDataAPIService = dependencies.userDataAPI
        self.userManager = dependencies.userManager
    }
    
    // MARK: - Public Properties
    weak var delegate: UserPointManagerFlowDelegate?
    
    var data: UserPointData? {
        get {
            userDataStorage.userPointData
        }
        set {
            userDataStorage.userPointData = newValue
        }
    }
    
    // MARK: - Public Interface
    func fetch() async throws {
        logger.log(message: "Loading user points")
        do {
            let response = try await userDataAPIService.getUserPoints(baseURL: APIUrl.baseURL, userToken: userManager.token ?? "")
            userDataStorage.beginTransaction()
            data = response.data
            userDataStorage.commitTransaction()
            delegate?.onUpdate()
        } catch {
            throw BaseError(
                context: .system,
                message: "Unable to load user points",
                logger: logger
            )
        }
    }
    
    func getById(id: String) -> UserPoint? {
        data?.data.first { $0.id == id }
    }
    
    func getAll() -> [UserPoint] {
        data?.data ?? []
    }
    
    func getPoints(byCategory categoryId: String) -> [UserPoint] {
        data?.data.filter { $0.pointCategory.contains(categoryId) } ?? []
    }
}
