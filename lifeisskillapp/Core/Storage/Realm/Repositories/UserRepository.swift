//
//  UserRepository.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 07.08.2024.
//

import Foundation
import RealmSwift

protocol HasRealmUserRepository {
    var realmUserRepository: any RealmUserRepositoring { get set }
}

protocol RealmUserRepositoring: RealmRepositoring where Entity == RealmUser {
    func clearUserCategories(forUser user: RealmUser) throws
    func updateUserCategories(forUser user: RealmUser, categories: [String], mainCategory: String?) throws
}

public class RealmUserRepository: BaseClass, RealmUserRepositoring, HasRealmStoraging, HasLoggers {
    typealias Entity = RealmUser
    typealias Dependencies = HasRealmStoraging & HasLoggers
    
    public let logger: LoggerServicing
    var realmStorage: RealmStoraging
    
    init(dependencies: Dependencies) {
        self.logger = dependencies.logger
        self.realmStorage = dependencies.realmStorage
    }
    
    func clearUserCategories(forUser user: RealmUser) throws {
        guard let realm = realmStorage.getRealm() else {
            throw BaseError(context: .database, message: "Failed to get realm", logger: logger)
        }
        
        try realm.write {
            user.categories.removeAll()
            user.mainCategory = ""
            realm.add(user, update: .modified)
        }
    }
    
    func updateUserCategories(forUser user: RealmUser, categories: [String], mainCategory: String? = nil) throws {
        guard let realm = realmStorage.getRealm() else {
            throw BaseError(context: .database, message: "Failed to get realm", logger: logger)
        }
        
        try realm.write {
            // Step 1: Identify the categories to remove
            let currentCategoryIDs = Set(user.categories.map { $0.categoryID })
            let newCategoryIDs = Set(categories)
            
            let categoriesToRemove = currentCategoryIDs.subtracting(newCategoryIDs)
            let categoriesToAdd = newCategoryIDs.subtracting(currentCategoryIDs)
            
            // Step 2: Remove old categories
            for categoryID in categoriesToRemove {
                if let category = realm.object(ofType: RealmCategory.self, forPrimaryKey: categoryID) {
                    if let index = user.categories.index(of: category) {
                        user.categories.remove(at: index)
                    }
                }
            }
            
            // Step 3: Add new categories
            for categoryID in categoriesToAdd {
                if let category = realm.object(ofType: RealmCategory.self, forPrimaryKey: categoryID) {
                    user.categories.append(category)
                } else {
                    // Log a warning if the category does not exist
                    logger.log(message: "Category with ID \(categoryID) does not exist and cannot be added.")
                }
            }
            
            // Step 4: Update the main category if provided
            if let mainCategory = mainCategory {
                user.mainCategory = mainCategory
            }
            
            // Save the updated user object
            realm.add(user, update: .modified)
        }
    }
}
