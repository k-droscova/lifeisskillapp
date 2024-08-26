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
    
    // MARK: - Public Properties
    
    private(set) var token: String?
    private(set) var isLoggedIn: Bool = false
    
    // MARK: - Keys
    
    private enum StorageKey: String {
        case loginUserData = "LoginUserData"
        case userCategoryData = "userCategoryData"
        case userPointData = "userPointData"
        case userRankData = "userRankData"
        case genericPointData = "genericPointData"
        case checkSumData = "checkSumData"
        case scannedPoints = "scannedPoints"
        case sponsorImageDataPrefix = "sponsorImageData_"
    }
    
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
        isLoggedIn = true
    }
    
    func savedLoginDetails() async throws -> LoginUserData? {
        guard let loggedInUser = internalStore[StorageKey.loginUserData.rawValue] as? LoggedInUser else { return nil }
        return LoginUserData(from: loggedInUser)
    }
    
    func loggedInUserDetails() async throws -> LoginUserData? {
        guard let loggedInUser = internalStore[StorageKey.loginUserData.rawValue] as? LoggedInUser else { return nil }
        return LoginUserData(from: loggedInUser)
    }
    
    func login(_ user: LoggedInUser) async throws {
        internalStore[StorageKey.loginUserData.rawValue] = user
        isLoggedIn = true
    }
    
    func markUserAsLoggedOut() async throws {
        await self.onLogout()
    }
    
    func markUserAsLoggedIn() async throws {
        return
    }
    
    func onLogout() async {
        token = nil
        isLoggedIn = false
        internalStore.removeAll()
    }
    
    func clearScannedPointData() async throws {
        internalStore.removeValue(forKey: StorageKey.scannedPoints.rawValue)
    }
    
    func clearUserRelatedData() async throws {
        // Remove user category, user points, and user rank data
        internalStore.removeValue(forKey: StorageKey.userCategoryData.rawValue)
        internalStore.removeValue(forKey: StorageKey.userPointData.rawValue)
        internalStore.removeValue(forKey: StorageKey.userRankData.rawValue)
        
        // Clear the related fields in CheckSumData
        if var checkSumData = internalStore[StorageKey.checkSumData.rawValue] as? CheckSumData {
            checkSumData.userPoints = ""
            checkSumData.rank = ""
            internalStore[StorageKey.checkSumData.rawValue] = checkSumData
        }
    }
    
    // MARK: - User Categories
    
    func userCategoryData() async throws -> UserCategoryData? {
        internalStore[StorageKey.userCategoryData.rawValue] as? UserCategoryData
    }
    
    func saveUserCategoryData(_ data: UserCategoryData?) async throws {
        guard let data else {
            internalStore.removeValue(forKey: StorageKey.userCategoryData.rawValue)
            return
        }
        internalStore[StorageKey.userCategoryData.rawValue] = data
    }
    
    // MARK: - User Points
    
    func userPointData() async throws -> UserPointData? {
        internalStore[StorageKey.userPointData.rawValue] as? UserPointData
    }
    
    func saveUserPointData(_ data: UserPointData?) async throws {
        guard let data else {
            internalStore.removeValue(forKey: StorageKey.userPointData.rawValue)
            return
        }
        internalStore[StorageKey.userPointData.rawValue] = data
    }
    
    // MARK: - User Rank
    
    func userRankData() async throws -> UserRankData? {
        internalStore[StorageKey.userRankData.rawValue] as? UserRankData
    }
    
    func saveUserRankData(_ data: UserRankData?) async throws {
        guard let data else {
            internalStore.removeValue(forKey: StorageKey.userRankData.rawValue)
            return
        }
        internalStore[StorageKey.userRankData.rawValue] = data
    }
    
    // MARK: - Generic Points
    
    func genericPointData() async throws -> GenericPointData? {
        internalStore[StorageKey.genericPointData.rawValue] as? GenericPointData
    }
    
    func saveGenericPointData(_ data: GenericPointData?) async throws {
        guard let data else {
            internalStore.removeValue(forKey: StorageKey.genericPointData.rawValue)
            return
        }
        internalStore[StorageKey.genericPointData.rawValue] = data
    }
    
    // MARK: - Check Sums
    
    func checkSumData() async throws -> CheckSumData? {
        internalStore[StorageKey.checkSumData.rawValue] as? CheckSumData
    }
    
    func saveCheckSumData(_ data: CheckSumData?) async throws {
        guard let data else {
            internalStore.removeValue(forKey: StorageKey.checkSumData.rawValue)
            return
        }
        internalStore[StorageKey.checkSumData.rawValue] = data
    }
    
    // MARK: - Scanned Points
    
    func scannedPoints() async throws -> [ScannedPoint] {
        internalStore[StorageKey.scannedPoints.rawValue] as? [ScannedPoint] ?? []
    }
    
    func saveScannedPoint(_ point: ScannedPoint) async throws {
        if var points = internalStore[StorageKey.scannedPoints.rawValue] as? [ScannedPoint] {
            points.append(point)
            internalStore[StorageKey.scannedPoints.rawValue] = points
        } else {
            internalStore[StorageKey.scannedPoints.rawValue] = [point]
        }
    }
    
    // MARK: - Sponsor Images
    
    func saveSponsorImage(for sponsorId: String, imageData: Data) async throws {
        let key = StorageKey.sponsorImageDataPrefix.rawValue + sponsorId
        internalStore[key] = imageData
    }
    
    func sponsorImage(for sponsorId: String) async throws -> Data? {
        let key = StorageKey.sponsorImageDataPrefix.rawValue + sponsorId
        return internalStore[key] as? Data
    }
}
