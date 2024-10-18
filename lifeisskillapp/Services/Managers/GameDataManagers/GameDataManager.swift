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
    // MARK: - be careful if adding new endpoint, ensure that hasCheckSumEndpoint returns correct value
    case userPoints, categories, ranks, messages, events, genericPoints
    
    var hasCheckSumEndpoint: Bool {
        guard case .categories = self else { return true }
        return false
    }
}

protocol GameDataManaging {
    var delegate: GameDataManagerFlowDelegate? { get set }
    var isVirtualAvailablePublisher: AnyPublisher<Bool, Never> { get }
    func reloadAfterRegistration() async throws
    func loadData(for dataType: DataType) async
    func onPointScanned(_ point: ScannedPoint) async
    func processVirtual(location: UserLocation?) async
    func performOnlineLogin() async throws
    func performOfflineLogin() async throws
}

final class GameDataManager: BaseClass, GameDataManaging {
    typealias Dependencies = HasUserDataManagers & HasCheckSumAPIService & HasLoggers & HasPersistentUserDataStoraging & HasNetworkMonitor & HasUserDefaultsStorage
    
    // MARK: - Private Properties
    
    private let logger: LoggerServicing
    private var storage: PersistentUserDataStoraging
    private let userDefaultsStorage: UserDefaultsStoraging
    private let checkSumAPI: CheckSumAPIServicing
    private let userPointManager: any UserPointManaging
    private let genericPointManager: any GenericPointManaging
    private let userRankManager: any UserRankManaging
    private let userCategoryManager: any UserCategoryManaging
    private let networkMonitor: NetworkMonitoring
    private var isOnline: Bool { networkMonitor.onlineStatus }
    private var cancellables = Set<AnyCancellable>()
    private var isLoggedIn: Bool { userDefaultsStorage.isLoggedIn ?? false }
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
        self.userDefaultsStorage = dependencies.userDefaultsStorage
        self.checkSumAPI = dependencies.checkSumAPI
        self.genericPointManager = dependencies.genericPointManager
        self.userPointManager = dependencies.userPointManager
        self.userRankManager = dependencies.userRankManager
        self.userCategoryManager = dependencies.userCategoryManager
        self.networkMonitor = dependencies.networkMonitor
        
        super.init()
        self.setupBindings()
    }
    
    // MARK: - deinit
    
    deinit {
        cancellables.forEach { $0.cancel() }
    }
    
    // MARK: - Public Interface
    
    /// Perform online login, fetch all data (categories, user points, events, ranks, messages) and save to Realm
    func performOnlineLogin() async throws {
        logger.log(message: "Performing online login, fetching all data...")
        
        do {
            async let categories: () = fetchNewUserCategories()
            async let userPoints: () = fetchNewUserPoints()
            async let userRanks: () = fetchNewUserRank()
            async let userEvents: () = fetchNewUserEvents()
            async let userMessages: () = fetchNewUserMessages()
            async let genericPoints: () = fetchNewData(for: .genericPoints)
            
            try await (categories, userPoints, userRanks, userEvents, userMessages, genericPoints)
            
            logger.log(message: "Successfully fetched and saved all data during online login")
        } catch let error as BaseError {
            if error.code == ErrorCodes.specificStatusCode(.invalidToken).code {
                delegate?.onInvalidToken()
                return
            }
            delegate?.onError(error)
        } catch {
            delegate?.onError(error)
        }
    }
    
    /// Perform offline login, load all data from the repository
    func performOfflineLogin() async throws {
        logger.log(message: "Performing offline login, loading all data from repository...")
        await loadAllDataFromRepository()
        logger.log(message: "Successfully loaded all data during offline login")
    }
    
    /// Fetches new data that is neccessary once user completes registration
    func reloadAfterRegistration() async throws {
        try await fetchNewUserCategories()
    }
    
    /// For loading data for specific ViewModels (Screens)
    /// Handles both online and offline loading
    func loadData(for dataType: DataType) async {
        guard !isOnline else {
            await fetchNewData(for: dataType)
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
            delegate?.onError(error)
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
            delegate?.onError(error)
        } catch {
            delegate?.onError(error)
        }
    }
    
    // MARK: - Private Helpers For Online Fetching
    
    private func fetchNewData(for dataType: DataType) async {
        do {
            try await fetchDataIfNeccessary(for: dataType)
        } catch let error as BaseError {
            if error.code == ErrorCodes.specificStatusCode(.invalidToken).code {
                delegate?.onInvalidToken()
                return
            }
            delegate?.onError(error)
        } catch {
            delegate?.onError(error)
        }
    }
    
    private func fetchDataIfNeccessary(for dataType: DataType) async throws {
        logger.log(message: "Fetching data for \(dataType)")
        guard dataType.hasCheckSumEndpoint else {
            try await fetchNewUserCategories()
            return
        }
        let checkSum = try await fetchNewCheckSumData(for: dataType)
        if try await shouldFetchData(for: dataType, newCheckSum: checkSum) {
            switch dataType {
            case .userPoints:
                try await fetchNewUserPoints()
            case .ranks:
                try await fetchNewUserRank()
            case .events:
                try await fetchNewUserEvents()
            case .messages:
                try await fetchNewUserMessages()
            case .genericPoints:
                try await fetchNewPoints()
            default:
                return
            }
        }
    }
    
    private func fetchNewCheckSumData(for dataType: DataType) async throws -> String {
        switch dataType {
        case .userPoints:
            let response = try await checkSumAPI.userPoints()
            return response.data.pointsProtect
        case .ranks:
            let response = try await checkSumAPI.userRank()
            return response.data.rankProtect
        case .events:
            let response = try await checkSumAPI.userEvents()
            return response.data.eventsProtect
        case .messages:
            let response = try await checkSumAPI.userMessages()
            return response.data.msgProtect
        case .genericPoints:
            let response = try await checkSumAPI.genericPoints()
            return response.data.pointsProtect
        default:
            return "" // should never happen
        }
    }
    
    private func shouldFetchData(for dataType: DataType, newCheckSum: String) async throws -> Bool {
        let currentChecksum = try await storage.checkSumData() ?? CheckSumData(userPoints: "", rank: "", messages: "", events: "", points: "")
        
        switch dataType {
        case .userPoints:
            return currentChecksum.userPoints != newCheckSum
        case .ranks:
            return currentChecksum.rank != newCheckSum
        case .events:
            return currentChecksum.events != newCheckSum
        case .messages:
            return currentChecksum.messages != newCheckSum
        case .genericPoints:
            return currentChecksum.points != newCheckSum
        default:
            return false
        }
    }
    
    private func updateCheckSum(newCheckSum: String, for dataType: DataType) async throws {
        var currentData = try await storage.checkSumData() ?? CheckSumData(userPoints: "", rank: "", messages: "", events: "", points: "")
        
        switch dataType {
        case .userPoints:
            currentData.userPoints = newCheckSum
        case .ranks:
            currentData.rank = newCheckSum
        case .events:
            currentData.events = newCheckSum
        case .messages:
            currentData.messages = newCheckSum
        case .genericPoints:
            currentData.points = newCheckSum
        default:
            return
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
        try await updateCheckSum(newCheckSum: newCheckSum, for: .userPoints)
    }
    
    private func fetchNewUserRank() async throws {
        try await userRankManager.fetch()
        guard let newCheckSum = userRankManager.checkSum() else {
            logger.log(message: "ERROR: User rank checksum is null")
            return
        }
        try await updateCheckSum(newCheckSum: newCheckSum, for: .ranks)
    }
    
    private func fetchNewUserMessages() async throws {
        logger.log(message: "Updating user messages data")
        // Not implemented in current version
    }
    
    private func fetchNewUserEvents() async throws {
        logger.log(message: "Updating user events data")
        // Not implemented in current version
    }
    
    private func fetchNewPoints() async throws {
        try await genericPointManager.fetch()
        guard let newCheckSum = genericPointManager.checkSum() else {
            logger.log(message: "ERROR: Points checksum is null")
            return
        }
        try await updateCheckSum(newCheckSum: newCheckSum, for: .genericPoints)
    }
    
    // MARK: - Private Helpers for Repository Loading
    
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
    
    // MARK: - Private Helpers Miscellaneous
    
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
            if self.isLoggedIn && self.isOnline {
                await self.handleOfflineToOnlineStatusChange()
            }
        }
    }
    
    private func handleOfflineToOnlineStatusChange() async {
        do {
            try await userPointManager.handleAllStoredScannedPoints()
            try await withThrowingTaskGroup(of: Void.self) { group in
                group.addTask { [weak self] in
                    await self?.fetchNewData(for: .userPoints)
                }
                group.addTask { [weak self] in
                    await self?.fetchNewData(for: .ranks)
                }
                try await group.waitForAll()
            }
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
