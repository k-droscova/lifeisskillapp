//
//  CategoryRepository.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 07.08.2024.
//

import Foundation
import RealmSwift

protocol HasRealmCategoryRepository {
    var realmCategoryRepository: any RealmUserCategoryRepositoring { get set }
}

protocol RealmUserCategoryRepositoring: RealmRepositoring where Entity == RealmUserCategoryData {}

public class RealmUserCategoryRepository: BaseClass, RealmUserCategoryRepositoring, HasRealmStoraging, HasLoggers {
    typealias Entity = RealmUserCategoryData
    typealias Dependencies = HasRealmStoraging & HasLoggers
    
    public let logger: LoggerServicing
    var realmStorage: RealmStoraging
    
    init(dependencies: Dependencies) {
        self.logger = dependencies.logger
        self.realmStorage = dependencies.realmStorage
    }
}
