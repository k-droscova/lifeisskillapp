//
//  RealmDependencies.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 07.08.2024.
//

import Foundation

typealias HasRealmRepositories = HasRealmUserRepository & HasRealmLoginRepository & HasRealmPointRepository & HasRealmRankingRepository & HasRealmCategoryRepository & HasRealmCheckSumRepository & HasRealmPointScanRepository

protocol HasRepositoryContainer {
    var container: HasRealmRepositories { get set }
}

final class RepositoryContainer: HasRealmRepositories {
    lazy var realmLoginRepository: any RealmLoginRepositoring = RealmLoginRepository(dependencies: appDependencies)
    lazy var realmUserRepository: any RealmUserRepositoring = RealmUserRepository(dependencies: appDependencies)
    lazy var realmCheckSumRepository: any RealmCheckSumRepositoring = RealmCheckSumRepository(dependencies: appDependencies)
    lazy var realmPointRepository: any RealmPointRepositoring = RealmPointRepository(dependencies: appDependencies)
    lazy var realmRankingRepository: any RealmRankingRepositoring = RealmRankingRepository(dependencies: appDependencies)
    lazy var realmCategoryRepository: any RealmCategoryRepositoring = RealmCategoryRepository(dependencies: appDependencies)
    lazy var realmPointScanRepository: any RealmPointScanRepositoring = RealmPointScanRepository(dependencies: appDependencies)
}
