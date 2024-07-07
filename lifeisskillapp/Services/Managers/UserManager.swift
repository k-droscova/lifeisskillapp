//
//  UserManager.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 01.07.2024.
//

import Foundation

protocol UserManagerFlowDelegate: NSObject {
    func onLogin()
    func onLogout()
}

protocol HasUserManager {
    var userManager: UserManaging { get }
}

protocol UserManaging {
    var delegate: UserManagerFlowDelegate? { get set }
    var appId: String? { get }
    var token: String? { get }

    var isLoggedIn: Bool { get }
    var hasAppId: Bool { get }
    
    func initializeAppId() async throws
    func login(loginCredentials: LoginCredentials) async throws
    func logout()
}


final class UserManager: UserManaging {
    typealias Dependencies = HasNetwork & HasAPIDependencies & HasLoggerServicing
    private let dependencies: Dependencies
    // MARK: - Initialization
    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }
    // MARK: - Public Properties
    
    weak var delegate: UserManagerFlowDelegate?
    
    var appId: String? {
        get { UserDefaults.standard.appId }
        set { UserDefaults.standard.set(newValue, forKey: "appId") }
    }
    
    var token: String? {
        get { UserDefaults.standard.token }
        set { UserDefaults.standard.set(newValue, forKey: "token") }
    }
    
    var isLoggedIn: Bool {
        return UserDefaults.standard.credentials != nil
    }
    var hasAppId: Bool {
        return !UserDefaults.standard.firstOpened
    }
    
    // MARK: - Public Interface
    func login(loginCredentials: LoginCredentials) async throws {
        dependencies.logger.log(message: "Login User: " + loginCredentials.username)
        do {
            let response = try await dependencies.loginAPI.login(loginCredentials: loginCredentials, baseURL: APIUrl.baseNewURL)
            let token = response.data.token
            UserDefaults.standard.credentials = loginCredentials
            print("User token obtained and saved: \(response.data.token)")
            delegate?.onLogin()
        } catch {
            throw BaseError(
                context: .system,
                message: "Unable to login",
                logger: dependencies.logger
            )
        }
    }
    func logout() {
        UserDefaults.standard.removeObject(forKey: "credentials")
        delegate?.onLogout()
    }
    
    func initializeAppId() async throws {
        dependencies.logger.log(message: "Initializing App Id")
        if let appId = appId {
            print("App ID already exists: \(appId)")
            return
        }
        do {
            let response = try await dependencies.registerAppAPI.registerApp(baseURL: APIUrl.baseOldURL)
            appId = response.data.appId
            print("App ID obtained and saved: \(response.data.appId)")
        } catch {
            throw BaseError(
                context: .system,
                message: "Unable to obtain App Id",
                logger: dependencies.logger
            )
        }
    }
}


