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
    
    // MARK: APP SETUP RELATED PROPERTIES
    
    var isLoggedIn: Bool { get }
    var hasAppId: Bool { get }
    
    func initializeAppId() async throws
    func login(loginCredentials: LoginCredentials) async throws
    func logout()
}

final class UserManager: BaseClass, UserManaging {
    typealias Dependencies = HasNetwork & HasAPIDependencies & HasLoggerServicing & HasUserDefaultsStorage & HasUserDataManagers
    
    // MARK: - Private Properties
    
    private let logger: LoggerServicing
    private var userDefaultsStorage: UserDefaultsStoraging
    private let registerAppAPI: RegisterAppAPIServicing
    private let userLoginDataManager: any UserLoginDataManaging
    // TODO: CAN BE DELETED once we have persitent data storage
    private var checkSumData: CheckSumData? {
        get { userDefaultsStorage.checkSumData }
        set { userDefaultsStorage.checkSumData = newValue }
    }
    
    // MARK: - Public Properties
    
    weak var delegate: UserManagerFlowDelegate?
    
    var isLoggedIn: Bool {
        userLoginDataManager.data != nil
    }
    var hasAppId: Bool {
        userDefaultsStorage.appId != nil
    }
    
    // MARK: - Initialization
    
    init(dependencies: Dependencies) {
        self.logger = dependencies.logger
        self.userDefaultsStorage = dependencies.userDefaultsStorage
        self.registerAppAPI = dependencies.registerAppAPI
        self.userLoginDataManager = dependencies.userLoginManager
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
            userDefaultsStorage.beginTransaction()
            userDefaultsStorage.appId = responseAppId
            userDefaultsStorage.commitTransaction()
        } catch {
            throw BaseError(
                context: .system,
                message: "Unable to obtain App Id",
                logger: logger
            )
        }
    }
    
    // MARK: - Public Interface
    func login(loginCredentials: LoginCredentials) async throws {
        try await userLoginDataManager.login(credentials: loginCredentials)
    }
    
    func logout() {
        logger.log(message: "Logging out")
        userDefaultsStorage.beginTransaction()
        userDefaultsStorage.checkSumData = nil // MARK: This will not be done once we have persitent data storage
        userDefaultsStorage.commitTransaction()
        userLoginDataManager.logout()
        delegate?.onLogout()
    }
}
