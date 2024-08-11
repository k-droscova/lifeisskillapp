//
//  RealmDependencies.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 07.08.2024.
//

import Foundation

typealias HasRealmRepositories = HasRealmLoginRepository & HasRealmCategoryRepository & HasRealmCheckSumRepository & HasRealmUserRankRepository & HasRealmUserPointRepository & HasRealmGenericPointRepository

protocol HasRepositoryContainer {
    var container: HasRealmRepositories { get set }
}

final class RepositoryContainer: HasRealmRepositories {
    var realmLoginRepository: any RealmLoginRepositoring = RealmLoginRepository(dependencies: appDependencies)
    var realmCategoryRepository: any RealmUserCategoryRepositoring = RealmUserCategoryRepository(dependencies: appDependencies)
    var realmCheckSumRepository: any RealmCheckSumRepositoring = RealmCheckSumRepository(dependencies: appDependencies)
    var realmUserRankRepository: any RealmUserRankRepositoring = RealmUserRankRepository(dependencies: appDependencies)
    var realmUserPointRepository: any RealmUserPointRepositoring = RealmUserPointRepository(dependencies: appDependencies)
    var realmPointRepository: any RealmGenericPointRepositoring = RealmGenericPointRepository(dependencies: appDependencies)
}

final class RealmUserDataStorageDependencies: HasLoggers, HasRealmRepositories {
    let logger: LoggerServicing
    var realmLoginRepository: any RealmLoginRepositoring
    var realmCategoryRepository: any RealmUserCategoryRepositoring
    var realmCheckSumRepository: any RealmCheckSumRepositoring
    var realmUserRankRepository: any RealmUserRankRepositoring
    var realmUserPointRepository: any RealmUserPointRepositoring
    var realmPointRepository: any RealmGenericPointRepositoring
    
    init(container: HasRealmRepositories, logger: LoggerServicing) {
        self.logger = logger
        self.realmLoginRepository = container.realmLoginRepository
        self.realmCategoryRepository = container.realmCategoryRepository
        self.realmCheckSumRepository = container.realmCheckSumRepository
        self.realmUserRankRepository = container.realmUserRankRepository
        self.realmUserPointRepository = container.realmUserPointRepository
        self.realmPointRepository = container.realmPointRepository
    }
}
