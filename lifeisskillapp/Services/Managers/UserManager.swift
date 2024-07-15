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
    var credentials: LoginCredentials? { get set }
    var checkSumData: CheckSumData? { get set }
    
    var isLoggedIn: Bool { get }
    var hasAppId: Bool { get }
    
    func initializeAppId() async throws
    func checkCheckSumData() async throws
    func login(loginCredentials: LoginCredentials) async throws
    func logout()
    
}


final class UserManager: UserManaging {
    typealias Dependencies = HasNetwork & HasAPIDependencies & HasLoggerServicing & HasUserDefaultsStorage
    private var dependencies: Dependencies
    // MARK: - Initialization
    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }
    // MARK: - Public Properties
    
    weak var delegate: UserManagerFlowDelegate?
    
    var appId: String? {
        get { self.dependencies.userDefaultsStorage.appId }
        set { self.dependencies.userDefaultsStorage.appId = newValue }
    }
    
    var token: String? {
        get { self.dependencies.userDefaultsStorage.token }
        set { self.dependencies.userDefaultsStorage.token = newValue }
    }
    
    var credentials: LoginCredentials? {
        get { self.dependencies.userDefaultsStorage.credentials }
        set { self.dependencies.userDefaultsStorage.credentials = newValue }
    }
    
    var checkSumData: CheckSumData? {
        get { self.dependencies.userDefaultsStorage.checkSumData }
        set { self.dependencies.userDefaultsStorage.checkSumData = newValue }
    }
    
    var isLoggedIn: Bool {
        return self.dependencies.userDefaultsStorage.credentials != nil
    }
    var hasAppId: Bool {
        return self.dependencies.userDefaultsStorage.appId != nil
    }
    
    // MARK: - Public Interface
    func login(loginCredentials: LoginCredentials) async throws {
        dependencies.logger.log(message: "Login User: " + loginCredentials.username)
        do {
            let response = try await dependencies.loginAPI.login(loginCredentials: loginCredentials, baseURL: APIUrl.baseURL)
            let responseToken = response.data.token
            dependencies.userDefaultsStorage.beginTransaction()
            credentials = loginCredentials
            token = responseToken
            dependencies.userDefaultsStorage.commitTransaction()
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
        dependencies.logger.log(message: "Logging out")
        dependencies.userDefaultsStorage.beginTransaction()
        credentials = nil
        token = nil
        checkSumData = nil
        dependencies.userDefaultsStorage.commitTransaction()
        delegate?.onLogout()
    }
    
    func initializeAppId() async throws {
        dependencies.logger.log(message: "Initializing App Id")
        if let appId = appId {
            dependencies.logger.log(message: "App Id \(appId) exists")
            return
        }
        do {
            let response = try await dependencies.registerAppAPI.registerApp(baseURL: APIUrl.baseURL)
            let responseAppId = response.data.appId
            dependencies.userDefaultsStorage.beginTransaction()
            appId = responseAppId
            dependencies.userDefaultsStorage.commitTransaction()
        } catch {
            throw BaseError(
                context: .system,
                message: "Unable to obtain App Id",
                logger: dependencies.logger
            )
        }
    }
    
    func checkCheckSumData() async throws {
        dependencies.logger.log(message: "Checking Check Sums")
        do {
            let checkSum = try await fetchNewCheckSumData()
            if checkSum == checkSumData {
                return
            }
            dependencies.userDefaultsStorage.beginTransaction()
            checkSumData = checkSum
            dependencies.userDefaultsStorage.commitTransaction()
            try await updateData()
        }
    }
    
    private func fetchNewCheckSumData() async throws -> CheckSumData {
        var result = CheckSumData(userPoints: "", rank: "", messages: "", events: "", points: "")
        do {
            let userPointsResponse = try await dependencies.checkSumAPI.getUserPoints(baseURL: APIUrl.baseURL)
            result.userPoints = userPointsResponse.data.pointsProtect
            
            let rankResponse = try await dependencies.checkSumAPI.getRank(baseURL: APIUrl.baseURL)
            result.rank = rankResponse.data.rankProtect
            
            let pointsPatchResponse = try await dependencies.checkSumAPI.getPoints(baseURL: APIUrl.baseURL)
            result.points = pointsPatchResponse.data.pointsProtect
            
            let messagePatchResponse = try await dependencies.checkSumAPI.getMessages(baseURL: APIUrl.baseURL)
            result.messages = messagePatchResponse.data.msgProtect
            
            let eventsPatchResponse = try await dependencies.checkSumAPI.getEvents(baseURL: APIUrl.baseURL)
            result.events = eventsPatchResponse.data.eventsProtect
            
            return result
        } catch {
            throw BaseError(
                context: .system,
                message: "Unable to fetch check sum data",
                logger: dependencies.logger
            )
        }
    }
    
    private func updateData() async throws {
        dependencies.logger.log(message: "Updating data")
    }
    
}


