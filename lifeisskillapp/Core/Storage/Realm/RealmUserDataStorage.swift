//
//  RealmUserDataStorage.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 10.08.2024.
//

import Foundation
import RealmSwift

public final class RealmUserDataStorage: UserDataStoraging {
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
            setUserCategories(data: userCategoryData)
        }
    }
    var userPointData: UserPointData?
    var genericPointData: GenericPointData?
    var userRankData: UserRankData?
    var loginData: LoginUserData?
    
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
        
        Task {
            await self.loadData()
        }
    }
    
    // MARK: - Private Helpers
    
    private func loadData() async {
        // Run the data loading functions concurrently
        async let categories: () = loadCategoriesFromRepo()
        async let points: () = loadUserPoints()
        async let genericPoints: () = loadGenericPoints()
        async let ranks: () = loadUserRanks()
        async let login: () = loadLoginData()
        
        // Await the results
        await categories
        await points
        await genericPoints
        await ranks
        await login
    }
    
    // MARK: - getters
    
    private func loadCategoriesFromRepo() async {
        guard let userID = getLoggedInUserId() else {
            return
        }
        guard let user = getUserInfo(userID) else {
            return
        }
        // create new categories
        let categories: [UserCategory] = user.categories.map { realmCategory in
            return UserCategory(
                id: realmCategory.categoryID,
                name: realmCategory.name,
                detail: realmCategory.detail,
                isPublic: realmCategory.isPublic
            )
        }
        // find the users maincategory
        if let mainCategory = categories.first(where: { $0.id == user.mainCategory }) {
            self.userCategoryData = UserCategoryData(main: mainCategory, data: categories)
        } else {
            logger.log(message: "No matching main category found for user ID: \(userID)")
        }
    }
    
    private func loadUserPoints() async {
        
    }
    
    private func loadGenericPoints() async {
        
    }
    
    private func loadUserRanks() async {
        
    }
    
    private func loadLoginData() async {
        
    }
    
    // MARK: - setters
    
    private func setUserCategories(data: UserCategoryData?) {
        guard let userID = getLoggedInUserId() else {
            return
        }
        guard let user = getUserInfo(userID) else {
            return
        }
        
        do {
            // handle case when new data is nil
            guard let newData = data else {
                logger.log(message: "Deleting user categories for \(userID)")
                try userRepo.clearUserCategories(forUser: user)
                return
            }
            // Convert UserCategory data to RealmCategory instances
            let realmCategories = newData.data.map { RealmCategory(from: $0) }
            
            // Ensure all categories exist
            try categoryRepo.updateCategories(categories: realmCategories)
            
            // Update user categories
            let categoryIDs = realmCategories.map { $0.categoryID }
            try userRepo.updateUserCategories(forUser: user, categories: categoryIDs, mainCategory: newData.main.id)
            
        } catch {
            logger.log(message: "ERROR while setting new value for user categories.")
        }
    }
    
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
