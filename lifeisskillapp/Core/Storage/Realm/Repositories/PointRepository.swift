//
//  PointRepository.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 07.08.2024.
//

import Foundation
import RealmSwift

protocol HasRealmPointRepository {
    var realmPointRepository: any RealmPointRepositoring { get set }
}

protocol RealmPointRepositoring: RealmRepositoring where Entity == RealmPoint {
    func update(_ points: [RealmPoint]) throws
}

public class RealmPointRepository: BaseClass, RealmPointRepositoring, HasRealmStoraging, HasLoggers {
    typealias Entity = RealmPoint
    typealias Dependencies = HasRealmStoraging & HasLoggers
    
    public let logger: LoggerServicing
    var realmStorage: RealmStoraging
    
    init(dependencies: Dependencies) {
        self.logger = dependencies.logger
        self.realmStorage = dependencies.realmStorage
    }
    
    func update(_ points: [RealmPoint]) throws {
        guard let realm = realmStorage.getRealm() else {
            throw BaseError(context: .database, message: "Failed to get Realm instance", logger: logger)
        }
        try realm.write {
            realm.add(points, update: .modified)
        }
    }
}
