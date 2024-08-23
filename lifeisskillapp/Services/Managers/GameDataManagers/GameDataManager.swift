//
//  GameDataManager.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 22.07.2024.
//

import Foundation
import Combine

protocol GameDataManagerFlowDelegate: NSObject {
    func onError(_ error: Error)
}

protocol HasGameDataManager {
    var gameDataManager: GameDataManaging { get }
}

protocol GameDataManaging {
    var delegate: GameDataManagerFlowDelegate? { get set }
    func loadData(for endpoint: CheckSumAPIService.Endpoint?) async
    func fetchNewDataIfNecessary(endpoint: CheckSumAPIService.Endpoint?) async
}

public final class GameDataManager: BaseClass, GameDataManaging {
    typealias Dependencies = HasUserDataManagers & HasCheckSumAPIService & HasLoggers & HasPersistentUserDataStoraging & HasUserManager & HasNetworkMonitor
    
    // MARK: - Private Properties
    
    private let logger: LoggerServicing
    private var storage: PersistentUserDataStoraging
    private let checkSumAPI: CheckSumAPIServicing
    private let userPointManager: any UserPointManaging
    private let genericPointManager: any GenericPointManaging
    private let userRankManager: any UserRankManaging
    private let userManager: UserManaging
    private let networkMonitor: NetworkMonitoring
    private var isOnline: Bool
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Public Properties
    
    weak var delegate: GameDataManagerFlowDelegate?
    
    // MARK: - Initialization
    
    init(dependencies: Dependencies) {
        self.logger = dependencies.logger
        self.storage = dependencies.storage
        self.checkSumAPI = dependencies.checkSumAPI
        self.genericPointManager = dependencies.genericPointManager
        self.userPointManager = dependencies.userPointManager
        self.userRankManager = dependencies.userRankManager
        self.userManager = dependencies.userManager
        self.networkMonitor = dependencies.networkMonitor
        self.isOnline = dependencies.networkMonitor.onlineStatus
        
        super.init()
        self.setupBindings()
        self.load() // load checksums
    }
    
    // MARK: - deinit
    
    deinit {
        cancellables.forEach { $0.cancel() }
    }
    
    // MARK: - Public Interface
    
    func loadData(for endpoint: CheckSumAPIService.Endpoint?) async {
        guard !isOnline else {
            await fetchNewDataIfNecessary(endpoint: endpoint)
            return
        }
        if let endpoint = endpoint {
            await loadFromRepository(for: endpoint)
        } else {
            await self.loadAllDataFromRepository()
        }
    }
    
    func fetchNewDataIfNecessary(endpoint: CheckSumAPIService.Endpoint? = nil) async {
        do {
            if let endpoint = endpoint {
                try await fetchData(for: endpoint)
            } else {
                try await fetchAllDataIfNecessary()
            }
        } catch let error as BaseError {
            if error.code == ErrorCodes.specificStatusCode(.invalidToken).code {
                userManager.forceLogout()
                return
            }
        } catch {
            delegate?.onError(error)
        }
    }
    
    // MARK: - Private Helpers
    
    private func loadFromRepository(for endpoint: CheckSumAPIService.Endpoint) async {
        switch endpoint {
        case .userpoints:
            await userPointManager.loadFromRepository()
        case .rank:
            await userRankManager.loadFromRepository()
        case .points:
            await userPointManager.loadFromRepository()
        default:
            logger.log(message: "Loading events or messages not yet implemented")
        }
    }
    
    private func loadAllDataFromRepository() async {
        await withTaskGroup(of: Void.self) { group in
            for endpoint in CheckSumAPIService.Endpoint.allCases {
                group.addTask { [weak self] in
                    await self?.loadFromRepository(for: endpoint)
                }
            }
        }
    }
    
    private func fetchAllDataIfNecessary() async throws {
        try await withThrowingTaskGroup(of: Void.self) { group in
            for endpoint in CheckSumAPIService.Endpoint.allCases {
                group.addTask { [weak self] in
                    try await self?.fetchData(for: endpoint)
                }
            }
            try await group.waitForAll()
        }
    }
    
    private func fetchData(for endpoint: CheckSumAPIService.Endpoint) async throws {
        logger.log(message: "Fetching data for \(endpoint.path)")
        
        let checkSum = try await fetchNewCheckSumData(for: endpoint)
        
        if try await shouldFetchData(for: endpoint, newCheckSum: checkSum) {
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
    
    private func fetchNewCheckSumData(for endpoint: CheckSumAPIService.Endpoint) async throws -> String {
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
    }
    
    private func shouldFetchData(for endpoint: CheckSumAPIService.Endpoint, newCheckSum: String) async throws -> Bool {
        let currentData = try await storage.checkSumData() ?? CheckSumData(userPoints: "", rank: "", messages: "", events: "", points: "")
        
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
    
    private func updateCheckSum(newCheckSum: String, for endpoint: CheckSumAPIService.Endpoint) async throws {
        var currentData = try await storage.checkSumData() ?? CheckSumData(userPoints: "", rank: "", messages: "", events: "", points: "")
        
        switch endpoint {
        case .userpoints:
            currentData.userPoints = newCheckSum
        case .rank:
            currentData.rank = newCheckSum
        case .events:
            currentData.events = newCheckSum
        case .messages:
            currentData.messages = newCheckSum
        case .points:
            currentData.points = newCheckSum
        }
        
        try await storage.saveCheckSumData(currentData)
    }
    
    private func fetchNewUserPoints() async {
        logger.log(message: "Updating user points data")
        do {
            try await userPointManager.fetch()
            guard let newCheckSum = userPointManager.checkSum() else {
                logger.log(message: "ERROR: User points checksum is null")
                return
            }
            try await updateCheckSum(newCheckSum: newCheckSum, for: .userpoints)
        } catch {
            logger.log(message: "ERROR: User points data fetch failed")
        }
    }
    
    private func fetchNewUserRank() async {
        logger.log(message: "Updating user rank data")
        do {
            try await userRankManager.fetch()
            guard let newCheckSum = userRankManager.checkSum() else {
                logger.log(message: "ERROR: User rank checksum is null")
                return
            }
            try await updateCheckSum(newCheckSum: newCheckSum, for: .rank)
        } catch {
            logger.log(message: "ERROR: User rank data fetch failed")
        }
    }
    
    private func fetchNewUserMessages() async {
        logger.log(message: "Updating user messages data")
        // Add implementation for fetching messages data and updating checksum
    }
    
    private func fetchNewUserEvents() async {
        logger.log(message: "Updating user events data")
        // Add implementation for fetching events data and updating checksum
    }
    
    private func fetchNewPoints() async {
        logger.log(message: "Updating points data")
        do {
            try await genericPointManager.fetch()
            guard let newCheckSum = genericPointManager.checkSum() else {
                logger.log(message: "ERROR: Points checksum is null")
                return
            }
            try await updateCheckSum(newCheckSum: newCheckSum, for: .points)
        } catch {
            logger.log(message: "ERROR: Points data fetch failed")
        }
    }
    
    private func load() {
        Task { [weak self] in
            do {
                try await self?.storage.loadAllDataFromRepositories()
            } catch {
                self?.logger.log(message: error.localizedDescription)
            }
        }
    }
    
    private func setupBindings() {
        networkMonitor.onlineStatusPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isOnline in
                self?.handleNetworkStatusChange(isOnline: isOnline)
            }
            .store(in: &cancellables)
    }
    
    private func handleNetworkStatusChange(isOnline: Bool) {
        Task { [weak self] in
            guard let self = self else { return }
            self.isOnline = isOnline
            if self.userManager.isLoggedIn && self.isOnline {
                self.userPointManager.handleAllStoredScannedPoints()
                await self.fetchNewDataIfNecessary()
            }
        }
    }
}
