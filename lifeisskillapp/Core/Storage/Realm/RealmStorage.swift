//
//  RealmStorage.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 07.08.2024.
//

import Foundation
import RealmSwift

protocol HasRealmStoraging {
    var realmStorage: RealmStoraging { get }
}

protocol RealmStoraging {
    var configurations: Realm.Configuration { get }
    func getRealm() -> Realm?
}

public final class RealmStorage: BaseClass, RealmStoraging {
    typealias Dependencies = HasLoggers
    
    // MARK: - Private Properties
    
    private let logger: LoggerServicing
    
    // MARK: - Public Properties
    
    var realm: Realm?
    private(set) var configurations: Realm.Configuration = Realm.Configuration()
    
    // MARK: - Initialization
    
    init(dependencies: Dependencies) {
        self.logger = dependencies.logger
        super.init()
        self.setupConfig()
    }
    
    // MARK: - Public Interface
    
    func getRealm() -> Realm? {
        do {
            return try Realm(configuration: configurations)
        } catch {
            logger.log(message: "REALM INIT ERROR: \(error.localizedDescription)")
            return nil
        }
    }
    
    // MARK: - Private Helpers
    
    private func setupConfig() {
        // Set the file URL for the default Realm
        configurations.fileURL = configurations.fileURL!.deletingLastPathComponent().appendingPathComponent("LifeIsSkill.realm")
        
        // define object types in database
        let objectTypes = [
            RealmCheckSumData.self,
            RealmLoginDetails.self,
            RealmCategory.self,
            RealmUserCategoryData.self,
            RealmUserRankData.self,
            RealmUserRank.self,
            RealmRankedUser.self,
            RealmGenericPointData.self,
            RealmGenericPoint.self,
            RealmPointParam.self,
            RealmTimerParam.self,
            RealmStatusParam.self,
            RealmUserPointData.self,
            RealmPointScan.self
        ]
        
        // Set the schema version. This must be incremented whenever schema changes
        configurations.schemaVersion = 2 // Increment this whenever you update your schema
        
        // Set the migration block
        configurations.migrationBlock = { migration, oldSchemaVersion in
            if oldSchemaVersion < 1 {
                // do nothing
            }
            if oldSchemaVersion < 2 {
                for objectType in objectTypes {
                    migration.deleteData(forType: objectType.className())
                }
            }
        }
        
        configurations.objectTypes = objectTypes
    }
}
