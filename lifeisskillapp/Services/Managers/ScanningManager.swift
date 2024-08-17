//
//  ScanningManager.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 26.07.2024.
//

import Foundation

protocol HasScanningManager {
    var scanningManager: ScanningManaging { get }
}

protocol ScanningManaging {
    func sendScannedPoint(_ point: LoadPoint) async throws
}

public final class ScanningManager: ScanningManaging {
    typealias Dependencies = HasLoggerServicing & HasUserDataAPIService & HasUserLoginManager

    // MARK: - Private properties
    
    private let logger: LoggerServicing
    private let userDataAPI: UserDataAPIServicing
    private let dataManager: UserLoginDataManaging
    
    // MARK: - Initialization
    
    init(dependencies: Dependencies) {
        self.logger = dependencies.logger
        self.userDataAPI = dependencies.userDataAPI
        self.dataManager = dependencies.userLoginManager
    }
    
    // MARK: - Public Interface
    
    func sendScannedPoint(_ point: LoadPoint) async throws {
        logger.log(message: "Sending scanned point: \(point.code)")
        guard let token = dataManager.token else {
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
    
    // MARK: - Private Helpers
    
    private func checkValidity(_ response: APIResponse<UserPointData>) -> Bool {
        // TODO: handle logic from response
        true
    }
}