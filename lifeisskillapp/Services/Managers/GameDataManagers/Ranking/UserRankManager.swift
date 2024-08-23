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
    typealias Dependencies = HasLoggerServicing & HasUserDataAPIService & HasPersistentUserDataStoraging & HasUserManager & HasNetworkMonitor
    
    // MARK: - Private Properties
    
    private var storage: PersistentUserDataStoraging
    private let logger: LoggerServicing
    private let userManager: UserManaging
    private let userDataAPIService: UserDataAPIServicing
    private var _data: UserRankData?
    
    internal let networkMonitor: NetworkMonitoring

    
    // MARK: - Public Properties
    
    var token: String? { userManager.token }
    
    // MARK: - Initialization
    
    init(dependencies: Dependencies) {
        self.storage = dependencies.storage
        self.logger = dependencies.logger
        self.userManager = dependencies.userManager
        self.userDataAPIService = dependencies.userDataAPI
        self.networkMonitor = dependencies.networkMonitor

        super.init()
        self.loadFromRepository()
    }
    
    // MARK: - Public Interface
    
    func loadFromRepository() {
        Task { @MainActor [weak self] in
            do {
                try await self?.storage.loadFromRepository(for: .rankings)
                self?._data = try await self?.storage.userRankData()
            } catch {
                self?.logger.log(message: "Unable to load user ranks from storage")
            }
        }
    }
    
    func fetch(withToken token: String) async throws {
        logger.log(message: "Fetching user ranks")
        do {
            let response = try await userDataAPIService.getRank(baseURL: APIUrl.baseURL, userToken: token)
            try await storage.saveUserRankData(response.data)
            _data = response.data
        } catch let error as BaseError {
            if error.code == ErrorCodes.specificStatusCode(.invalidToken).code {
                userManager.forceLogout()
                return
            } else {
                throw error
            }
        } catch {
            throw BaseError(
                context: .system,
                message: "Unable to load user ranks",
                logger: logger
            )
        }
    }
    
    func getById(id: String) -> UserRank? {
        _data?.data.first { $0.id == id }
    }
    
    func getAll() -> [UserRank] {
        _data?.data ?? []
    }
    
    func onLogout() {
        _data = nil
    }
    
    func checkSum() -> String? {
        _data?.checkSum
    }
}
