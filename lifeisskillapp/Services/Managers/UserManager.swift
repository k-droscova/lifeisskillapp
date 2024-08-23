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
    
    // MARK: LOGGED IN USER PROPERTIES FOR VIEWMODELS
    
    //var token: String? { get }
    var userName: String? { get }
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
    private let networkMonitor: NetworkMonitoring
    private let keychainStorage: KeychainStoraging
    
    private var data: LoginUserData?
    private var isOnline: Bool { networkMonitor.onlineStatus }
    
    
    // MARK: - Public Properties
    
    weak var delegate: UserManagerFlowDelegate?
    var isLoggedIn: Bool { data != nil }
    var hasAppId: Bool { userDefaultsStorage.appId != nil }

    var userName: String? { self.data?.user.nick }
    var userGender: UserGender? { self.data?.user.sex }
    
    // MARK: - Initialization
    
    init(dependencies: Dependencies) {
        self.logger = dependencies.logger
        self.userDefaultsStorage = dependencies.userDefaultsStorage
        self.registerAppAPI = dependencies.registerAppAPI
        self.loginAPI = dependencies.loginAPI
        self.storage = dependencies.storage
        self.networkMonitor = dependencies.networkMonitor
        self.keychainStorage = dependencies.keychainStorage
        
        super.init()
    }
    
    // MARK: - Public interface
    
    func initializeAppId() async throws {
        if let appId = userDefaultsStorage.appId {
            logger.log(message: "App Id \(appId) exists")
            return
        }
        do {
            logger.log(message: "Initializing App Id")
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
            try await performOfflineLogin(credentials: credentials)
        }
    }
    
    func logout() {
        Task { @MainActor [weak self] in
            do {
                try await self?.storage.onLogout()
            } catch {
                self?.logger.log(message: "Failed to logout: \(error.localizedDescription)")
            }
            self?.data = nil
            self?.delegate?.onLogout()
        }
    }
    
    func offlineLogout() {
        Task { @MainActor [weak self] in
            do {
                try await self?.storage.clearScannedPointData()
                try await self?.storage.onLogout()
                self?.data = nil
                self?.delegate?.onLogout()
            } catch {
                self?.logger.log(message: "Error: offline logout failed")
            }
        }
    }
    
    func forceLogout() {
        Task { @MainActor [weak self] in
            do {
                try await self?.storage.clearScannedPointData()
                try await self?.storage.onLogout()
                self?.data = nil
                self?.delegate?.onForceLogout()
            } catch {
                self?.logger.log(message: "Error: force logout failed")
            }
        }
    }
    
    // MARK: - Private Helpers
    
    private func load() {
        Task { @MainActor [weak self] in
            await self?.checkIfUserIsLoggedIn() // check if the user has logged out before, or is still logged in
        }
    }
    
    private func checkIfUserIsLoggedIn() async {
        do {
            if let storedLoginData = try await storage.loggedInUserDetails() {
                self.data = storedLoginData // gives signal to show main page
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
            
            // check if there is existing user in realm
            guard let existingUser = try await storage.savedLoginDetails() else {
                try keychainStorage.save(credentials: credentials) // save new credentials to keychain
                try await storage.login(loggedInUser) // save new data to realm
                data = response.data // give signal of successfull login
                return
            }
            // if there is data in realm and if the newly logged in user is different then we clear all data in realm
            if loggedInUser.userId != existingUser.user.userId {
                logger.log(message: "Different user detected. Clearing all related data.")
                try await storage.clearUserRelatedData() // clear all data
            }
            try await storage.login(loggedInUser) // save the new login data
            try keychainStorage.delete() // delete previous credentials
            try keychainStorage.save(credentials: credentials) // save new credentials in keychain
            data = response.data // indicate to appFC to present Home Screen in TabBar
        } catch {
            throw BaseError(
                context: .system,
                message: "Unable to login",
                logger: logger
            )
        }
    }
    
    private func performOfflineLogin(credentials: LoginCredentials) async throws {
        // check keychain and that the data match
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
        // load stored data
        guard try await storage.loggedInUserDetails() == nil else {
            throw BaseError(
                context: .system,
                message: "Offline login failed: unable to retrieve realm data.",
                logger: logger
            )
        }
        guard let storedLoginData = try await storage.savedLoginDetails() else {
            throw BaseError(
                context: .system,
                message: "Offline login failed: unable to retrieve realm data.",
                logger: logger
            )
        }
        try await storage.markUserAsLoggedIn()
        try await storage.onLogin()
        self.data = storedLoginData // indicate to appFC to present Home Screen in TabBar
    }
}
