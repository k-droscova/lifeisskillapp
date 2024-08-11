//
//  PointScanRepository.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 07.08.2024.
//

import Foundation
import RealmSwift

protocol HasRealmPointScanRepository {
    var realmPointScanRepository: any RealmPointScanRepositoring { get set }
}

protocol RealmPointScanRepositoring: RealmRepositoring where Entity == RealmPointScan {
    func update(_ pointScans: [RealmPointScan]) throws
    func clear(forUser user: RealmUser) throws
}

public class RealmPointScanRepository: BaseClass, RealmPointScanRepositoring, HasRealmStoraging, HasLoggers {
    typealias Entity = RealmPointScan
    typealias Dependencies = HasRealmStoraging & HasLoggers
    
    public let logger: LoggerServicing
    var realmStorage: RealmStoraging
    
    init(dependencies: Dependencies) {
        self.logger = dependencies.logger
        self.realmStorage = dependencies.realmStorage
    }
    
    func update(_ pointScans: [RealmPointScan]) throws {
        guard let realm = realmStorage.getRealm() else {
            throw BaseError(context: .database, message: "Failed to get Realm instance", logger: logger)
        }
        try realm.write {
            realm.add(pointScans, update: .modified)
        }
    }
    
    func clear(forUser user: RealmUser) throws {
        guard let realm = realmStorage.getRealm() else {
            throw BaseError(context: .database, message: "Failed to get Realm instance", logger: logger)
        }
        try realm.write {
            let userPoints = realm.objects(RealmPointScan.self).filter("userID == %@", user.userID)
            realm.delete(userPoints)
        }
    }
}
