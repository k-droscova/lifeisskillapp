//
//  UserLoginDataManager.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 21.07.2024.
//

import Foundation

protocol HasUserLoginManager {
    var userLoginManager: any UserLoginDataManaging { get }
}

protocol UserLoginDataManaging {
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
    typealias Dependencies = HasLoggerServicing & HasLoginAPIService & HasUserDataStorage & HasUserManager & HasRepositoryContainer & HasPersistentUserDataStoraging & HasNetworkMonitor & HasKeychainStorage
    
    // MARK: - Private Properties
    
    private let logger: LoggerServicing
    private let loginAPI: LoginAPIServicing
    private var realmLoginRepo: any RealmLoginRepositoring
    private var storage: PersistentUserDataStoraging
    private let networkMonitor: NetworkMonitoring
    private var isOnline: Bool { networkMonitor.onlineStatus }
    private let keychainStorage: KeychainStoraging
    
    // MARK: - Public Properties
    
    var isLoggedIn: Bool { data != nil }
    var data: LoginUserData?
    var userId: String? { self.data?.user.id }
    var token: String? { self.data?.user.token }
    var userName: String? { self.data?.user.nick }
    var userMainCategory: String? { self.data?.user.mainCategory }
    
    // MARK: - Initialization
    
    init(dependencies: Dependencies) {
        self.logger = dependencies.logger
        self.loginAPI = dependencies.loginAPI
        self.realmLoginRepo = dependencies.container.realmLoginRepository
        self.storage = dependencies.storage
        self.networkMonitor = dependencies.networkMonitor
        self.keychainStorage = dependencies.keychainStorage
        
        super.init()
        self.load()
    }
    
    // MARK: - Public Interface
    
    func login(credentials: LoginCredentials) async throws {
        logger.log(message: "Login User: " + credentials.username)
        if isOnline {
            try await performOnlineLogin(credentials: credentials)
        } else {
            try performOfflineLogin(credentials: credentials)
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
            await self?.storage.loadFromRepository(for: .login) // load the login data from repo to storage login property
            self?.checkIfUserIsLoggedIn() // check if the user has logged out before, or is still logged in
        }
    }
    
    private func checkIfUserIsLoggedIn() {
        do {
            // if the user hasn't logged out then I use that data
            if let storedLoginData = try realmLoginRepo.getLoggedInUser(), storedLoginData.isLoggedIn {
                self.data = storedLoginData.toLoginData() // gives signal to show main page
            } else {
                self.data = nil // gives signal to show login page
            }
        } catch {
            logger.log(message: "Failed to load login data: \(error.localizedDescription)")
            self.data = nil // gives signal to show login page
        }
    }
    
    private func performOnlineLogin(credentials: LoginCredentials) async throws {
        do {
            let response = try await loginAPI.login(loginCredentials: credentials, baseURL: APIUrl.baseURL)
            let loggedInUser = response.data.user
            
            // check if there is logged in user data
            guard let existingUser = try realmLoginRepo.getLoggedInUser() else {
                try keychainStorage.save(credentials: credentials) // save new credentials to keychain
                try realmLoginRepo.saveLoginUser(loggedInUser) // save new data to realm
                data = response.data // give signal of successfull login
                return
            }
            // if the newly logged in user is different then we clear all data in realm
            if loggedInUser.userId != existingUser.userID {
                logger.log(message: "Different user detected. Clearing all related data.")
                try await storage.clearAllUserData() // clear all data
                try keychainStorage.delete() // delete previous credentials
                try keychainStorage.save(credentials: credentials) // save new credentials in keychain
            }
            
            try realmLoginRepo.saveLoginUser(loggedInUser) // save the new login data, more specifically the new token
            data = response.data // give signal of successfull login
        } catch {
            throw BaseError(
                context: .system,
                message: "Unable to login",
                logger: logger
            )
        }
    }
    
    private func performOfflineLogin(credentials: LoginCredentials) throws {
        guard let storedUsername = keychainStorage.username,
              let storedPassword = keychainStorage.password,
              storedUsername == credentials.username,
              storedPassword == credentials.password else {
            throw BaseError(
                context: .system,
                message: "Offline login failed: credentials do not match.",
                code: .login(.offlineInvalidCredentials),
                logger: logger
            )
        }
        guard let storedLoginData = try realmLoginRepo.getLoggedInUser(), !storedLoginData.isLoggedIn else {
            throw BaseError(
                context: .system,
                message: "Offline login failed: unable to retrieve realm data.",
                logger: logger
            )
        }
        self.data = storedLoginData.toLoginData()
    }
}
