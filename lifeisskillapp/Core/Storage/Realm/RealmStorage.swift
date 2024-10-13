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

final class RealmStorage: BaseClass, RealmStoraging {
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
            let realm = try Realm(configuration: configurations)
            print("Realm initialized successfully at \(realm.configuration.fileURL?.absoluteString ?? "")")
            return realm
        } catch {
            logger.log(message: "REALM INIT ERROR: \(error.localizedDescription)")
            return nil
        }
    }
    
    // MARK: - Private Helpers
    
    private func setupConfig() {
        // Define the Realm file URL
        let realmFileURL = configurations.fileURL!.deletingLastPathComponent().appendingPathComponent(RealmConstants.storageFile)
        configurations.schemaVersion = 2
        configurations.migrationBlock = { migration, oldSchemaVersion in
            if oldSchemaVersion < 2 {
                migration.deleteData(forType: RealmCheckSumData.className())
                migration.deleteData(forType: RealmLoginDetails.className())
                migration.deleteData(forType: RealmCategory.className())
                migration.deleteData(forType: RealmUserCategoryData.className())
                migration.deleteData(forType: RealmUserRankData.className())
                migration.deleteData(forType: RealmUserRank.className())
                migration.deleteData(forType: RealmRankedUser.className())
                migration.deleteData(forType: RealmGenericPointData.className())
                migration.deleteData(forType: RealmGenericPoint.className())
                migration.deleteData(forType: RealmPointParam.className())
                migration.deleteData(forType: RealmTimerParam.className())
                migration.deleteData(forType: RealmStatusParam.className())
                migration.deleteData(forType: RealmUserPointData.className())
                migration.deleteData(forType: RealmUserPoint.className())
                migration.deleteData(forType: RealmScannedPoint.className())
                migration.deleteData(forType: RealmUserLocation.className())
                migration.deleteData(forType: RealmSponsorData.className())
            }
        }
        
        configurations.fileURL = realmFileURL
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
            RealmUserLocation.self,
            RealmSponsorData.self
        ]
    }
}
