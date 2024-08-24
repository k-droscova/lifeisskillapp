//
//  RealmUserDataStorage.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 10.08.2024.
//

import Foundation
import RealmSwift
import Combine

enum PersistentDataType {
    case categories, userPoints, genericPoints, rankings, checkSum, scannedPoints
}

protocol HasPersistentUserDataStoraging {
    var storage: PersistentUserDataStoraging { get }
}

protocol PersistentUserDataStoraging: UserDataStoraging {
    func loadAllDataFromRepositories() async throws
    func loadFromRepository(for data: PersistentDataType) async throws
}

public final class RealmUserDataStorage: BaseClass, PersistentUserDataStoraging {
    typealias Dependencies = HasLoggers & HasRealmRepositories
    
    // MARK: - Private Properties
    
    private let logger: LoggerServicing
    private var loginRepo: any RealmLoginRepositoring
    private var checkSumRepo: any RealmCheckSumRepositoring
    private var categoryRepo: any RealmUserCategoryRepositoring
    private var rankingRepo: any RealmUserRankRepositoring
    private var genericPointRepo: any RealmGenericPointRepositoring
    private var userPointRepo: any RealmUserPointRepositoring
    private var scannedPointRepo: any RealmScannedPointRepositoring
    
    private var _userCategoryData: UserCategoryData?
    private var _userPointData: UserPointData?
    private var _genericPointData: GenericPointData?
    private var _userRankData: UserRankData?
    private var _checkSumData: CheckSumData?
    private var _scannedPoints: [ScannedPoint] = []
    
    // MARK: - Public Properties
    
    var token: String?
    var isLoggedIn: Bool = false
    
    // MARK: - Initialization
    
    init(dependencies: Dependencies) {
        self.logger = dependencies.logger
        self.loginRepo = dependencies.realmLoginRepository
        self.checkSumRepo = dependencies.realmCheckSumRepository
        self.categoryRepo = dependencies.realmCategoryRepository
        self.rankingRepo = dependencies.realmUserRankRepository
        self.genericPointRepo = dependencies.realmPointRepository
        self.userPointRepo = dependencies.realmUserPointRepository
        self.scannedPointRepo = dependencies.realmScannedPointRepository
    }
    
    // MARK: - Public Interface
    
    func onLogin() async throws {
        try await withThrowingTaskGroup(of: Void.self) {  [weak self] group in
            guard let self = self else { return }
            group.addTask { try await self.loadCategories() }
            group.addTask { try await self.loadUserPoints() }
            group.addTask { try await self.loadGenericPoints() }
            group.addTask { try await self.loadUserRanks() }
            group.addTask { try await self.loadCheckSumData() }
            try await group.waitForAll()
        }
        self.isLoggedIn = true
        logger.log(message: "All data loaded concurrently on login.")
    }
    
    func onLogout() async throws {
        try loginRepo.markUserAsLoggedOut()
        await clearInMemoryData()
        self.isLoggedIn = false
        logger.log(message: "User logged out successfully.")
    }
    
    func clearUserRelatedData() async throws {
        try await withThrowingTaskGroup(of: Void.self) { [weak self] group in
            guard let self = self else { return }
            group.addTask { try self.loginRepo.deleteAll() }
            group.addTask { try self.checkSumRepo.deleteAll() }
            group.addTask { try self.categoryRepo.deleteAll() }
            group.addTask { try self.rankingRepo.deleteAll() }
            group.addTask { try self.userPointRepo.deleteAll() }
            group.addTask { await self.clearInMemoryData() }
            try await group.waitForAll()
        }
        logger.log(message: "All related user data has been cleared.")
    }
    
    func clearScannedPointData() async throws {
        try scannedPointRepo.deleteAll()
        logger.log(message: "Saved scanned points deleted")
    }
    
    func loadFromRepository(for data: PersistentDataType) async throws {
        switch data {
        case .userPoints:
            try await loadUserPoints()
        case .genericPoints:
            try await loadGenericPoints()
        case .rankings:
            try await loadUserRanks()
        case .checkSum:
            try await loadCheckSumData()
        case .categories:
            try await loadCategories()
        case .scannedPoints:
            try await loadScannedPoints()
        }
    }
    
    func loadAllDataFromRepositories() async throws {
        try await withThrowingTaskGroup(of: Void.self) {  [weak self] group in
            guard let self = self else { return }
            group.addTask { try await self.loadCategories() }
            group.addTask { try await self.loadUserPoints() }
            group.addTask { try await self.loadGenericPoints() }
            group.addTask { try await self.loadUserRanks() }
            group.addTask { try await self.loadCheckSumData() }
            
            try await group.waitForAll()
        }
        logger.log(message: "All data loaded concurrently")
    }
    
    // MARK: - Public Interface Saving Methods
    
    func saveUserCategoryData(_ data: UserCategoryData?) async throws {
        if let data = data {
            let realmCategoryData = RealmUserCategoryData(from: data)
            try categoryRepo.save(realmCategoryData)
            logger.log(message: "User categories saved successfully.")
        } else {
            try categoryRepo.deleteAll()
            logger.log(message: "User categories deleted successfully.")
        }
        _userCategoryData = data
    }
    
    func saveUserPointData(_ data: UserPointData?) async throws {
        if let data = data {
            let realmUserPointData = RealmUserPointData(from: data)
            try userPointRepo.save(realmUserPointData)
            logger.log(message: "User points saved successfully.")
        } else {
            try userPointRepo.deleteAll()
            logger.log(message: "User points deleted successfully.")
        }
        _userPointData = data
    }
    
    func saveGenericPointData(_ data: GenericPointData?) async throws {
        if let data = data {
            let realmGenericPointData = RealmGenericPointData(from: data)
            try genericPointRepo.save(realmGenericPointData)
            logger.log(message: "Generic points saved successfully.")
        } else {
            try genericPointRepo.deleteAll()
            logger.log(message: "Generic points deleted successfully.")
        }
        _genericPointData = data
    }
    
    func saveUserRankData(_ data: UserRankData?) async throws{
        if let data = data {
            let realmUserRankData = RealmUserRankData(from: data)
            try rankingRepo.save(realmUserRankData)
            logger.log(message: "User ranks saved successfully.")
        } else {
            try rankingRepo.deleteAll()
            logger.log(message: "User ranks deleted successfully.")
        }
        _userRankData = data
    }
    
    func saveCheckSumData(_ data: CheckSumData?) async throws {
        if let data = data {
            let realmCheckSumData = RealmCheckSumData(from: data)
            try checkSumRepo.save(realmCheckSumData)
            logger.log(message: "CheckSum data saved successfully.")
        } else {
            try checkSumRepo.deleteAll()
            logger.log(message: "CheckSum data deleted successfully.")
        }
        _checkSumData = data
    }
    
    func saveScannedPoint(_ point: ScannedPoint) async throws {
        try scannedPointRepo.save(RealmScannedPoint(from: point))
    }
    
    // MARK: - Public Interface Getting Methods
    
    func userCategoryData() async throws -> UserCategoryData? {
        try await loadCategories()
        return _userCategoryData
    }
    
    func userPointData() async throws -> UserPointData? {
        try await loadUserPoints()
        return _userPointData
    }
    
    func userRankData() async throws -> UserRankData? {
        try await loadUserRanks()
        return _userRankData
    }
    
    func genericPointData() async throws -> GenericPointData? {
        try await loadGenericPoints()
        return _genericPointData
    }
    
    func checkSumData() async throws -> CheckSumData? {
        try await loadCheckSumData()
        return _checkSumData
    }
    
    func scannedPoints() async throws -> [ScannedPoint] {
        try await loadScannedPoints()
        return _scannedPoints
    }
    
    // MARK: - Public Interface For Logged In User
    
    func savedLoginDetails() async throws -> LoginUserData? {
        guard let user = try loginRepo.getSavedLoginDetails() else { return nil }
        return user.loginUserData()
    }
    
    func loggedInUserDetails() async throws -> LoginUserData? {
        guard let user = try loginRepo.getSavedLoginDetails(), user.isLoggedIn else { return nil }
        return user.loginUserData()
    }
    
    func login(_ user: LoggedInUser) async throws {
        try loginRepo.saveLoginUser(user)
        self.token = user.token
    }
    
    func markUserAsLoggedOut() async throws {
        try loginRepo.markUserAsLoggedOut()
        self.token = nil
    }
    
    func markUserAsLoggedIn() async throws {
        guard let user = try loginRepo.getSavedLoginDetails() else { return }
        try loginRepo.markUserAsLoggedOut()
        self.token = user.token
    }
    
    // MARK: - Private Helpers
    
    private func clearInMemoryData() async {
        Task { [weak self] in
            guard let self = self else { return }
            await withTaskGroup(of: Void.self) { group in
                group.addTask { self._userCategoryData = nil }
                group.addTask { self._userPointData = nil }
                group.addTask { self._userRankData = nil }
                group.addTask { self._genericPointData = nil }
                group.addTask { self._checkSumData = nil }
                group.addTask { self.token = nil }
            }
            self.logger.log(message: "All data nullified on logout.")
        }
    }
    
    private func loadCategories() async throws {
        let realmCategoryData = try categoryRepo.getAll().first
        if let realmCategoryData = realmCategoryData {
            _userCategoryData = realmCategoryData.userCategoryData()
            logger.log(message: "User categories loaded successfully.")
        } else {
            logger.log(message: "No user categories found in the repository.")
        }
    }
    
    private func loadUserPoints() async throws {
        let realmUserPoints = try userPointRepo.getAll().first
        if let realmUserPoints = realmUserPoints {
            _userPointData = realmUserPoints.userPointData()
            logger.log(message: "User points loaded successfully.")
        } else {
            logger.log(message: "No user points found in the repository.")
        }
    }
    
    private func loadGenericPoints() async throws {
        let realmGenericPoints = try genericPointRepo.getAll().first
        if let realmGenericPoints = realmGenericPoints {
            _genericPointData = realmGenericPoints.genericPointData()
            logger.log(message: "Generic points loaded successfully.")
        } else {
            logger.log(message: "No generic points found in the repository.")
        }
    }
    
    private func loadUserRanks() async throws {
        let realmUserRanks = try rankingRepo.getAll().first
        if let realmUserRanks = realmUserRanks {
            _userRankData = realmUserRanks.userRankData()
            logger.log(message: "User ranks loaded successfully.")
        } else {
            logger.log(message: "No user ranks found in the repository.")
        }
    }
    
    private func loadCheckSumData() async throws {
        let realmCheckSumData = try checkSumRepo.getAll().first
        if let realmCheckSumData = realmCheckSumData {
            _checkSumData = realmCheckSumData.checkSumData()
            logger.log(message: "CheckSum data loaded successfully.")
        } else {
            logger.log(message: "No CheckSum data found in the repository.")
        }
    }
    
    private func loadScannedPoints() async throws {
        let scannedPoints = try await scannedPointRepo.getScannedPoints()
        _scannedPoints = scannedPoints
    }
}
