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

final class UserRankManager: BaseClass, UserRankManaging {
    typealias Dependencies = HasLoggerServicing & HasUserDataAPIService & HasPersistentUserDataStoraging & HasUserManager & HasNetworkMonitor
    
    // MARK: - Private Properties
    
    private var storage: PersistentUserDataStoraging
    private let logger: LoggerServicing
    private let userDataAPIService: UserDataAPIServicing
    private var _data: UserRankData?
    
    // MARK: - Public Properties
    
    var token: String? { storage.token }
    let networkMonitor: NetworkMonitoring
    
    // MARK: - Initialization
    
    init(dependencies: Dependencies) {
        self.storage = dependencies.storage
        self.logger = dependencies.logger
        self.userDataAPIService = dependencies.userDataAPI
        self.networkMonitor = dependencies.networkMonitor
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
        let response = try await userDataAPIService.userRanks(userToken: token)
        try await storage.saveUserRankData(response.data)
        _data = response.data
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
