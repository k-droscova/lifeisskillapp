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
    case categories, userPoints, genericPoints, rankings, checkSum
}

protocol PersistentUserDataStorageDelegate: NSObject {
    func onError(_ error: Error)
}

protocol HasPersistentUserDataStoraging {
    var storage: PersistentUserDataStoraging { get }
}

protocol PersistentUserDataStoraging: UserDataStoraging {
    var delegate: PersistentUserDataStorageDelegate? { get set }
    func load()
    func onLogout() throws
    func loadFromRepository(for data: PersistentDataType) async
    func saveUserCategories(data: UserCategoryData?) async
    func saveUserPoints(data: UserPointData?) async
    func saveGenericPoints(data: GenericPointData?) async
    func saveUserRanks(data: UserRankData?) async
    func saveLoginData(data: LoginUserData?) async
    func saveCheckSumData(data: CheckSumData?) async
    func clearAllUserData() async throws
    func clearSavedScannedPoints() async throws
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
    
    // MARK: - Public Properties
    
    var userCategoryData: UserCategoryData? {
        get {
            _userCategoryData
        }
        set {
            _userCategoryData = newValue
            Task { [weak self] in
                await self?.saveUserCategories(data: newValue)
            }
        }
    }

    var userPointData: UserPointData? {
        get {
            _userPointData
        }
        set {
            _userPointData = newValue
            Task { [weak self] in
                await self?.saveUserPoints(data: newValue)
            }
        }
    }

    var genericPointData: GenericPointData? {
        get {
            _genericPointData
        }
        set {
            _genericPointData = newValue
            Task { [weak self] in
                await self?.saveGenericPoints(data: newValue)
            }
        }
    }

    var userRankData: UserRankData? {
        get {
            _userRankData
        }
        set {
            _userRankData = newValue
            Task { [weak self] in
                await self?.saveUserRanks(data: newValue)
            }
        }
    }

    var checkSumData: CheckSumData? {
        get {
            _checkSumData
        }
        set {
            _checkSumData = newValue
            Task { [weak self] in
                await self?.saveCheckSumData(data: newValue)
            }
        }
    }
    
    weak var delegate: PersistentUserDataStorageDelegate?

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
    
    func load() {
        Task { [weak self] in
            guard let self = self else { return }
            await withTaskGroup(of: Void.self) { group in
                group.addTask { await self.loadCategories() }
                group.addTask { await self.loadUserPoints() }
                group.addTask { await self.loadGenericPoints() }
                group.addTask { await self.loadUserRanks() }
                group.addTask { await self.loadCheckSumData() }
            }
            self.logger.log(message: "All data loaded concurrently.")
        }
    }
    
    func onLogout() throws {
        try loginRepo.markUserAsLoggedOut()
        self.clearInMemoryData()
    }
    
    func clearAllUserData() async throws {
        try await withThrowingTaskGroup(of: Void.self) { [weak self] group in
            guard let self = self else { return }
            group.addTask { try self.loginRepo.deleteAll() }
            group.addTask { try self.checkSumRepo.deleteAll() }
            group.addTask { try self.categoryRepo.deleteAll() }
            group.addTask { try self.rankingRepo.deleteAll() }
            group.addTask { try self.genericPointRepo.deleteAll() }
            group.addTask { try self.userPointRepo.deleteAll() }
            group.addTask { self.clearInMemoryData() }
            try await group.waitForAll()
        }
        logger.log(message: "All related user data has been cleared.")
    }
    
    func clearSavedScannedPoints() async throws {
        logger.log(message: "Saved scanned points deleted")
        try self.scannedPointRepo.deleteAll()
    }
    
    func loadFromRepository(for data: PersistentDataType) async {
        switch data {
        case .userPoints:
            await loadUserPoints()
        case .genericPoints:
            await loadGenericPoints()
        case .rankings:
            await loadUserRanks()
        case .checkSum:
            await loadCheckSumData()
        case .categories:
            await loadCategories()
        }
    }
    
    func saveUserCategories(data: UserCategoryData?) async {
        do {
            if let data = data {
                let realmCategoryData = RealmUserCategoryData(from: data)
                try categoryRepo.save(realmCategoryData)
                logger.log(message: "User categories saved successfully.")
            } else {
                try categoryRepo.deleteAll()
                logger.log(message: "User categories deleted successfully.")
            }
        } catch {
            logger.log(message: "Failed to save/delete user categories: \(error.localizedDescription)")
            delegate?.onError(error)
        }
    }
    
    func saveUserPoints(data: UserPointData?) async {
        do {
            if let data = data {
                let realmUserPointData = RealmUserPointData(from: data)
                try userPointRepo.save(realmUserPointData)
                logger.log(message: "User points saved successfully.")
            } else {
                try userPointRepo.deleteAll()
                logger.log(message: "User points deleted successfully.")
            }
        } catch {
            logger.log(message: "Failed to save/delete user points: \(error.localizedDescription)")
            delegate?.onError(error)
        }
    }
    
    func saveGenericPoints(data: GenericPointData?) async {
        do {
            if let data = data {
                let realmGenericPointData = RealmGenericPointData(from: data)
                try genericPointRepo.save(realmGenericPointData)
                logger.log(message: "Generic points saved successfully.")
            } else {
                try genericPointRepo.deleteAll()
                logger.log(message: "Generic points deleted successfully.")
            }
        } catch {
            logger.log(message: "Failed to save/delete generic points: \(error.localizedDescription)")
            delegate?.onError(error)
        }
    }
    
    func saveUserRanks(data: UserRankData?) async {
        do {
            if let data = data {
                let realmUserRankData = RealmUserRankData(from: data)
                try rankingRepo.save(realmUserRankData)
                logger.log(message: "User ranks saved successfully.")
            } else {
                try rankingRepo.deleteAll()
                logger.log(message: "User ranks deleted successfully.")
            }
        } catch {
            logger.log(message: "Failed to save/delete user ranks: \(error.localizedDescription)")
            delegate?.onError(error)
        }
    }
    
    func saveLoginData(data: LoginUserData?) async {
        do {
            if let data = data {
                let realmLoginDetails = RealmLoginDetails(from: data.user)
                try loginRepo.save(realmLoginDetails)
                logger.log(message: "Login data saved successfully.")
            } else {
                try loginRepo.deleteAll()
                logger.log(message: "Login data deleted successfully.")
            }
        } catch {
            logger.log(message: "Failed to save/delete login data: \(error.localizedDescription)")
            delegate?.onError(error)
        }
    }
    
    func saveCheckSumData(data: CheckSumData?) async {
        do {
            if let data = data {
                let realmCheckSumData = RealmCheckSumData(from: data)
                try checkSumRepo.save(realmCheckSumData)
                logger.log(message: "CheckSum data saved successfully.")
            } else {
                try checkSumRepo.deleteAll()
                logger.log(message: "CheckSum data deleted successfully.")
            }
        } catch {
            logger.log(message: "Failed to save/delete CheckSum data: \(error.localizedDescription)")
            delegate?.onError(error)
        }
    }
    
    // MARK: - Private Helpers
    
    private func clearInMemoryData() {
        Task { [weak self] in
            guard let self = self else { return }
            await withTaskGroup(of: Void.self) { group in
                group.addTask { self._userCategoryData = nil }
                group.addTask { self._userPointData = nil }
                group.addTask { self._userRankData = nil }
                group.addTask { self._genericPointData = nil }
                group.addTask { self._checkSumData = nil }
            }
            self.logger.log(message: "All data nullified on logout.")
        }
    }
    
    private func loadCategories() async {
        do {
            let realmCategoryData = try categoryRepo.getAll().first
            if let realmCategoryData = realmCategoryData {
                _userCategoryData = realmCategoryData.userCategoryData()
                logger.log(message: "User categories loaded successfully.")
            } else {
                logger.log(message: "No user categories found in the repository.")
            }
        } catch {
            logger.log(message: "Failed to load user categories: \(error.localizedDescription)")
        }
    }
    
    private func loadUserPoints() async {
        do {
            let realmUserPoints = try userPointRepo.getAll().first
            if let realmUserPoints = realmUserPoints {
                _userPointData = realmUserPoints.userPointData()
                logger.log(message: "User points loaded successfully.")
            } else {
                logger.log(message: "No user points found in the repository.")
            }
        } catch {
            logger.log(message: "Failed to load user points: \(error.localizedDescription)")
        }
    }
    
    private func loadGenericPoints() async {
        do {
            let realmGenericPoints = try genericPointRepo.getAll().first
            if let realmGenericPoints = realmGenericPoints {
                _genericPointData = realmGenericPoints.genericPointData()
                logger.log(message: "Generic points loaded successfully.")
            } else {
                logger.log(message: "No generic points found in the repository.")
            }
        } catch {
            logger.log(message: "Failed to load generic points: \(error.localizedDescription)")
        }
    }
    
    private func loadUserRanks() async {
        do {
            let realmUserRanks = try rankingRepo.getAll().first
            if let realmUserRanks = realmUserRanks {
                _userRankData = realmUserRanks.userRankData()
                logger.log(message: "User ranks loaded successfully.")
            } else {
                logger.log(message: "No user ranks found in the repository.")
            }
        } catch {
            logger.log(message: "Failed to load user ranks: \(error.localizedDescription)")
        }
    }
    
    private func loadCheckSumData() async {
        do {
            let realmCheckSumData = try checkSumRepo.getAll().first
            if let realmCheckSumData = realmCheckSumData {
                _checkSumData = realmCheckSumData.checkSumData()
                logger.log(message: "CheckSum data loaded successfully.")
            } else {
                logger.log(message: "No CheckSum data found in the repository.")
            }
        } catch {
            logger.log(message: "Failed to load CheckSum data: \(error.localizedDescription)")
        }
    }
}
