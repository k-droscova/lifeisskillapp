//
//  CheckSumRepository.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 07.08.2024.
//

import Foundation
import RealmSwift

protocol HasRealmCheckSumRepository {
    var realmCheckSumRepository: any RealmCheckSumRepositoring { get set }
}

protocol RealmCheckSumRepositoring: RealmRepositoring where Entity == RealmCheckSumData {
    func deleteUserSpecificCheckSums() throws
}

public class RealmCheckSumRepository: BaseClass, RealmCheckSumRepositoring, HasRealmStoraging, HasLoggers {
    typealias Entity = RealmCheckSumData
    typealias Dependencies = HasRealmStoraging & HasLoggers
    
    public let logger: LoggerServicing
    var realmStorage: RealmStoraging
    
    init(dependencies: Dependencies) {
        self.logger = dependencies.logger
        self.realmStorage = dependencies.realmStorage
    }
    
    func deleteUserSpecificCheckSums() throws {
        guard let realm = realmStorage.getRealm() else {
            throw BaseError(
                context: .database,
                message: "Realm is not initialized",
                logger: logger
            )
        }
        
        try realm.write {
            if let checkSumData = realm.objects(RealmCheckSumData.self).first {
                checkSumData.userPoints = ""
                checkSumData.rank = ""
                checkSumData.messages = ""
                checkSumData.events = ""
                realm.add(checkSumData, update: .modified)
                logger.log(message: "User-specific checksums cleared, generic points checksum retained.")
            } else {
                logger.log(message: "No CheckSum data found to clear.")
            }
        }
    }
}
