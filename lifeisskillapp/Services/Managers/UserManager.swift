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
    func userNotActivated()
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
    var loggedInUser: LoggedInUser? { get }
    
    func initializeAppId() async throws
    // login/logout
    func login(credentials: LoginCredentials) async throws
    func logout()
    func forceLogout()
    func offlineLogout()
    // password renewal
    func requestPinForPasswordRenewal(username: String) async throws -> ForgotPasswordData
    func validateNewPassword(credentials: ForgotPasswordCredentials) async throws -> Bool
    // registration
    func checkUsernameAvailability(_ username: String) async throws -> Bool
    func checkEmailAvailability(_ email: String) async throws -> Bool
    func registerUser(credentials: NewRegistrationCredentials) async throws
    func completeUserRegistration(credentials: FullRegistrationCredentials) async throws -> Bool
    func signature() async -> String?
}

final class UserManager: BaseClass, UserManaging {
    typealias Dependencies = HasNetwork & HasAPIDependencies & HasLoggerServicing & HasUserDefaultsStorage & HasUserDataManagers & HasRepositoryContainer & HasPersistentUserDataStoraging & HasNetworkMonitor & HasKeychainStorage & HasGameDataManager & HasLocationManager
    
    // MARK: - Private Properties
    
    private let logger: LoggerServicing
    private var userDefaultsStorage: UserDefaultsStoraging
    private var storage: PersistentUserDataStoraging
    private let registerAppAPI: RegisterAppAPIServicing
    private let registerUserAPI: RegisterUserAPIServicing
    private let loginAPI: LoginAPIServicing
    private let forgotPasswordAPI: ForgotPasswordAPIServicing
    private let networkMonitor: NetworkMonitoring
    private let locationManager: LocationManaging
    private let keychainStorage: KeychainStoraging
    private let gameDataManager: GameDataManaging
    
    private var data: LoginUserData?
    private var isOnline: Bool { networkMonitor.onlineStatus }
    
    
    // MARK: - Public Properties
    
    weak var delegate: UserManagerFlowDelegate?
    var isLoggedIn: Bool { data != nil }
    var hasAppId: Bool { userDefaultsStorage.appId != nil }
    var loggedInUser: LoggedInUser? { self.data?.user }
    
    // MARK: - Initialization
    
    init(dependencies: Dependencies) {
        self.logger = dependencies.logger
        self.userDefaultsStorage = dependencies.userDefaultsStorage
        self.registerAppAPI = dependencies.registerAppAPI
        self.registerUserAPI = dependencies.registerUserAPI
        self.loginAPI = dependencies.loginAPI
        self.forgotPasswordAPI = dependencies.forgotPasswordAPI
        self.storage = dependencies.storage
        self.networkMonitor = dependencies.networkMonitor
        self.locationManager = dependencies.locationManager
        self.keychainStorage = dependencies.keychainStorage
        self.gameDataManager = dependencies.gameDataManager
        
        super.init()
        self.checkIfUserIsLoggedIn() // check if the user is logged in already
    }
    
    // MARK: - Public interface
    
    func initializeAppId() async throws {
        if let appId = userDefaultsStorage.appId {
            logger.log(message: "App Id \(appId) exists")
            return
        }
        do {
            logger.log(message: "Initializing App Id")
            let response = try await registerAppAPI.registerApp()
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
    
    func checkUsernameAvailability(_ username: String) async throws -> Bool {
        logger.log(message: "Checking availability for: \(username)")
        let response = try await registerUserAPI.checkUsernameAvailability(username)
        return response.data.isAvailable
    }
    
    func checkEmailAvailability(_ email: String) async throws -> Bool {
        logger.log(message: "Checking availability for: \(email)")
        let response = try await registerUserAPI.checkEmailAvailability(email)
        return response.data.isAvailable
    }
    
    func registerUser(credentials: NewRegistrationCredentials) async throws {
        logger.log(message: "Registering User: " + credentials.username)
        do {
            let _ = try await registerUserAPI.registerUser(credentials: credentials, location: locationManager.location)
            return
        } catch {
            throw BaseError(
                context: .system,
                message: "Unable to register",
                logger: logger
            )
        }
    }
    
    func completeUserRegistration(credentials: FullRegistrationCredentials) async throws -> Bool {
        logger.log(message: "Completing registration for User: " + credentials.firstName)
        do {
            let response = try await registerUserAPI.completeRegistration(credentials: credentials)
            guard response.data.completionStatus else {
                throw BaseError(
                    context: .system,
                    message: "Unable to register",
                    logger: logger
                )
            }
            return response.data.needParentActivation
        } catch {
            throw BaseError(
                context: .system,
                message: "Unable to register",
                logger: logger
            )
        }
    }
    
    func requestPinForPasswordRenewal(username: String) async throws -> ForgotPasswordData {
        do {
            logger.log(message: "Requesting Pin for \(username)")
            let response = try await forgotPasswordAPI.fetchPin(username: username)
            return response.data
        } catch {
            throw BaseError(
                context: .api,
                message: "Unable to obtain Pin",
                logger: logger
            )
        }
    }
    
    func validateNewPassword(credentials: ForgotPasswordCredentials) async throws -> Bool {
        do {
            logger.log(message: "New password for User: " + credentials.email)
            let response = try await forgotPasswordAPI.setNewPassword(credentials: credentials)
            return response.data.message
        } catch {
            throw BaseError(
                context: .system,
                message: "Unable to renew password for user: \(credentials.email)",
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
        await gameDataManager.loadData(for: nil) // load all data for the user upon login
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
    
    func signature() async -> String? {
        guard let token = storage.token else {
            logger.log(message: "Unable to fetch signature: Token is nil")
            return nil
        }
        do {
            let response = try await loginAPI.signature(userToken: token)
            return response.data.signature
        } catch {
            logger.log(message: "Unable to fetch signature: \(error.localizedDescription)")
            return nil
        }
    }
    
    // MARK: - Private Helpers
    
    private func checkIfUserIsLoggedIn() {
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
            let response = try await loginAPI.login(credentials: credentials, location: locationManager.location)
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
        } catch let error as BaseError where error.code == ErrorCodes.specificStatusCode(.userNotActivated).code {
            delegate?.userNotActivated()
        } catch {
            // Catch all other errors and throw a generic BaseError
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
