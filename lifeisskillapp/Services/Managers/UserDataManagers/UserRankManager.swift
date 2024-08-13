//
//  UserRankManager.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 21.07.2024.
//

import Foundation
import Combine

protocol HasUserRankManager {
    var userRankManager: any UserRankManaging { get }
}

protocol UserRankManaging: UserDataManaging where DataType == UserRank, DataContainer == UserRankData {
}

public final class UserRankManager: BaseClass, UserRankManaging {    
    typealias Dependencies = HasLoggerServicing & HasUserDataAPIService & HasPersistentUserDataStoraging & HasUserLoginManager
    
    // MARK: - Private Properties
    
    private var storage: PersistentUserDataStoraging
    private let logger: LoggerServicing
    private let dataManager: UserLoginDataManaging
    private let userDataAPIService: UserDataAPIServicing
    private var cancellables = Set<AnyCancellable>()
    private var checkSum: String?
    
    // MARK: - Public Properties
    
    /*
     TODO: need to resolve whether it is necessary to be declared public or can be set during init (which class will be responsible for onUpdate)
     Now it can be set from anywhere, needs to be handled with caution.
     */
    weak var delegate: UserDataManagerFlowDelegate?
    
    var data: UserRankData? {
        get {
            storage.userRankData
        }
        set {
            storage.userRankData = newValue
        }
    }
    
    var token: String? {
        get { dataManager.token }
    }
    
    // MARK: - Initialization
    
    init(dependencies: Dependencies) {
        self.storage = dependencies.storage
        self.logger = dependencies.logger
        self.dataManager = dependencies.userLoginManager
        self.userDataAPIService = dependencies.userDataAPI
        
        super.init()
        self.load()
    }
    
    // MARK: - Public Interface
    
    func fetch(withToken token: String) async throws {
        logger.log(message: "Loading user ranks")
        do {
            let response = try await userDataAPIService.getRank(baseURL: APIUrl.baseURL, userToken: token)
            data = response.data
        } catch let error as BaseError {
            if error.code == ErrorCodes.specificStatusCode(.invalidToken).code {
                delegate?.onInvalidToken()
            }
        }
        catch {
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
    
    // MARK: - Private Helpers
    
    private func load() {
        Task { @MainActor [weak self] in
            await self?.storage.loadFromRepository(for: .rankings)
        }
    }
}
