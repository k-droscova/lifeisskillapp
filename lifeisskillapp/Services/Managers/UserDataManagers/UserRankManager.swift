//
//  UserRankManager.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 21.07.2024.
//

import Foundation

protocol UserRankManagerFlowDelegate: UserDataManagerFlowDelegate {
}

protocol HasUserRankManager {
    var userRankManager: any UserRankManaging { get }
}

protocol UserRankManaging: UserDataManaging where DataType == UserRank, DataContainer == UserRankData {
    var delegate: UserRankManagerFlowDelegate? { get set }
}

public final class UserRankManager: UserRankManaging {
    typealias Dependencies = HasLoggerServicing & HasUserDataAPIService & HasUserDataStorage & HasUserManager
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
    weak var delegate: UserRankManagerFlowDelegate?
    
    var data: UserRankData? {
        get {
            userDataStorage.userRankData
        }
        set {
            userDataStorage.userRankData = newValue
        }
    }
    
    // MARK: - Public Interface
    func fetch(credentials: LoginCredentials? = nil, userToken: String?) async throws {
        logger.log(message: "Loading user ranks")
        do {
            let response = try await userDataAPIService.getRank(baseURL: APIUrl.baseURL, userToken: userToken ?? "")
            userDataStorage.beginTransaction()
            data = response.data
            userDataStorage.commitTransaction()
            delegate?.onUpdate()
        } catch {
            throw BaseError(
                context: .system,
                message: "Unable to load user ranks",
                logger: logger
            )
        }
    }
    
    func getById(id: String) -> UserRank? {
        data?.data.first { $0.id == id }
    }
    
    func getAll() -> [UserRank] {
        data?.data ?? []
    }
}
