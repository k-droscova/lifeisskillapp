//
//  CategoryRepository.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 07.08.2024.
//

import Foundation
import RealmSwift

protocol HasRealmCategoryRepository {
    var realmCategoryRepository: any RealmCategoryRepositoring { get set }
}

protocol RealmCategoryRepositoring: RealmRepositoring where Entity == RealmCategory {
    func getRankingsForCategory(byCategoryID categoryID: String) -> [RealmRanking]?
    func updateCategories(categories: [RealmCategory]) throws
}

public class RealmCategoryRepository: BaseClass, RealmCategoryRepositoring, HasRealmStoraging, HasLoggers {
    typealias Entity = RealmCategory
    typealias Dependencies = HasRealmStoraging & HasLoggers
    
    public let logger: LoggerServicing
    var realmStorage: RealmStoraging
    
    init(dependencies: Dependencies) {
        self.logger = dependencies.logger
        self.realmStorage = dependencies.realmStorage
    }
    
    func getRankingsForCategory(byCategoryID categoryID: String) -> [RealmRanking]? {
        guard let category = getById(categoryID) else { return nil }
        return Array(category.rankings)
    }
    
    func updateCategories(categories: [RealmCategory]) throws {
        guard let realm = realmStorage.getRealm() else {
            logger.log(message: "Failed to get Realm instance")
            return
        }
        try realm.write {
            for category in categories {
                realm.add(category, update: .modified)
            }
        }
    }
}
