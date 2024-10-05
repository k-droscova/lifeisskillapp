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
            return try Realm(configuration: configurations)
        } catch {
            logger.log(message: "REALM INIT ERROR: \(error.localizedDescription)")
            return nil
        }
    }
    
    // MARK: - Private Helpers
    
    private func setupConfig() {
        // Define the Realm file URL
        let realmFileURL = configurations.fileURL!.deletingLastPathComponent().appendingPathComponent(RealmConstants.storageFile)
        configurations.schemaVersion = 1
        configurations.migrationBlock = nil
        
        // Common setup
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
