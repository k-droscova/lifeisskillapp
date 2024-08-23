//
//  UserDataStorage.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 16.07.2024.
//

import Foundation

final class InMemoryUserDataStorage: UserDataStoraging {
    typealias Dependencies = HasLoggerServicing
    
    // MARK: - Private Properties
    
    private let logger: LoggerServicing
    private var internalStore: [String: Any] = [:]
    
    // MARK: - Initialization
    
    init(dependencies: Dependencies) {
        self.logger = dependencies.logger
    }
    
    // MARK: - Public Interface
    
    func onLogin() async throws {
        logger.log(message: "User logged in. Current internal store contents:")
        for (key, value) in internalStore {
            print("\(key): \(value)")
        }
    }
    
    func onLogout() async {
        internalStore.removeAll()
    }
    
    func clearScannedPointData() async throws {
        internalStore.removeValue(forKey: "scannedPoints")
    }
    
    func clearUserRelatedData() async throws {
        // Remove user category, user points, and user rank data
        internalStore.removeValue(forKey: "userCategoryData")
        internalStore.removeValue(forKey: "userPointData")
        internalStore.removeValue(forKey: "userRankData")
        
        // Clear the related fields in CheckSumData
        if var checkSumData = internalStore["checkSumData"] as? CheckSumData {
            checkSumData.userPoints = ""
            checkSumData.rank = ""
            internalStore["checkSumData"] = checkSumData
        }
    }
    
    // MARK: - User Categories
    
    func userCategoryData() async throws -> UserCategoryData? {
        internalStore["userCategoryData"] as? UserCategoryData
    }
    
    func saveUserCategoryData(_ data: UserCategoryData?) async throws {
        guard let data else {
            internalStore.removeValue(forKey: "userCategoryData")
            return
        }
        internalStore["userCategoryData"] = data
    }
    
    // MARK: - User Points
    
    func userPointData() async throws -> UserPointData? {
        internalStore["userPointData"] as? UserPointData
    }
    
    func saveUserPointData(_ data: UserPointData?) async throws {
        guard let data else {
            internalStore.removeValue(forKey: "userPointData")
            return
        }
        internalStore["userPointData"] = data
    }
    
    // MARK: - User Rank
    
    func userRankData() async throws -> UserRankData? {
        internalStore["userRankData"] as? UserRankData
    }
    
    func saveUserRankData(_ data: UserRankData?) async throws {
        guard let data else {
            internalStore.removeValue(forKey: "userRankData")
            return
        }
        internalStore["userRankData"] = data
    }
    
    // MARK: - Generic Points
    
    func genericPointData() async throws -> GenericPointData? {
        internalStore["genericPointData"] as? GenericPointData
    }
    
    func saveGenericPointData(_ data: GenericPointData?) async throws {
        guard let data else {
            internalStore.removeValue(forKey: "genericPointData")
            return
        }
        internalStore["genericPointData"] = data
    }
    
    // MARK: - Check Sums
    
    func checkSumData() async throws -> CheckSumData? {
        internalStore["checkSumData"] as? CheckSumData
    }
    
    func saveCheckSumData(_ data: CheckSumData?) async throws {
        guard let data else {
            internalStore.removeValue(forKey: "checkSumData")
            return
        }
        internalStore["checkSumData"] = data
    }
    
    // MARK: - Scanned Points
    
    func scannedPoints() async throws -> [ScannedPoint] {
        internalStore["scannedPoints"] as? [ScannedPoint] ?? []
    }
    
    func saveScannedPoint(_ point: ScannedPoint) async throws {
        if var points = internalStore["scannedPoints"] as? [ScannedPoint] {
            points.append(point)
            internalStore["scannedPoints"] = points
        } else {
            internalStore["scannedPoints"] = [point]
        }
    }
}
