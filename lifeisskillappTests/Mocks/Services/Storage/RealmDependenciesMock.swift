//
//  RealmDependenciesMock.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 02.10.2024.
//

@testable import lifeisskillapp

final class RepositoryContainerMock: HasRealmRepositories {
    
    var realmLoginRepository: any RealmLoginRepositoring = RealmLoginRepositoryMock()
    var realmCategoryRepository: any RealmUserCategoryRepositoring = RealmUserCategoryRepositoryMock()
    var realmCheckSumRepository: any RealmCheckSumRepositoring = RealmCheckSumRepositoryMock()
    var realmUserRankRepository: any RealmUserRankRepositoring = RealmUserRankRepositoryMock()
    var realmUserPointRepository: any RealmUserPointRepositoring = RealmUserPointRepositoryMock()
    var realmPointRepository: any RealmGenericPointRepositoring = RealmGenericPointRepositoryMock()
    var realmScannedPointRepository: any RealmScannedPointRepositoring = RealmScannedPointRepositoryMock()
    var realmSponsorRepository: any RealmSponsorRepositoring = RealmSponsorRepositoryMock()
}

final class RealmUserDataStorageDependenciesMock: HasLoggers, HasRealmRepositories {
    
    let logger: LoggerServicing
    var realmLoginRepository: any RealmLoginRepositoring
    var realmCategoryRepository: any RealmUserCategoryRepositoring
    var realmCheckSumRepository: any RealmCheckSumRepositoring
    var realmUserRankRepository: any RealmUserRankRepositoring
    var realmUserPointRepository: any RealmUserPointRepositoring
    var realmPointRepository: any RealmGenericPointRepositoring
    var realmScannedPointRepository: any RealmScannedPointRepositoring
    var realmSponsorRepository: any RealmSponsorRepositoring
    
    init(container: HasRealmRepositories = RepositoryContainerMock(), logger: LoggerServicing = LoggingServiceMock()) {
        self.logger = logger
        self.realmLoginRepository = container.realmLoginRepository
        self.realmCategoryRepository = container.realmCategoryRepository
        self.realmCheckSumRepository = container.realmCheckSumRepository
        self.realmUserRankRepository = container.realmUserRankRepository
        self.realmUserPointRepository = container.realmUserPointRepository
        self.realmPointRepository = container.realmPointRepository
        self.realmScannedPointRepository = container.realmScannedPointRepository
        self.realmSponsorRepository = container.realmSponsorRepository
    }
}
