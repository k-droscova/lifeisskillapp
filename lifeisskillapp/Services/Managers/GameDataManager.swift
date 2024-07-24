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
    private var checkSumData: CheckSumData? {
        get { userDefaultsStorage.checkSumData }
        set { userDefaultsStorage.checkSumData = newValue }
    }
    
    // MARK: - Public Properties
    
    /*
     TODO: need to resolve whether it is necessary to be declared public or can be set during init (which class will be responsible for onUpdate)
     Now it can be set from anywhere, needs to be handled with caution.
     */
    weak var delegate: GameDataManagerFlowDelegate?
    
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
                logger.log(message: "FETCHED CHECK SUM: \(String(describing: checkSum)) EQUALS OLD: \(String(describing: checkSumData))")
                return
            }
            // else update
            try await updateData(newCheckSum: checkSum)
        }
    }
    
    private func fetchNewCheckSumData() async throws -> CheckSumData {
        do {
            // Start calls on different threads
            async let userPointsResponse = checkSumAPI.getUserPoints(baseURL: APIUrl.baseURL)
            async let rankResponse = checkSumAPI.getRank(baseURL: APIUrl.baseURL)
            async let pointsPatchResponse = checkSumAPI.getPoints(baseURL: APIUrl.baseURL)
            async let messagePatchResponse = checkSumAPI.getMessages(baseURL: APIUrl.baseURL)
            async let eventsPatchResponse = checkSumAPI.getEvents(baseURL: APIUrl.baseURL)
            
            // Initialize and return CheckSumData with await (waits for async thread results)
            return try await CheckSumData(
                userPoints: userPointsResponse.data.pointsProtect,
                rank: rankResponse.data.rankProtect,
                messages: messagePatchResponse.data.msgProtect,
                events: eventsPatchResponse.data.eventsProtect,
                points: pointsPatchResponse.data.pointsProtect
            )
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
            checkSumData = CheckSumData(userPoints: "", rank: "", messages: "", events: "", points: "")
            userDefaultsStorage.commitTransaction()
            await fetchAllNewData()
            return
        }
        /*
         If there is data saved, we will dispatch different threads to handle different data.
         The async let binding allows the fetchNewUserPoints() function to run concurrently with the other fetch functions. This should dramatically speed up the process of fetching data, especially if there have been changes in Generic Points which have a lot of data.
         However, the fetch is performed only if the current checksum for that data is different than new checksum.
         This ensures only the necessary data is fetched and updated.
         */
        async let userPoints: Void? = (currentData.userPoints != newCheckSum.userPoints) ? fetchNewUserPoints() : nil
        async let events: Void? = (currentData.events != newCheckSum.events) ? fetchNewUserEvents() : nil
        async let messages: Void? = (currentData.messages != newCheckSum.messages) ? fetchNewUserMessages() : nil
        async let rank: Void? = (currentData.rank != newCheckSum.rank) ? fetchNewUserRank() : nil
        async let points: Void? = (currentData.points != newCheckSum.points) ? fetchNewPoints() : nil
        
        // Await all results
        await userPoints
        await events
        await messages
        await rank
        await points
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
        // Run this concurrently on different threads
        async let userPoints: () = fetchNewUserPoints()
        async let events: () = fetchNewUserEvents()
        async let rank: () = fetchNewUserRank()
        async let messages: () = fetchNewUserMessages()
        async let points: () = fetchNewPoints()
        
        // Await all results
        await userPoints
        await events
        await messages
        await rank
        await points
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
