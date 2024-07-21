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
    
    // MARK: USER DATA FETCHED FROM userLoginDataManager
    var userId: String? { get }
    var token: String? { get }
    var userName: String? { get }
    var userMainCategory: String? { get }
    
    // MARK: APP SETUP RELATED PROPERTIES
    var isLoggedIn: Bool { get }
    var hasAppId: Bool { get }
    
    func initializeAppId() async throws
    func login(loginCredentials: LoginCredentials) async throws
    func logout()
    func loadDataAfterLogin() async
}

final class UserManager: UserManaging {
    typealias Dependencies = HasNetwork & HasAPIDependencies & HasLoggerServicing & HasStorage & HasUserDataManagers
    private var logger: LoggerServicing
    private var userDefaultsStorage: UserDefaultsStoraging
    private var registerAppAPI: RegisterAppAPIServicing
    private var checkSumAPI: CheckSumAPIServicing
    private var userCategoryManager: any UserCategoryManaging
    private var userPointManager: any UserPointManaging
    private var genericPointManager: any GenericPointManaging
    private var userRankManager: any UserRankManaging
    private var userLoginDataManager: any UserLoginDataManaging
    
    // MARK: - Initialization
    init(dependencies: Dependencies) {
        self.logger = dependencies.logger
        self.userDefaultsStorage = dependencies.userDefaultsStorage
        self.registerAppAPI = dependencies.registerAppAPI
        self.checkSumAPI = dependencies.checkSumAPI
        self.userCategoryManager = dependencies.userCategoryManager
        self.genericPointManager = dependencies.genericPointManager
        self.userPointManager = dependencies.userPointManager
        self.userRankManager = dependencies.userRankManager
        self.userLoginDataManager = dependencies.userLoginManager
    }
    // MARK: - Public Properties
    
    weak var delegate: UserManagerFlowDelegate?
    
    var token: String? {
        get { userLoginDataManager.token }
    }
    var userId: String? {
        get { userLoginDataManager.userId }
    }
    var userMainCategory: String? {
        get { userLoginDataManager.userMainCategory }
    }
    var userName: String? {
        get { userLoginDataManager.userName }
    }
    
    var isLoggedIn: Bool {
        userLoginDataManager.data != nil
    }
    var hasAppId: Bool {
        userDefaultsStorage.appId != nil
    }
    
    // MARK: - Public Interface
    func login(loginCredentials: LoginCredentials) async throws {
        try await userLoginDataManager.fetch(credentials: loginCredentials)
    }
    
    func logout() {
        logger.log(message: "Logging out")
        userDefaultsStorage.beginTransaction()
        userDefaultsStorage.checkSumData = nil // MARK: This will not be done once we have persitent data storage
        userDefaultsStorage.commitTransaction()
        userLoginDataManager.logout()
        delegate?.onLogout()
    }
    
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
    
    func loadDataAfterLogin() async {
        do {
            try await userCategoryManager.fetch(userToken: token)
            try await checkCheckSumData()
        } catch {
            delegate?.onDataError(error)
        }
    }
    
    // MARK: Private helpers
    private func checkCheckSumData() async throws {
        logger.log(message: "Checking Check Sums")
        do {
            let checkSum = try await fetchNewCheckSumData()
            if checkSum == userDefaultsStorage.checkSumData {
                return
            }
            try await updateData(newCheckSum: checkSum)
        }
    }
    
    private func fetchNewCheckSumData() async throws -> CheckSumData {
        var result = CheckSumData(userPoints: "", rank: "", messages: "", events: "", points: "")
        do {
            let userPointsResponse = try await checkSumAPI.getUserPoints(baseURL: APIUrl.baseURL, userToken: token ?? "")
            result.userPoints = userPointsResponse.data.pointsProtect
            
            let rankResponse = try await checkSumAPI.getRank(baseURL: APIUrl.baseURL, userToken: token ?? "")
            result.rank = rankResponse.data.rankProtect
            
            let pointsPatchResponse = try await checkSumAPI.getPoints(baseURL: APIUrl.baseURL, userToken: token ?? "")
            result.points = pointsPatchResponse.data.pointsProtect
            
            let messagePatchResponse = try await checkSumAPI.getMessages(baseURL: APIUrl.baseURL, userToken: token ?? "")
            result.messages = messagePatchResponse.data.msgProtect
            
            let eventsPatchResponse = try await checkSumAPI.getEvents(baseURL: APIUrl.baseURL, userToken: token ?? "")
            result.events = eventsPatchResponse.data.eventsProtect
            return result
        } catch {
            throw BaseError(
                context: .system,
                message: "Unable to fetch check sum data",
                logger: logger
            )
        }
    }
    
    private func updateData(newCheckSum: CheckSumData) async throws {
        guard let currentData = userDefaultsStorage.checkSumData else {
            userDefaultsStorage.beginTransaction()
            userDefaultsStorage.checkSumData = newCheckSum
            userDefaultsStorage.commitTransaction()
            await fetchAllNewData()
            return
        }
        if (currentData.userPoints != newCheckSum.userPoints) {
            await fetchNewUserPoints()
        }
        if (currentData.events != newCheckSum.events) {
            await fetchNewUserEvents()
        }
        if (currentData.messages != newCheckSum.messages) {
            await fetchNewUserMessages()
        }
        if (currentData.rank != newCheckSum.rank) {
            await fetchNewUserRank()
        }
        if (currentData.points != newCheckSum.points) {
            await fetchNewPoints()
        }
    }
    
    private func updateCheckSum(newCheckSum: String, type: CheckSumData.CheckSumType) {
        userDefaultsStorage.beginTransaction()
        switch type {
        case .userPoints:
            userDefaultsStorage.checkSumData?.userPoints = newCheckSum
        case .rank:
            userDefaultsStorage.checkSumData?.rank = newCheckSum
        case .messages:
            userDefaultsStorage.checkSumData?.messages = newCheckSum
        case .events:
            userDefaultsStorage.checkSumData?.events = newCheckSum
        case .points:
            userDefaultsStorage.checkSumData?.points = newCheckSum
        }
        userDefaultsStorage.commitTransaction()
    }
    
    private func fetchAllNewData() async {
        async let userPoints: () = fetchNewUserPoints()
        async let userEvents: () = fetchNewUserEvents()
        async let userRank: () = fetchNewUserRank()
        async let userMessages: () = fetchNewUserMessages()
        async let newPoints: () = fetchNewPoints()
        
        // Await all concurrently running tasks
        await (userPoints, userEvents, userRank, userMessages, newPoints)
    }
    
    private func fetchNewUserPoints() async {
        logger.log(message: "Updating userPointsData")
        do {
            try await userPointManager.fetch(userToken: token)
            guard let newCheckSumUserPoints = userPointManager.data?.checkSum else {
                throw BaseError(context: .system, code: .general(.missingConfigItem), logger: logger)
            }
            updateCheckSum(newCheckSum: newCheckSumUserPoints, type: CheckSumData.CheckSumType.userPoints)
        } catch {
            
        }
    }
    
    private func fetchNewUserRank() async {
        logger.log(message: "Updating user rank")
        do {
            try await userRankManager.fetch(userToken: token)
            guard let newCheckSum = userRankManager.data?.checkSum else {
                throw BaseError(context: .system, code: .general(.missingConfigItem), logger: logger)
            }
            updateCheckSum(newCheckSum: newCheckSum, type: CheckSumData.CheckSumType.rank)
        } catch {
            
        }
    }
    
    private func fetchNewUserMessages() async {
        logger.log(message: "Updating user messages")
    }
    
    private func fetchNewUserEvents() async {
        logger.log(message: "Updating user events")
    }
    
    private func fetchNewPoints() async {
        logger.log(message: "Updating generic points")
        do {
            try await genericPointManager.fetch(userToken: token)
            guard let newCheckSum = genericPointManager.data?.checkSum else {
                throw BaseError(context: .system, code: .general(.missingConfigItem), logger: logger)
            }
            updateCheckSum(newCheckSum: newCheckSum, type: CheckSumData.CheckSumType.points)
        } catch {
            
        }
    }
}


