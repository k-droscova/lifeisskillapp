//
//  UserManager.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 01.07.2024.
//

import Foundation

protocol UserManagerFlowDelegate: NSObject {
    func onLogout()
    func onForceLogout()
}

protocol HasUserManager {
    var userManager: UserManaging { get }
}

protocol UserManaging {
    var delegate: UserManagerFlowDelegate? { get set }
    
    // MARK: APP SETUP RELATED PROPERTIES
    
    var isLoggedIn: Bool { get }
    var hasAppId: Bool { get }
    
    // MARK: LOGGED IN USER PROPERTIES
    
    var userId: String? { get }
    var token: String? { get }
    var userName: String? { get }
    var userMainCategory: String? { get }
    var userGender: UserGender? { get }
    
    func initializeAppId() async throws
    func login(credentials: LoginCredentials) async throws
    func logout()
    func forceLogout()
    func offlineLogout()
}

final class UserManager: BaseClass, UserManaging {
    typealias Dependencies = HasNetwork & HasAPIDependencies & HasLoggerServicing & HasUserDefaultsStorage & HasUserDataManagers & HasRepositoryContainer & HasPersistentUserDataStoraging & HasNetworkMonitor & HasKeychainStorage
    
    // MARK: - Private Properties
    
    private let logger: LoggerServicing
    private var userDefaultsStorage: UserDefaultsStoraging
    private var storage: PersistentUserDataStoraging
    private let registerAppAPI: RegisterAppAPIServicing
    private let loginAPI: LoginAPIServicing
    private var realmLoginRepo: any RealmLoginRepositoring
    private let networkMonitor: NetworkMonitoring
    private let keychainStorage: KeychainStoraging
    
    private var data: LoginUserData?
    private var isOnline: Bool { networkMonitor.onlineStatus }

    
    // MARK: - Public Properties
    
    weak var delegate: UserManagerFlowDelegate?
    var isLoggedIn: Bool { data != nil }
    var hasAppId: Bool { userDefaultsStorage.appId != nil }
    var userId: String? { self.data?.user.id }
    var token: String? { self.data?.user.token }
    var userName: String? { self.data?.user.nick }
    var userMainCategory: String? { self.data?.user.mainCategory }
    var userGender: UserGender? { self.data?.user.sex }
    
    // MARK: - Initialization
    
    init(dependencies: Dependencies) {
        self.logger = dependencies.logger
        self.userDefaultsStorage = dependencies.userDefaultsStorage
        self.registerAppAPI = dependencies.registerAppAPI
        self.loginAPI = dependencies.loginAPI
        self.realmLoginRepo = dependencies.container.realmLoginRepository
        self.storage = dependencies.storage
        self.networkMonitor = dependencies.networkMonitor
        self.keychainStorage = dependencies.keychainStorage
        
        super.init()
    }
    
    // MARK: - Public interface
    
    func initializeAppId() async throws {
        logger.log(message: "Initializing App Id")
        if let appId = userDefaultsStorage.appId {
            logger.log(message: "App Id \(appId) exists")
            return
        }
        do {
            let response = try await registerAppAPI.registerApp(baseURL: APIUrl.baseURL)
            let responseAppId = response.data.appId
            userDefaultsStorage.appId = responseAppId
        } catch {
            throw BaseError(
                context: .system,
                message: "Unable to obtain App Id",
                logger: logger
            )
        }
    }
    
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
            try storage.onLogout()
        } catch {
            logger.log(message: "Failed to logout: \(error.localizedDescription)")
        }
        data = nil
        delegate?.onLogout()
    }
    
    func offlineLogout() {
        Task { @MainActor [weak self] in
            do {
                try await self?.storage.clearSavedScannedPoints()
                self?.data = nil
                self?.delegate?.onLogout()
            } catch {
                self?.logger.log(message: "Error: offline logout failed")
            }
        }
    }
    
    func forceLogout() {
        logger.log(message: "Forced logout")
        do {
            try storage.onLogout()
        } catch {
            logger.log(message: "Failed to mark user as logged out: \(error.localizedDescription)")
        }
        data = nil
        delegate?.onForceLogout()
    }
    
    // MARK: - Private Helpers
    
    private func load() {
        Task { @MainActor [weak self] in
            self?.checkIfUserIsLoggedIn() // check if the user has logged out before, or is still logged in
        }
    }
    
    private func checkIfUserIsLoggedIn() {
        do {
            // if the user hasn't logged out then I use that data
            if let storedLoginData = try realmLoginRepo.getSavedLoginDetails(), storedLoginData.isLoggedIn {
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
            guard let existingUser = try realmLoginRepo.getSavedLoginDetails() else {
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
        guard let storedLoginData = try realmLoginRepo.getSavedLoginDetails() else {
            throw BaseError(
                context: .system,
                message: "Offline login failed: unable to retrieve realm data.",
                logger: logger
            )
        }
        guard !storedLoginData.isLoggedIn else {
            throw BaseError(
                context: .system,
                message: "Offline login failed: user is supposedly already logged in in realm database.",
                logger: logger
            )
        }
        try realmLoginRepo.markUserAsLoggedIn()
        self.data = storedLoginData.toLoginData()
    }
}

extension UserManager: UserDataManagerFlowDelegate {
    func onInvalidToken() {
        self.forceLogout()
    }
}
