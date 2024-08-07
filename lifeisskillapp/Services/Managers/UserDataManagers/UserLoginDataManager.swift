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
    
    func login(credentials: LoginCredentials) async throws
    func logout()
}

public final class UserLoginDataManager: BaseClass, UserLoginDataManaging {
    typealias Dependencies = HasLoggerServicing & HasLoginAPIService & HasUserDataStorage & HasUserManager & HasRepositoryContainer
    
    // MARK: - Private Properties
    
    private var userDataStorage: UserDataStoraging
    private let logger: LoggerServicing
    private let loginAPI: LoginAPIServicing
    private var realmLoginRepo: any RealmLoginRepositoring
    private var realmUserRepo: any RealmUserRepositoring
    
    // MARK: - Public Properties
    
    /*
     TODO: need to resolve whether it is necessary to be declared public or can be set during init (which class will be responsible for onUpdate) or if delegate is even necessary as it is not called anywhere.
     Now it can be set from anywhere, needs to be handled with caution.
     */
    weak var delegate: UserLoginManagerFlowDelegate?
    
    var data: LoginUserData? {
        get {
            userDataStorage.loginData
        }
        set {
            userDataStorage.loginData = newValue
        }
    }
    
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
        self.userDataStorage = dependencies.userDataStorage
        self.logger = dependencies.logger
        self.loginAPI = dependencies.loginAPI
        self.realmLoginRepo = dependencies.container.realmLoginRepository
        self.realmUserRepo = dependencies.container.realmUserRepository
    }
    
    // MARK: - Public Interface
    
    func login(credentials: LoginCredentials) async throws {
        logger.log(message: "Login User: " + credentials.username)
        do {
            let response = try await loginAPI.login(loginCredentials: credentials, baseURL: APIUrl.baseURL)
            data = response.data
        } catch {
            throw BaseError(
                context: .system,
                message: "Unable to login",
                logger: logger
            )
        }
    }
    
    func logout() {
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
    
}
