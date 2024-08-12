//
//  UserLoginDataManager.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 21.07.2024.
//

import Foundation

protocol UserLoginManagerFlowDelegate: UserDataManagerFlowDelegate {
}

protocol HasUserLoginManager {
    var userLoginManager: any UserLoginDataManaging { get }
}

protocol UserLoginDataManaging {
    var delegate: UserLoginManagerFlowDelegate? { get set }
    var data: LoginUserData? { get set }
    
    var userId: String? { get }
    var token: String? { get }
    var userName: String? { get }
    var userMainCategory: String? { get }
    var isLoggedIn: Bool { get }
    
    func login(credentials: LoginCredentials) async throws
    func logout()
}

public final class UserLoginDataManager: BaseClass, UserLoginDataManaging {
    typealias Dependencies = HasLoggerServicing & HasLoginAPIService & HasUserDataStorage & HasUserManager & HasRepositoryContainer & HasPersistentUserDataStoraging
    
    // MARK: - Private Properties
    
    private let logger: LoggerServicing
    private let loginAPI: LoginAPIServicing
    private var realmLoginRepo: any RealmLoginRepositoring
    private var storage: PersistentUserDataStoraging
    
    // MARK: - Public Properties
    
    /*
     TODO: need to resolve whether it is necessary to be declared public or can be set during init (which class will be responsible for onInvalidToken())
     Now it can be set from anywhere, needs to be handled with caution.
     */
    weak var delegate: UserLoginManagerFlowDelegate?
    
    var isLoggedIn: Bool { data != nil }
    
    var data: LoginUserData?
    
    var userId: String? {
        get { self.data?.user.id }
    }
    
    var token: String? {
        get { self.data?.user.token }
    }
    
    var userName: String? {
        get { self.data?.user.nick }
    }
    
    var userMainCategory: String? {
        get { self.data?.user.mainCategory }
    }
    
    // MARK: - Initialization
    
    init(dependencies: Dependencies) {
        self.logger = dependencies.logger
        self.loginAPI = dependencies.loginAPI
        self.realmLoginRepo = dependencies.container.realmLoginRepository
        self.storage = dependencies.storage
        
        super.init()
        self.load()
    }
    
    // MARK: - Public Interface
    
    func login(credentials: LoginCredentials) async throws {
        logger.log(message: "Login User: " + credentials.username)
        do {
            let response = try await loginAPI.login(loginCredentials: credentials, baseURL: APIUrl.baseURL)
            let loggedInUser = response.data.user
            // Check if there is an existing logged-in user
            if let existingUser = try realmLoginRepo.getLoggedInUser(), existingUser.userID != loggedInUser.userId {
                // If the existing user's ID is different from the new user's ID, clear all user data
                logger.log(message: "Different user detected. Clearing all related data.")
                try await storage.clearAllUserData()
            }
            try realmLoginRepo.saveLoginUser(loggedInUser)
            data = response.data
        } catch let error as BaseError {
            if error.code == ErrorCodes.specificStatusCode(.invalidToken).code {
                delegate?.onInvalidToken()
            }
        }
        catch {
            throw BaseError(
                context: .system,
                message: "Unable to login",
                logger: logger
            )
        }
    }
    
    func logout() {
        logger.log(message: "Logging out")
        do {
            // Mark the user as logged out in persistent storage
            try realmLoginRepo.markUserAsLoggedOut()
        } catch {
            logger.log(message: "Failed to mark user as logged out: \(error.localizedDescription)")
        }
        data = nil
    }
    
    func getById(id: String) -> LoggedInUser? {
        data?.user
    }
    
    func getAll() -> [LoggedInUser] {
        if let user = data?.user {
            return [user]
        }
        return []
    }
    
    // MARK: - Private Helpers
    
    private func load() {
        Task { @MainActor [weak self] in
            await self?.storage.loadFromRepository(for: .login)
            self?.updateLoginData()
        }
    }

    private func updateLoginData() {
        do {
            if let storedLoginData = try realmLoginRepo.getLoggedInUser(), storedLoginData.isLoggedIn {
                self.data = storedLoginData.toLoginData()
            } else {
                self.data = nil
            }
        } catch {
            logger.log(message: "Failed to load login data: \(error.localizedDescription)")
            self.data = nil
        }
    }
}
