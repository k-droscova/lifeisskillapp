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
            return try DispatchQueue.global(qos: .userInitiated).sync {
                return try Realm(configuration: configurations)
            }
        } catch {
            logger.log(message: "REALM INIT ERROR: \(error.localizedDescription)")
            return nil
        }
    }
    
    // MARK: - Private Helpers
    
    private func setupConfig() {
#if DEBUG
        // Define the Realm file URL
        let realmFileURL = configurations.fileURL!.deletingLastPathComponent().appendingPathComponent("LifeIsSkill.realm")
        
        // Check if the Realm file exists and delete it
        if FileManager.default.fileExists(atPath: realmFileURL.path) {
            do {
                try FileManager.default.removeItem(at: realmFileURL)
                print("Existing Realm file deleted in DEBUG mode.")
            } catch {
                print("Error deleting Realm file: \(error)")
            }
        }
        
        // Reset schema version for development
        configurations.schemaVersion = 1
        // No need for a migration block in development mode
        configurations.migrationBlock = nil
        
#else
        // Define the schema version for production or other environments
        configurations.schemaVersion = 1
        
        // Set the migration block for production
        configurations.migrationBlock = { migration, oldSchemaVersion in
            if oldSchemaVersion < 1 {
                // do nothing
            }
        }
#endif
        
        // Common setup
        configurations.fileURL = configurations.fileURL!.deletingLastPathComponent().appendingPathComponent("LifeIsSkill.realm")
        configurations.objectTypes = [
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
            RealmUserPoint.self,
            RealmScannedPoint.self,
            RealmUserLocation.self
        ]
    }
}
