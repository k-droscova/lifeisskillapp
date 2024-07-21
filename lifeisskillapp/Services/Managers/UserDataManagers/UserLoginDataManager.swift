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

protocol UserLoginDataManaging: UserDataManaging where DataType == LoggedInUser, DataContainer == LoginUserData {
    var delegate: UserLoginManagerFlowDelegate? { get set }
    var userId: String? { get }
    var token: String? { get }
    var userName: String? { get }
    var userMainCategory: String? { get }
    func logout()
}

public final class UserLoginDataManager: UserLoginDataManaging {
    
    typealias Dependencies = HasLoggerServicing & HasLoginAPIService & HasUserDataStorage & HasUserManager
    private var userDataStorage: UserDataStoraging
    private var logger: LoggerServicing
    private var loginAPI: LoginAPIServicing

    // MARK: - Initialization
    init(dependencies: Dependencies) {
        self.userDataStorage = dependencies.userDataStorage
        self.logger = dependencies.logger
        self.loginAPI = dependencies.loginAPI
    }
    
    // MARK: - Public Properties
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
    
    // MARK: - Public Interface
    func fetch(credentials: LoginCredentials?, userToken: String? = "") async throws {
        guard let credentials else {
            throw BaseError(
                context: .system,
                message: "Attempting login with empty credentials",
                logger: logger
            )
        }
        logger.log(message: "Login User: " + credentials.username)
        do {
            let response = try await loginAPI.login(loginCredentials: credentials, baseURL: APIUrl.baseURL)
            userDataStorage.beginTransaction()
            data = response.data
            userDataStorage.commitTransaction()
        } catch {
            throw BaseError(
                context: .system,
                message: "Unable to login",
                logger: logger
            )
        }
    }
    
    func logout() {
        userDataStorage.beginTransaction()
        data = nil
        userDataStorage.commitTransaction()
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
