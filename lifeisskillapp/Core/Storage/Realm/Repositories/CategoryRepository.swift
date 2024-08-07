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

protocol RealmCategoryRepositoring: RealmRepositoring where Entity == RealmCategory {}

public class RealmCategoryRepository: BaseClass, RealmCategoryRepositoring, HasRealmStoraging, HasLoggers {
    typealias Entity = RealmCategory
    typealias Dependencies = HasRealmStoraging & HasLoggers
    
    public let logger: LoggerServicing
    var realmStorage: RealmStoraging
    
    init(dependencies: Dependencies) {
        self.logger = dependencies.logger
        self.realmStorage = dependencies.realmStorage
    }
}
