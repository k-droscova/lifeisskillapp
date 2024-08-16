//
//  ScanningManager.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 26.07.2024.
//

import Foundation
import Combine

protocol HasScanningManager {
    var scanningManager: ScanningManaging { get }
}

protocol ScanningManaging {
    func handleScannedPointOnline(_ point: ScannedPoint) async throws
    func handleScannedPointOffline(_ point: ScannedPoint) async throws
    func sendAllStoredScannedPoints() async throws
    func checkValidity(_ point: ScannedPoint) -> Bool
}

public final class ScanningManager: ScanningManaging {
    typealias Dependencies = HasLoggerServicing & HasUserDataAPIService & HasUserManager & HasPersistentUserDataStoraging & HasRepositoryContainer & HasNetworkMonitor
    
    // MARK: - Private properties
    
    private let logger: LoggerServicing
    private let userDataAPI: UserDataAPIServicing
    private let userManager: UserManaging
    private var token: String? { userManager.token }
    private let storage: PersistentUserDataStoraging
    private var scannedPointRepo: any RealmScannedPointRepositoring
    private let networkMonitor: NetworkMonitoring
        
    // MARK: - Initialization
    
    init(dependencies: Dependencies) {
        self.logger = dependencies.logger
        self.userDataAPI = dependencies.userDataAPI
        self.userManager = dependencies.userManager
        self.storage = dependencies.storage
        self.scannedPointRepo = dependencies.container.realmScannedPointRepository
        self.networkMonitor = dependencies.networkMonitor
    }
    
    // MARK: - Public Interface
    
    func handleScannedPointOnline(_ point: ScannedPoint) async throws {
        logger.log(message: "Sending scanned point: \(point.code)")
        guard let token else {
            throw BaseError(
                context: .system,
                message: "Cannot send data to API, no access to userToken",
                logger: logger)
        }
        let response = try await userDataAPI.postUserPoints(baseURL: APIUrl.baseURL, userToken: token, point: point)
        // Handle response if needed
        guard checkValidity(response) else {
            throw BaseError(
                context: .system,
                message: "The Scanned point \(point.code) was not processed properly",
                logger: logger)
        }
        logger.log(message: "Successfully sent scanned point: \(point.code)")
    }
    
    func handleScannedPointOffline(_ point: ScannedPoint) async throws {
        logger.log(message: "Saving scanned point: \(point.code)")
        try scannedPointRepo.save(RealmScannedPoint(from: point))
    }
    
    func checkValidity(_ point: ScannedPoint) -> Bool {
        // TODO: handle preprocessing for validity in the app
        guard (point.location != nil) else { return false }
        return true
    }
    
    func sendAllStoredScannedPoints() async throws {
        let points = try await scannedPointRepo.getScannedPoints()
        try scannedPointRepo.deleteAll()
        
        for scannedPoint in points {
            try await handleScannedPointOnline(scannedPoint)
            logger.log(message: "Successfully sent scanned point: \(scannedPoint.code)")
        }
    }
    
    // MARK: - Private Helpers
    
    private func checkValidity(_ response: APIResponse<UserPointData>) -> Bool {
        // TODO: handle logic from response
        true
    }
}
