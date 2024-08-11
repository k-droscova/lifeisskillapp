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
