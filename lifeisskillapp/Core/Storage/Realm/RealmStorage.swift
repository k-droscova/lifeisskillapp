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
        
        // Set the schema version. This must be incremented whenever schema changes
        configurations.schemaVersion = 2 // first migration -> renamind *Id to *ID
        
        // Set the migration block
        configurations.migrationBlock = { migration, oldSchemaVersion in
            if oldSchemaVersion < 1 {
                // do nothing
            }
            if oldSchemaVersion < 2 {
                migration.renameProperty(onType: RealmCheckSumData.className(), from: "id", to: "checkSumID")
                migration.renameProperty(onType: RealmLoginDetails.className(), from: "userId", to: "userID")
                migration.renameProperty(onType: RealmUser.className(), from: "userId", to: "userID")
                migration.renameProperty(onType: RealmCategory.className(), from: "categoryId", to: "categoryID")
                migration.renameProperty(onType: RealmRanking.className(), from: "rankingId", to: "rankingID")
                migration.renameProperty(onType: RealmRanking.className(), from: "userId", to: "userID")
                migration.renameProperty(onType: RealmRanking.className(), from: "categoryId", to: "categoryID")
                migration.renameProperty(onType: RealmPoint.className(), from: "pointId", to: "pointID")
                migration.renameProperty(onType: RealmPoint.className(), from: "sponsorId", to: "sponsorID")
                migration.renameProperty(onType: RealmPointScan.className(), from: "scanId", to: "scanID")
            }
        }
        
        configurations.objectTypes = [
            RealmCheckSumData.self,
            RealmLoginDetails.self,
            RealmUser.self,
            RealmCategory.self,
            RealmRanking.self,
            RealmPoint.self,
            RealmPointParam.self,
            RealmTimerParam.self,
            RealmStatusParam.self,
            RealmPointScan.self
        ]
    }
}
