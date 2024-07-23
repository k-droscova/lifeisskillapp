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

public final class UserRankManager: BaseClass, UserRankManaging {    
    typealias Dependencies = HasLoggerServicing & HasUserDataAPIService & HasUserDataStorage & HasUserLoginManager
    
    // MARK: - Private Properties
    
    private var userDataStorage: UserDataStoraging
    private let logger: LoggerServicing
    private let dataManager: UserLoginDataManaging
    private let userDataAPIService: UserDataAPIServicing
    
    // MARK: - Public Properties
    
    /*
     Delegate is not able to be passed into init, hence declared public.
     Must be handled with caution -> can be set from anywhere
     */
    weak var delegate: UserRankManagerFlowDelegate?
    
    var data: UserRankData? {
        get {
            userDataStorage.userRankData
        }
        set {
            userDataStorage.userRankData = newValue
        }
    }
    
    var token: String? {
        get { dataManager.token }
    }
    
    // MARK: - Initialization
    
    init(dependencies: Dependencies) {
        self.userDataStorage = dependencies.userDataStorage
        self.logger = dependencies.logger
        self.dataManager = dependencies.userLoginManager
        self.userDataAPIService = dependencies.userDataAPI
    }
    
    // MARK: - Public Interface
    
    func fetch(withToken token: String) async throws {
        logger.log(message: "Loading user ranks")
        do {
            let response = try await userDataAPIService.getRank(baseURL: APIUrl.baseURL, userToken: token)
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
