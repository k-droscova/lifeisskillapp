//
//  GameDataManager.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 22.07.2024.
//

import Foundation

protocol GameDataManagerFlowDelegate: NSObject {
    func onError(_ error: Error)
}

protocol HasGameDataManager {
    var gameDataManager: GameDataManaging { get }
}

protocol GameDataManaging {
    var delegate: GameDataManagerFlowDelegate? { get set }
    var checkSumData: CheckSumData? { get set }
    func fetchNewDataIfNeccessary() async
}

public final class GameDataManager: BaseClass, GameDataManaging {
    typealias Dependencies = HasUserDataManagers & HasCheckSumAPIService & HasLoggers & HasUserDefaultsStorage
    
    // MARK: - Private Properties
    
    private let logger: LoggerServicing
    private var userDefaultsStorage: UserDefaultsStoraging
    private let checkSumAPI: CheckSumAPIServicing
    private let userCategoryManager: any UserCategoryManaging
    private let userPointManager: any UserPointManaging
    private let genericPointManager: any GenericPointManaging
    private let userRankManager: any UserRankManaging
    
    // MARK: - Public Properties
    
    /*
     TODO: need to resolve whether it is necessary to be declared public or can be set during init (which class will be responsible for onUpdate)
     Now it can be set from anywhere, needs to be handled with caution.
     */
    weak var delegate: GameDataManagerFlowDelegate?
    
    var checkSumData: CheckSumData? {
        get { userDefaultsStorage.checkSumData }
        set { userDefaultsStorage.checkSumData = newValue }
    }
    
    // MARK: - Initialization
    
    init(dependencies: Dependencies) {
        self.logger = dependencies.logger
        self.userDefaultsStorage = dependencies.userDefaultsStorage
        self.checkSumAPI = dependencies.checkSumAPI
        self.userCategoryManager = dependencies.userCategoryManager
        self.genericPointManager = dependencies.genericPointManager
        self.userPointManager = dependencies.userPointManager
        self.userRankManager = dependencies.userRankManager
    }
    
    // MARK: - Public Interface
    
    func fetchNewDataIfNeccessary() async {
        do {
            try await userCategoryManager.fetch()
            try await checkCheckSumData()
        } catch {
            delegate?.onError(error)
        }
    }

    // MARK: - Private Helpers
    
    private func checkCheckSumData() async throws {
        logger.log(message: "Checking Check Sums")
        do {
            // get new check sums for data from the server
            let checkSum = try await fetchNewCheckSumData()
            // if no data have changed since last data fetch then do nothing
            if checkSum == checkSumData {
                return
            }
            // else update
            try await updateData(newCheckSum: checkSum)
        }
    }
    
    private func fetchNewCheckSumData() async throws -> CheckSumData {
        var result = CheckSumData(userPoints: "", rank: "", messages: "", events: "", points: "")
        do {
            let userPointsResponse = try await checkSumAPI.getUserPoints(baseURL: APIUrl.baseURL)
            result.userPoints = userPointsResponse.data.pointsProtect
            
            let rankResponse = try await checkSumAPI.getRank(baseURL: APIUrl.baseURL)
            result.rank = rankResponse.data.rankProtect
            
            let pointsPatchResponse = try await checkSumAPI.getPoints(baseURL: APIUrl.baseURL)
            result.points = pointsPatchResponse.data.pointsProtect
            
            let messagePatchResponse = try await checkSumAPI.getMessages(baseURL: APIUrl.baseURL)
            result.messages = messagePatchResponse.data.msgProtect
            
            let eventsPatchResponse = try await checkSumAPI.getEvents(baseURL: APIUrl.baseURL)
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
        // if no data have been saved until now then fetch all user data
        guard let currentData = checkSumData else {
            userDefaultsStorage.beginTransaction()
            checkSumData = newCheckSum
            userDefaultsStorage.commitTransaction()
            await fetchAllNewData()
            return
        }
        // else fetch just the data that has been updated
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
            checkSumData?.userPoints = newCheckSum
        case .rank:
            checkSumData?.rank = newCheckSum
        case .messages:
            checkSumData?.messages = newCheckSum
        case .events:
            checkSumData?.events = newCheckSum
        case .points:
            checkSumData?.points = newCheckSum
        }
        userDefaultsStorage.commitTransaction()
    }
    
    private func fetchAllNewData() async {
        await fetchNewUserPoints()
        await fetchNewUserEvents()
        await fetchNewUserRank()
        await fetchNewUserMessages()
        await fetchNewPoints()
    }
    
    private func fetchNewUserPoints() async {
        logger.log(message: "Updating userPointsData")
        do {
            try await userPointManager.fetch()
            guard let newCheckSumUserPoints = userPointManager.data?.checkSum else {
                throw BaseError(context: .system, code: .general(.missingConfigItem), logger: logger)
            }
            updateCheckSum(newCheckSum: newCheckSumUserPoints, type: CheckSumData.CheckSumType.userPoints)
        } catch {
            logger.log(message: "fetch New User Points threw error")
        }
    }
    
    private func fetchNewUserRank() async {
        logger.log(message: "Updating user rank")
        do {
            try await userRankManager.fetch()
            guard let newCheckSumUserRank = userRankManager.data?.checkSum else {
                throw BaseError(context: .system, code: .general(.missingConfigItem), logger: logger)
            }
            updateCheckSum(newCheckSum: newCheckSumUserRank, type: CheckSumData.CheckSumType.rank)
        } catch {
            logger.log(message: "fetch New User Rank threw error")
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
            try await genericPointManager.fetch()
            guard let newCheckSum = genericPointManager.data?.checkSum else {
                throw BaseError(context: .system, code: .general(.missingConfigItem), logger: logger)
            }
            updateCheckSum(newCheckSum: newCheckSum, type: CheckSumData.CheckSumType.points)
        } catch {
            logger.log(message: "fetch New Generic Points threw error")
        }
    }
}
