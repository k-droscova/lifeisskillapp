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
    func onScanPointProcessError(_ source: CodeSource)
    func onScanPointOfflineProcessError()
}

protocol UserPointManaging: UserDataManaging where DataType == UserPoint, DataContainer == UserPointData {
    var scanningDelegate: ScanPointFlowDelegate? { get set }
    func getPoints(byCategory categoryId: String) -> [UserPoint]
    func getTotalPoints(byCategory categoryId: String) -> Int
    func handleScannedPoint(_ point: ScannedPoint)
    func handleAllStoredScannedPoints()
}

public final class UserPointManager: BaseClass, UserPointManaging {
    typealias Dependencies = HasLoggerServicing & HasUserDataAPIService & HasPersistentUserDataStoraging & HasUserManager & HasScanningManager & HasNetworkMonitor
    
    // MARK: - Private Properties
    
    private var storage: PersistentUserDataStoraging
    private let logger: LoggerServicing
    private let userManager: UserManaging
    private let userDataAPIService: UserDataAPIServicing
    private let scanningManager: ScanningManaging
    private var _data: UserPointData?
    private var isOnline: Bool { networkMonitor.onlineStatus }
    
    internal let networkMonitor: NetworkMonitoring
    
    // MARK: - Public Properties
    
    weak var scanningDelegate: ScanPointFlowDelegate?
    
    var token: String? { userManager.token }
    
    // MARK: - Initialization
    
    init(dependencies: Dependencies) {
        self.storage = dependencies.storage
        self.logger = dependencies.logger
        self.userManager = dependencies.userManager
        self.userDataAPIService = dependencies.userDataAPI
        self.networkMonitor = dependencies.networkMonitor
        self.scanningManager = dependencies.scanningManager
        
        super.init()
        self.loadFromRepository()
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
        do {
            let response = try await userDataAPIService.getUserPoints(baseURL: APIUrl.baseURL, userToken: token)
            try await storage.saveUserPointData(response.data)
            _data = response.data
        } catch let error as BaseError {
            if error.code == ErrorCodes.specificStatusCode(.invalidToken).code {
                userManager.forceLogout()
            } else {
                throw error
            }
        } catch {
            throw BaseError(
                context: .system,
                message: "Unable to load user points",
                logger: logger
            )
        }
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
    
    func handleScannedPoint(_ point: ScannedPoint) {
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
            handleOnlinePoint(point)
        } else {
            handleOfflinePoint(point)
        }
    }
    
    func handleAllStoredScannedPoints() {
        Task { @MainActor [weak self] in
            do {
                try await self?.scanningManager.sendAllStoredScannedPoints()
            } catch let error as BaseError {
                if error.code == ErrorCodes.specificStatusCode(.invalidToken).code {
                    self?.userManager.forceLogout()
                    return
                }
            } catch {
                self?.logger.log(message: "The saved scanned point could not be processed")
                self?.scanningDelegate?.onScanPointOfflineProcessError()
            }
        }
    }
    
    func onLogout() {
        _data = nil
    }
    
    func checkSum() -> String? {
        _data?.checkSum
    }
    
    // MARK: - Private Helpers
    
    private func handleOnlinePoint(_ point: ScannedPoint) {
        Task { @MainActor [weak self] in
            do {
                try await self?.scanningManager.handleScannedPointOnline(point)
                self?.scanningDelegate?.onScanPointProcessSuccessOnline(point.codeSource)
            } catch {
                self?.logger.log(message: "The Scanned point \(point.code) could not be processed")
                self?.scanningDelegate?.onScanPointProcessError(point.codeSource)
            }
        }
    }
    
    private func handleOfflinePoint(_ point: ScannedPoint) {
        Task { @MainActor [weak self] in
            do {
                try await self?.scanningManager.handleScannedPointOffline(point)
                self?.scanningDelegate?.onScanPointProcessSuccessOffline(point.codeSource)
            } catch {
                self?.logger.log(message: "The Scanned point \(point.code) could not be processed")
                self?.scanningDelegate?.onScanPointProcessError(point.codeSource)
            }
        }
    }
}
