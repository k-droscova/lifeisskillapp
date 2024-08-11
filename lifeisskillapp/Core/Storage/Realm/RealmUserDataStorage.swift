//
//  RealmUserDataStorage.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 10.08.2024.
//

import Foundation
import RealmSwift

enum PersistentDataType {
    case userPoints, genericPoints, ranks, login
}

protocol HasPersistentUserDataStoraging {
    var storage: PersistentUserDataStoraging { get }
}

protocol PersistentUserDataStoraging: UserDataStoraging {
    func loadFromRepository(forData: PersistentDataType) async
}

public final class RealmUserDataStorage: PersistentUserDataStoraging {
    typealias Dependencies = HasLoggers & HasRealmRepositories
    
    // MARK: - Private Properties
    
    private let logger: LoggerServicing
    private var loginRepo: any RealmLoginRepositoring
    private var checkSumRepo: any RealmCheckSumRepositoring
    private var userRepo: any RealmUserRepositoring
    private var categoryRepo: any RealmCategoryRepositoring
    private var rankingRepo: any RealmRankingRepositoring
    private var pointRepo: any RealmPointRepositoring
    private var pointScanRepo: any RealmPointScanRepositoring
    
    
    // MARK: - Public Properties
    
    var userCategoryData: UserCategoryData? {
        didSet {
            Task { [weak self] in
                await self?.setUserCategories(data: self?.userCategoryData)
            }
        }
    }
    var userPointData: UserPointData? {
        didSet {
            Task { [weak self] in
                await self?.setUserPoints(data: self?.userPointData)
            }
        }
    }
    var genericPointData: GenericPointData?
    var userRankData: UserRankData?
    var loginData: LoginUserData?
    var checkSumData: CheckSumData?
    
    // MARK: - Initialization
    
    init(dependencies: Dependencies) {
        self.logger = dependencies.logger
        self.loginRepo = dependencies.realmLoginRepository
        self.checkSumRepo = dependencies.realmCheckSumRepository
        self.userRepo = dependencies.realmUserRepository
        self.categoryRepo = dependencies.realmCategoryRepository
        self.rankingRepo = dependencies.realmRankingRepository
        self.pointRepo = dependencies.realmPointRepository
        self.pointScanRepo = dependencies.realmPointScanRepository
    }
    
    // MARK: - Public Interface
    
    func loadFromRepository(forData: PersistentDataType) async {
        switch forData {
        case .userPoints:
            await loadUserPoints()
        case .genericPoints:
            await loadGenericPoints()
        case .ranks:
            await loadUserRanks()
        case .login:
            await loadLoginData()
        }
    }
    
    // MARK: - getters
    
    private func loadUserPoints() async {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            guard let checkSum = self.checkSumData?.userPoints else {
                self.logger.log(message: "ERROR: cannot load user points when check sum is nil:\n \(checkSumData.debugDescription).")
                return
            }
            guard let userID = self.getLoggedInUserId() else {
                return
            }
            guard let user = self.getUserInfo(userID) else {
                return
            }
            
            do {
                // Step 1: Fetch all point scans for the user
                let pointScans = try self.pointScanRepo.getAll(forUser: user)
                
                // Step 2: Create UserPoint objects by fetching corresponding RealmPoint objects
                let userPoints = Array(
                    pointScans.compactMap { realmPointScan -> UserPoint? in
                        let pointID = realmPointScan.pointID
                        guard let realmPoint = self.pointRepo.getById(pointID) else {
                            self.logger.log(message: "ERROR: Could not find RealmPoint for pointID: \(realmPointScan.pointID)")
                            return nil
                        }
                        
                        return UserPoint(
                            id: realmPointScan.scanID,
                            recordKey: realmPointScan.scanID,
                            pointTime: realmPointScan.pointTime,
                            pointName: realmPoint.pointName,
                            pointValue: realmPoint.pointValue,
                            pointType: PointType(rawValue: realmPoint.pointType) ?? .unknown,
                            pointSpec: realmPoint.pointSpec,
                            pointLat: realmPoint.pointLat,
                            pointLng: realmPoint.pointLng,
                            pointAlt: realmPoint.pointAlt,
                            accuracy: realmPointScan.accuracy,
                            codeSource: CodeSource(rawValue: realmPointScan.codeSource) ?? .unknown,
                            pointCategory: Array(realmPointScan.pointCategory),
                            duration: realmPointScan.duration,
                            doesPointCount: realmPointScan.doesPointCount
                        )
                    }
                )
                
                // Step 3: Set the userPointData property
                let userPointData = UserPointData(checkSum: checkSum, data: userPoints)
                DispatchQueue.main.async {
                    self.userPointData = userPointData
                }
                
            } catch {
                self.logger.log(message: "ERROR while loading user points: \(error.localizedDescription)")
            }
        }
    }
    
    private func loadGenericPoints() async {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            guard let checkSum = self.checkSumData?.points else {
                self.logger.log(message: "ERROR: cannot load generic points when check sum is nil:\n \(self.checkSumData.debugDescription).")
                return
            }
            
            // Step 1: Fetch all generic points from the repository
            guard let realmPoints = self.pointRepo.getAll() else {
                self.logger.log(message: "There are no generic points to load")
                return
            }
            
            // Step 2: Convert the RealmPoint objects to GenericPoint objects
            let genericPoints = Array( realmPoints.map { GenericPoint(from: $0) } )

            // Step 3: Set the genericPointData property
            let genericPointData = GenericPointData(checkSum: checkSum, data: genericPoints)
            DispatchQueue.main.async {
                self.genericPointData = genericPointData
            }
        }
    }
    
    private func loadUserRanks() async {
        
    }
    
    private func loadLoginData() async {
        
    }
    
    // MARK: - setters
    
    private func setUserCategories(data: UserCategoryData?) async {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            guard let userID = self.getLoggedInUserId() else {
                return
            }
            guard let user = self.getUserInfo(userID) else {
                return
            }
            
            do {
                // Handle case when new data is nil
                guard let newData = data else {
                    self.logger.log(message: "Deleting user categories for \(userID)")
                    try self.userRepo.clear(forUser: user)
                    return
                }
                
                // Convert UserCategory data to RealmCategory instances
                let realmCategories = newData.data.map { RealmCategory(from: $0) }
                
                // Ensure all categories exist
                try self.categoryRepo.update(categories: realmCategories)
                
                // Update user categories
                let categoryIDs = realmCategories.map { $0.categoryID }
                try self.userRepo.update(forUser: user, categories: categoryIDs, mainCategory: newData.main.id)
            } catch {
                self.logger.log(message: "ERROR while setting new value for user categories.")
            }
        }
    }
    
    private func setUserPoints(data: UserPointData?) async {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            guard let userID = self.getLoggedInUserId() else {
                return
            }
            guard let user = self.getUserInfo(userID) else {
                return
            }
            do {
                guard let newData = data else {
                    self.logger.log(message: "No user points data provided.")
                    try self.pointScanRepo.clear(forUser: user)
                    return
                }
                let realmPoints = newData.data.map { RealmPoint(from: $0) }
                let realmPointScans = newData.data.map { RealmPointScan(from: $0, userID: userID) }
                try self.pointRepo.update(realmPoints)
                try self.pointScanRepo.update(realmPointScans)
            } catch {
                self.logger.log(message: "ERROR while setting new value for user points: \(error.localizedDescription)")
            }
        }
    }
}


// MARK: - Other Helpers
extension RealmUserDataStorage {
    private func getLoggedInUserId() -> String? {
        guard let userID = loginRepo.getLoggedInUserID() else {
            logger.log(message: "No logged-in user found in Realm")
            return nil
        }
        return userID
    }
    
    private func getUserInfo(_ id: String) -> RealmUser? {
        guard let user = userRepo.getById(id) else {
            logger.log(message: "No user found with ID: \(id)")
            return nil
        }
        return user
    }
}
