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
    typealias Dependencies = HasLoggerServicing & HasUserDataAPIService & HasPersistentUserDataStoraging & HasUserManager
    
    // MARK: - Private Properties
    
    private var storage: PersistentUserDataStoraging
    private let logger: LoggerServicing
    private let userManager: UserManaging
    private let userDataAPIService: UserDataAPIServicing
    private var checkSum: String?
    
    // MARK: - Public Properties
    
    var data: UserRankData? {
        get {
            storage.userRankData
        }
        set {
            storage.userRankData = newValue
        }
    }
    
    var token: String? {
        get { userManager.token }
    }
    
    // MARK: - Initialization
    
    init(dependencies: Dependencies) {
        self.storage = dependencies.storage
        self.logger = dependencies.logger
        self.userManager = dependencies.userManager
        self.userDataAPIService = dependencies.userDataAPI
        
        super.init()
    }
    
    // MARK: - Public Interface
    
    func loadFromRepository() {
        Task { @MainActor [weak self] in
            await self?.storage.loadFromRepository(for: .rankings)
        }
    }
    
    func fetch(withToken token: String) async throws {
        logger.log(message: "Loading user ranks")
        do {
            let response = try await userDataAPIService.getRank(baseURL: APIUrl.baseURL, userToken: token)
            data = response.data
        } catch let error as BaseError {
            if error.code == ErrorCodes.specificStatusCode(.invalidToken).code {
                userManager.forceLogout()
                return
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
}
