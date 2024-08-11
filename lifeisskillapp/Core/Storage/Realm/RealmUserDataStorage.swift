//
//  RealmUserDataStorage.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 10.08.2024.
//

import Foundation
import RealmSwift

enum PersistentDataType {
    case categories, userPoints, genericPoints, rankings, login, checkSum
}

protocol HasPersistentUserDataStoraging {
    var storage: PersistentUserDataStoraging { get }
}

protocol PersistentUserDataStoraging: UserDataStoraging {
    func loadFromRepository(for data: PersistentDataType) async
    func saveUserCategories(data: UserCategoryData?) async
    func saveUserPoints(data: UserPointData?) async
    func saveGenericPoints(data: GenericPointData?) async
    func saveUserRanks(data: UserRankData?) async
    func saveLoginData(data: LoginUserData?) async
    func saveCheckSumData(data: CheckSumData?) async
}

public final class RealmUserDataStorage: PersistentUserDataStoraging {
    typealias Dependencies = HasLoggers & HasRealmRepositories
    
    // MARK: - Private Properties
    
    private let logger: LoggerServicing
    private var loginRepo: any RealmLoginRepositoring
    private var checkSumRepo: any RealmCheckSumRepositoring
    private var categoryRepo: any RealmUserCategoryRepositoring
    private var rankingRepo: any RealmUserRankRepositoring
    private var genericPointRepo: any RealmGenericPointRepositoring
    private var userPointRepo: any RealmUserPointRepositoring
    
    // MARK: - Public Properties
    
    var userCategoryData: UserCategoryData?
    var userPointData: UserPointData?
    var genericPointData: GenericPointData?
    var userRankData: UserRankData?
    var loginData: LoginUserData?
    var checkSumData: CheckSumData?
    
    // MARK: - Initialization
    
    init(dependencies: Dependencies) {
        self.logger = dependencies.logger
        self.loginRepo = dependencies.realmLoginRepository
        self.checkSumRepo = dependencies.realmCheckSumRepository
        self.categoryRepo = dependencies.realmCategoryRepository
        self.rankingRepo = dependencies.realmUserRankRepository
        self.genericPointRepo = dependencies.realmPointRepository
        self.userPointRepo = dependencies.realmUserPointRepository
    }
    
    // MARK: - Public Interface
    
    func loadFromRepository(for data: PersistentDataType) async {
        switch data {
        case .userPoints:
            await loadUserPoints()
        case .genericPoints:
            await loadGenericPoints()
        case .rankings:
            await loadUserRanks()
        case .login:
            await loadLoginData()
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
        }
    }

    // MARK: - Private Helpers
    
    private func loadCategories() async {
        do {
            let realmCategoryData = try categoryRepo.getAll().first
            if let realmCategoryData = realmCategoryData {
                userCategoryData = realmCategoryData.toUserCategoryData()
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
                userPointData = realmUserPoints.toUserPointData()
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
                genericPointData = realmGenericPoints.toGenericPointData()
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
                userRankData = realmUserRanks.toUserRankData()
                logger.log(message: "User ranks loaded successfully.")
            } else {
                logger.log(message: "No user ranks found in the repository.")
            }
        } catch {
            logger.log(message: "Failed to load user ranks: \(error.localizedDescription)")
        }
    }
    
    private func loadLoginData() async {
        do {
            let realmLoginDetails = try loginRepo.getAll().first
            if let realmLoginDetails = realmLoginDetails {
                loginData = realmLoginDetails.toLoginData()
                logger.log(message: "Login data loaded successfully.")
            } else {
                logger.log(message: "No login data found in the repository.")
            }
        } catch {
            logger.log(message: "Failed to load login data: \(error.localizedDescription)")
        }
    }
    
    private func loadCheckSumData() async {
        do {
            let realmCheckSumData = try checkSumRepo.getAll().first
            if let realmCheckSumData = realmCheckSumData {
                checkSumData = realmCheckSumData.toCheckSumData()
                logger.log(message: "CheckSum data loaded successfully.")
            } else {
                logger.log(message: "No CheckSum data found in the repository.")
            }
        } catch {
            logger.log(message: "Failed to load CheckSum data: \(error.localizedDescription)")
        }
    }
}
