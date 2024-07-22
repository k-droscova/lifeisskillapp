//
//  UserManager.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 01.07.2024.
//

import Foundation

protocol UserManagerFlowDelegate: NSObject {
    func onLogout()
    func onDataError(_ error: Error)
}

protocol HasUserManager {
    var userManager: UserManaging { get }
}

protocol UserManaging {
    var delegate: UserManagerFlowDelegate? { get set }
    var appId: String? { get }
    var token: String? { get }
    var credentials: LoginCredentials? { get set }
    
    var isLoggedIn: Bool { get }
    var hasAppId: Bool { get }
    
    func initializeAppId() async throws
    func login(loginCredentials: LoginCredentials) async throws
    func logout()
}

final class UserManager: BaseClass, UserManaging {
    typealias Dependencies = HasNetwork & HasAPIDependencies & HasLoggerServicing & HasUserDefaultsStorage & HasUserDataManagers
    private var logger: LoggerServicing
    private var userDefaultsStorage: UserDefaultsStoraging
    private var loginAPI: LoginAPIServicing
    private var registerAppAPI: RegisterAppAPIServicing
    
    // MARK: - Public Properties
    
    weak var delegate: UserManagerFlowDelegate?
    
    var appId: String? {
        get { userDefaultsStorage.appId }
        set { userDefaultsStorage.appId = newValue }
    }
    
    var token: String? {
        get { userDefaultsStorage.token }
        set { userDefaultsStorage.token = newValue }
    }
    
    var credentials: LoginCredentials? {
        get { userDefaultsStorage.credentials }
        set { userDefaultsStorage.credentials = newValue }
    }
    
    var isLoggedIn: Bool {
        userDefaultsStorage.credentials != nil
    }
    var hasAppId: Bool {
        userDefaultsStorage.appId != nil
    }
    
    // MARK: - Private Properties
    // TODO: CAN BE DELETED once we have persitent data storage
    private var checkSumData: CheckSumData? {
        get { userDefaultsStorage.checkSumData }
        set { userDefaultsStorage.checkSumData = newValue }
    }
    
    // MARK: - Initialization
    init(dependencies: Dependencies) {
        self.logger = dependencies.logger
        self.userDefaultsStorage = dependencies.userDefaultsStorage
        self.loginAPI = dependencies.loginAPI
        self.registerAppAPI = dependencies.registerAppAPI
    }
    
    // MARK: - Public Interface
    func login(loginCredentials: LoginCredentials) async throws {
        logger.log(message: "Login User: " + loginCredentials.username)
        do {
            let response = try await loginAPI.login(loginCredentials: loginCredentials, baseURL: APIUrl.baseURL)
            let responseToken = response.data.token
            userDefaultsStorage.beginTransaction()
            credentials = loginCredentials
            token = responseToken
            userDefaultsStorage.commitTransaction()
        } catch {
            throw BaseError(
                context: .system,
                message: "Unable to login",
                logger: logger
            )
        }
    }
    
    func logout() {
        logger.log(message: "Logging out")
        userDefaultsStorage.beginTransaction()
        credentials = nil
        token = nil
        checkSumData = nil // MARK: This will not be done once we have persitent data storage
        userDefaultsStorage.commitTransaction()
        delegate?.onLogout()
    }
    
    func initializeAppId() async throws {
        logger.log(message: "Initializing App Id")
        if let appId = appId {
            logger.log(message: "App Id \(appId) exists")
            return
        }
        do {
            let response = try await registerAppAPI.registerApp(baseURL: APIUrl.baseURL)
            let responseAppId = response.data.appId
            userDefaultsStorage.beginTransaction()
            appId = responseAppId
            userDefaultsStorage.commitTransaction()
        } catch {
            throw BaseError(
                context: .system,
                message: "Unable to obtain App Id",
                logger: logger
            )
        }
    }
}


