//
//  GameDataManager.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 22.07.2024.
//

import Foundation

/// Protocol defining the delegate methods for GameDataManager.
protocol GameDataManagerFlowDelegate: NSObject {
    /// Called when an error occurs during data fetching.
    /// - Parameter error: The error that occurred.
    func onError(_ error: Error)
}

/// Protocol to access an instance of GameDataManager.
protocol HasGameDataManager {
    /// The instance of GameDataManager.
    var gameDataManager: GameDataManaging { get }
}

/// Protocol defining the methods for GameDataManager.
protocol GameDataManaging {
    /// The delegate to handle flow events.
    var delegate: GameDataManagerFlowDelegate? { get set }
    
    /// Fetches new data if necessary.
    /// - Parameter endpoint: The optional endpoint to fetch data for. If nil, fetches data for all endpoints.
    func fetchNewDataIfNeccessary(endpoint: CheckSumAPIService.Endpoint?) async
}

/// Class responsible for managing game data.
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
    
    /// The delegate to handle flow events.
    weak var delegate: GameDataManagerFlowDelegate?
    
    // MARK: - Initialization
    
    /// Initializes a new instance of GameDataManager with the provided dependencies.
    /// - Parameter dependencies: The dependencies required by the GameDataManager.
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
    
    /// Fetches new data if necessary.
    /// - Parameter endpoint: The optional endpoint to fetch data for. If nil, fetches data for all endpoints.
    func fetchNewDataIfNeccessary(endpoint: CheckSumAPIService.Endpoint? = nil) async {
        do {
            if let endpoint = endpoint {
                try await fetchData(for: endpoint)
            } else {
                await fetchAllDataIfNecessary()
            }
        } catch {
            delegate?.onError(error)
        }
    }
    
    // MARK: - Private Helpers
    
    /// Fetches data for all endpoints if necessary.
    private func fetchAllDataIfNecessary() async {
        await withTaskGroup(of: Void.self) { group in
            for endpoint in CheckSumAPIService.Endpoint.allCases {
                group.addTask { [weak self] in
                    do {
                        try await self?.fetchData(for: endpoint)
                    } catch {
                        self?.delegate?.onError(error)
                    }
                }
            }
        }
    }
    
    /// Fetches data for a specific endpoint.
    /// - Parameter endpoint: The endpoint to fetch data for.
    private func fetchData(for endpoint: CheckSumAPIService.Endpoint) async throws {
        logger.log(message: "Fetching data for \(endpoint.path)")
        
        let checkSum = try await fetchNewCheckSumData(for: endpoint)
        
        if shouldFetchData(for: endpoint, newCheckSum: checkSum) {
            switch endpoint {
            case .userpoints:
                await fetchNewUserPoints()
            case .rank:
                await fetchNewUserRank()
            case .events:
                await fetchNewUserEvents()
            case .messages:
                await fetchNewUserMessages()
            case .points:
                await fetchNewPoints()
            }
        }
    }
    
    /// Fetches the new checksum data for a specific endpoint.
    /// - Parameter endpoint: The endpoint to fetch the checksum data for.
    /// - Returns: The new checksum string.
    private func fetchNewCheckSumData(for endpoint: CheckSumAPIService.Endpoint) async throws -> String {
        do {
            switch endpoint {
            case .userpoints:
                let response = try await checkSumAPI.getUserPoints(baseURL: APIUrl.baseURL)
                return response.data.pointsProtect
            case .rank:
                let response = try await checkSumAPI.getRank(baseURL: APIUrl.baseURL)
                return response.data.rankProtect
            case .events:
                let response = try await checkSumAPI.getEvents(baseURL: APIUrl.baseURL)
                return response.data.eventsProtect
            case .messages:
                let response = try await checkSumAPI.getMessages(baseURL: APIUrl.baseURL)
                return response.data.msgProtect
            case .points:
                let response = try await checkSumAPI.getPoints(baseURL: APIUrl.baseURL)
                return response.data.pointsProtect
            }
        } catch {
            throw BaseError(
                context: .system,
                message: "Unable to fetch check sum data for \(endpoint.path)",
                logger: logger
            )
        }
    }
    
    /// Determines whether data should be fetched for a specific endpoint based on the checksum.
    /// - Parameters:
    ///   - endpoint: The endpoint to check.
    ///   - newCheckSum: The new checksum to compare with the stored checksum.
    /// - Returns: A Boolean indicating whether data should be fetched.
    private func shouldFetchData(for endpoint: CheckSumAPIService.Endpoint, newCheckSum: String) -> Bool {
        guard let currentData = checkSumData else {
            checkSumData = CheckSumData(userPoints: "", rank: "", messages: "", events: "", points: "")
            return true
        }
        
        switch endpoint {
        case .userpoints:
            return currentData.userPoints != newCheckSum
        case .rank:
            return currentData.rank != newCheckSum
        case .events:
            return currentData.events != newCheckSum
        case .messages:
            return currentData.messages != newCheckSum
        case .points:
            return currentData.points != newCheckSum
        }
    }
    
    /// Updates the stored checksum for a specific endpoint.
    /// - Parameters:
    ///   - newCheckSum: The new checksum to store.
    ///   - endpoint: The endpoint to update the checksum for.
    private func updateCheckSum(newCheckSum: String, for endpoint: CheckSumAPIService.Endpoint) {
        switch endpoint {
        case .userpoints:
            checkSumData?.userPoints = newCheckSum
        case .rank:
            checkSumData?.rank = newCheckSum
        case .events:
            checkSumData?.events = newCheckSum
        case .messages:
            checkSumData?.messages = newCheckSum
        case .points:
            checkSumData?.points = newCheckSum
        }
    }
    
    /// Fetches new user points data and updates the checksum.
    private func fetchNewUserPoints() async {
        logger.log(message: "Updating user points data")
        do {
            try await userPointManager.fetch()
            guard let newCheckSum = userPointManager.data?.checkSum else {
                logger.log(message: "ERROR: User points checksum is null")
                return
            }
            updateCheckSum(newCheckSum: newCheckSum, for: .userpoints)
        } catch {
            logger.log(message: "ERROR: User points data fetch failed")
        }
    }
    
    /// Fetches new user rank data and updates the checksum.
    private func fetchNewUserRank() async {
        logger.log(message: "Updating user rank data")
        do {
            try await userRankManager.fetch()
            guard let newCheckSum = userRankManager.data?.checkSum else {
                logger.log(message: "ERROR: User rank checksum is null")
                return
            }
            updateCheckSum(newCheckSum: newCheckSum, for: .rank)
        } catch {
            logger.log(message: "ERROR: User rank data fetch failed")
        }
    }
    
    /// Fetches new user messages data and updates the checksum.
    private func fetchNewUserMessages() async {
        logger.log(message: "Updating user messages data")
        // Add implementation for fetching messages data and updating checksum
    }
    
    /// Fetches new user events data and updates the checksum.
    private func fetchNewUserEvents() async {
        logger.log(message: "Updating user events data")
        // Add implementation for fetching events data and updating checksum
    }
    
    /// Fetches new points data and updates the checksum.
    private func fetchNewPoints() async {
        logger.log(message: "Updating points data")
        do {
            try await genericPointManager.fetch()
            guard let newCheckSum = genericPointManager.data?.checkSum else {
                logger.log(message: "ERROR: Points checksum is null")
                return
            }
            updateCheckSum(newCheckSum: newCheckSum, for: .points)
        } catch {
            logger.log(message: "ERROR: Points data fetch failed")
        }
    }
}
