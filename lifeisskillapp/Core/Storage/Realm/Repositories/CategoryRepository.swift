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
    func update(categories: [RealmCategory]) throws
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
    
    func update(categories: [RealmCategory]) throws {
        guard let realm = realmStorage.getRealm() else {
            throw BaseError(context: .database, message: "Failed to get Realm instance", logger: logger)
        }
        try realm.write {
            realm.add(categories, update: .modified)
        }
    }
}
