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
    func onInvalidToken()
    func storedScannedPointsFailedToSend()
}

protocol HasGameDataManager {
    var gameDataManager: GameDataManaging { get }
}

enum DataType: CaseIterable {
    case userPoints, categories, ranks, messages, events, genericPoints
    var checkSumApiEndpoint: CheckSumAPIService.Endpoint? {
        switch self {
        case .userPoints:
                .userpoints
        case .ranks:
                .rank
        case .messages:
                .messages
        case .events:
                .events
        case .genericPoints:
                .points
        default:
            nil
        }
    }
}

protocol GameDataManaging {
    var delegate: GameDataManagerFlowDelegate? { get set }
    var isVirtualAvailablePublisher: AnyPublisher<Bool, Never> { get }
    func loadData(for dataType: DataType?) async
    func onPointScanned(_ point: ScannedPoint) async
    func processVirtual(location: UserLocation?) async
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
    private let userCategoryManager: any UserCategoryManaging
    private let networkMonitor: NetworkMonitoring
    private var isOnline: Bool
    private var cancellables = Set<AnyCancellable>()
    private var isUserLoggedIn: Bool { storage.isLoggedIn }
    private var closestVirtualPoint: GenericPoint?
    private let isVirtualAvailableSubject = CurrentValueSubject<Bool, Never>(false)
    
    // MARK: - Public Properties
    
    weak var delegate: GameDataManagerFlowDelegate?
    var isVirtualAvailablePublisher: AnyPublisher<Bool, Never> {
        isVirtualAvailableSubject.eraseToAnyPublisher()
    }
    
    // MARK: - Initialization
    
    init(dependencies: Dependencies) {
        self.logger = dependencies.logger
        self.storage = dependencies.storage
        self.checkSumAPI = dependencies.checkSumAPI
        self.genericPointManager = dependencies.genericPointManager
        self.userPointManager = dependencies.userPointManager
        self.userRankManager = dependencies.userRankManager
        self.userCategoryManager = dependencies.userCategoryManager
        self.networkMonitor = dependencies.networkMonitor
        self.isOnline = dependencies.networkMonitor.onlineStatus
        
        super.init()
        self.setupBindings()
    }
    
    // MARK: - deinit
    
    deinit {
        cancellables.forEach { $0.cancel() }
    }
    
    // MARK: - Public Interface
    
    func loadData(for dataType: DataType? = nil) async {
        guard !isOnline else {
            await fetchNewDataIfNecessary(for: dataType)
            return
        }
        guard let dataType else {
            await loadAllDataFromRepository()
            return
        }
        await loadFromRepository(for: dataType)
    }
    
    func onPointScanned(_ point: ScannedPoint) async {
        do {
            try await userPointManager.handleScannedPoint(point)
        } catch let error as BaseError {
            if error.code == ErrorCodes.specificStatusCode(.invalidToken).code {
                delegate?.onInvalidToken()
                return
            }
        } catch {
            delegate?.onError(error)
        }
    }
    
    func processVirtual(location: UserLocation?) async {
        do {
            guard let point = closestVirtualPoint else {
                logger.log(message: "virtual point is nil")
                return
            }
            let scannedPoint = ScannedPoint(
                code: point.id,
                codeSource: .virtual,
                location: location)
            try await userPointManager.handleScannedPoint(scannedPoint)
        } catch let error as BaseError {
            if error.code == ErrorCodes.specificStatusCode(.invalidToken).code {
                delegate?.onInvalidToken()
                return
            }
        } catch {
            delegate?.onError(error)
        }
    }
    
    // MARK: - Private Helpers
    
    private func fetchNewDataIfNecessary(for dataType: DataType? = nil) async {
        do {
            guard let dataType else {
                try await fetchAllDataIfNecessary()
                return
            }
            try await fetchData(for: dataType)
        } catch let error as BaseError {
            if error.code == ErrorCodes.specificStatusCode(.invalidToken).code {
                delegate?.onInvalidToken()
                return
            }
        } catch {
            delegate?.onError(error)
        }
    }
    
    private func loadFromRepository(for dataType: DataType) async {
        switch dataType {
        case .categories:
            await userCategoryManager.loadFromRepository()
        case .userPoints:
            await userPointManager.loadFromRepository()
        case .ranks:
            await userRankManager.loadFromRepository()
        case .genericPoints:
            await genericPointManager.loadFromRepository()
        default:
            logger.log(message: "Loading data for \(dataType) not yet implemented")
        }
    }
    
    private func loadAllDataFromRepository() async {
        await withTaskGroup(of: Void.self) { group in
            for dataType in DataType.allCases {
                group.addTask { [weak self] in
                    await self?.loadFromRepository(for: dataType)
                }
            }
        }
    }
    
    private func fetchAllDataIfNecessary() async throws {
        try await withThrowingTaskGroup(of: Void.self) { group in
            for dataType in DataType.allCases {
                group.addTask { [weak self] in
                    try await self?.fetchData(for: dataType)
                }
            }
            try await group.waitForAll()
        }
    }
    
    private func fetchData(for dataType: DataType) async throws {
        logger.log(message: "Fetching data for \(dataType)")
        guard let endpoint = dataType.checkSumApiEndpoint else {
            try await fetchNewUserCategories()
            return
        }
        let checkSum = try await fetchNewCheckSumData(for: endpoint)
        if try await shouldFetchData(for: endpoint, newCheckSum: checkSum) {
            switch endpoint {
            case .userpoints:
                try await fetchNewUserPoints()
            case .rank:
                try await fetchNewUserRank()
            case .events:
                try await fetchNewUserEvents()
            case .messages:
                try await fetchNewUserMessages()
            case .points:
                try await fetchNewPoints()
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
    
    private func fetchNewUserCategories() async throws {
        try await userCategoryManager.fetch()
    }
    
    private func fetchNewUserPoints() async throws {
        try await userPointManager.fetch()
        guard let newCheckSum = userPointManager.checkSum() else {
            logger.log(message: "ERROR: User points checksum is null")
            return
        }
        try await updateCheckSum(newCheckSum: newCheckSum, for: .userpoints)
    }
    
    private func fetchNewUserRank() async throws {
        try await userRankManager.fetch()
        guard let newCheckSum = userRankManager.checkSum() else {
            logger.log(message: "ERROR: User rank checksum is null")
            return
        }
        try await updateCheckSum(newCheckSum: newCheckSum, for: .rank)
    }
    
    private func fetchNewUserMessages() async throws {
        logger.log(message: "Updating user messages data")
        // Add implementation for fetching messages data and updating checksum
    }
    
    private func fetchNewUserEvents() async throws {
        logger.log(message: "Updating user events data")
        // Add implementation for fetching events data and updating checksum
    }
    
    private func fetchNewPoints() async throws {
        try await genericPointManager.fetch()
        guard let newCheckSum = genericPointManager.checkSum() else {
            logger.log(message: "ERROR: Points checksum is null")
            return
        }
        try await updateCheckSum(newCheckSum: newCheckSum, for: .points)
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
        
        genericPointManager.closestVirtualPointPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] closestPoint in
                self?.closestVirtualPoint = closestPoint
                self?.isVirtualAvailableSubject.send(closestPoint != nil)
            }
            .store(in: &cancellables)
    }
    
    private func handleNetworkStatusChange(isOnline: Bool) {
        Task { [weak self] in
            guard let self = self else { return }
            self.isOnline = isOnline
            if self.storage.isLoggedIn && self.isOnline {
                await self.handleOfflineToOnlineStatusChange()
            }
        }
    }
    
    private func handleOfflineToOnlineStatusChange() async {
        do {
            try await userPointManager.handleAllStoredScannedPoints()
            await self.fetchNewDataIfNecessary()
        } catch let error as BaseError {
            if error.code == ErrorCodes.specificStatusCode(.invalidToken).code {
                delegate?.onInvalidToken()
                return
            }
            delegate?.storedScannedPointsFailedToSend()
        } catch {
            delegate?.storedScannedPointsFailedToSend()
        }
    }
}
