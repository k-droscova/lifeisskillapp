//
//  UserPointManager.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 16.07.2024.
//

import Foundation
import Combine

protocol HasUserPointManager {
    var userPointManager: any UserPointManaging { get }
}

protocol ScanPointFlowDelegate: NSObject {
    func onScanPointInvalidPoint()
    func onScanPointNoLocation()
    func onScanPointProcessSuccessOnline(_ source: CodeSource)
    func onScanPointProcessSuccessOffline(_ source: CodeSource)
    func onScanPointOnlineProcessError(_ source: CodeSource)
    func onScanPointOfflineProcessError()
}

protocol UserPointManaging: UserDataManaging where DataType == UserPoint, DataContainer == UserPointData {
    var scanningDelegate: ScanPointFlowDelegate? { get set }
    func getPoints(byCategory categoryId: String) -> [UserPoint]
    func getTotalPoints(byCategory categoryId: String) -> Int
    func handleScannedPoint(_ point: ScannedPoint) async throws
    func handleAllStoredScannedPoints() async throws
}

final class UserPointManager: BaseClass, UserPointManaging {
    typealias Dependencies = HasLoggerServicing & HasUserDataAPIService & HasPersistentUserDataStoraging & HasScanningManager & HasNetworkMonitor
    
    // MARK: - Private Properties
    
    private var storage: PersistentUserDataStoraging
    private let logger: LoggerServicing
    private let userDataAPIService: UserDataAPIServicing
    private let scanningManager: ScanningManaging
    private var _data: UserPointData?
    private var isOnline: Bool { networkMonitor.onlineStatus }
    
    // MARK: - Public Properties
    
    weak var scanningDelegate: ScanPointFlowDelegate?
    let networkMonitor: NetworkMonitoring
    var token: String? { storage.token }
    
    // MARK: - Initialization
    
    init(dependencies: Dependencies) {
        self.storage = dependencies.storage
        self.logger = dependencies.logger
        self.userDataAPIService = dependencies.userDataAPI
        self.networkMonitor = dependencies.networkMonitor
        self.scanningManager = dependencies.scanningManager
    }
    
    // MARK: - Public Interface
    
    func loadFromRepository() {
        Task { @MainActor [weak self] in
            do {
                try await self?.storage.loadFromRepository(for: .userPoints)
                self?._data = try await self?.storage.userPointData()
            } catch {
                self?.logger.log(message: "Unable to load user points from storage")
            }
        }
    }
    
    func fetch(withToken token: String) async throws {
        logger.log(message: "Loading user points")
        let response = try await userDataAPIService.userPoints(userToken: token)
        try await storage.saveUserPointData(response.data)
        _data = response.data
    }
    
    func getById(id: String) -> UserPoint? {
        _data?.data.first { $0.id == id }
    }
    
    func getAll() -> [UserPoint] {
        _data?.data ?? []
    }
    
    func getPoints(byCategory categoryId: String) -> [UserPoint] {
        _data?.data.filter { $0.pointCategory.contains(categoryId) } ?? []
    }
    
    func getTotalPoints(byCategory categoryId: String) -> Int {
        // Returns total for user points that are valid
        return getPoints(byCategory: categoryId)
            .filter { $0.doesPointCount }
            .reduce(0) { $0 + $1.pointValue }
    }
    
    func handleScannedPoint(_ point: ScannedPoint) async throws {
        guard point.location != nil else {
            logger.log(message: "Couldn't extract user's location for scanned point \(point.code)")
            scanningDelegate?.onScanPointNoLocation()
            return
        }
        guard scanningManager.checkValidity(point) else {
            logger.log(message: "The Scanned point \(point.code) is invalid")
            scanningDelegate?.onScanPointInvalidPoint()
            return
        }
        if isOnline {
            try await handleOnlinePoint(point)
        } else {
            await handleOfflinePoint(point)
        }
    }
    
    func handleAllStoredScannedPoints() async throws {
        try await scanningManager.sendAllStoredScannedPoints()
    }
    
    func onLogout() {
        _data = nil
    }
    
    func checkSum() -> String? {
        _data?.checkSum
    }
    
    // MARK: - Private Helpers
    
    private func handleOnlinePoint(_ point: ScannedPoint) async throws {
        do {
            try await scanningManager.handleScannedPointOnline(point)
            scanningDelegate?.onScanPointProcessSuccessOnline(point.codeSource)
        } catch let error as BaseError {
            if error.code == ErrorCodes.specificStatusCode(.invalidToken).code {
                throw error // Handled by Game Data Manager
            } else {
                scanningDelegate?.onScanPointOnlineProcessError(point.codeSource)
            }
        } catch {
            scanningDelegate?.onScanPointOnlineProcessError(point.codeSource)
        }
    }
    
    private func handleOfflinePoint(_ point: ScannedPoint) async {
        do {
            try await scanningManager.handleScannedPointOffline(point)
            scanningDelegate?.onScanPointProcessSuccessOffline(point.codeSource)
        } catch {
            scanningDelegate?.onScanPointOnlineProcessError(point.codeSource)
        }
    }
}
