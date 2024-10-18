//
//  AppDependencies.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 01.07.2024.
//

import Foundation

let appDependencies = AppDependency()

typealias HasBaseNetwork = HasNetwork & HasUrlSessionWrapper & HasNetworkMonitor
typealias HasAPIDependencies = HasRegisterAppAPIService & HasRegisterUserAPIService & HasLoginAPIService & HasCheckSumAPIService & HasUserDataAPIService & HasForgotPasswordAPIService
typealias HasKeychain = HasKeychainHelper & HasKeychainStorage
typealias HasStorage = HasUserDefaultsStorage & HasUserDataStorage & HasKeychainHelper & HasKeychain
typealias HasUserDataManagers = HasUserCategoryManager & HasUserPointManager & HasGenericPointManager & HasUserRankManager
typealias HasManagers = HasUserManager & HasLocationManager & HasUserDataManagers & HasScanningManager & HasGameDataManager
typealias HasLoggers = HasLoggerServicing
typealias HasRealm = HasRealmStoraging & HasRepositoryContainer & HasPersistentUserDataStoraging

final class AppDependency {
    // MARK: logger
    
    lazy var logger: LoggerServicing = OSLoggerService()
    
    // MARK: network
    
    lazy var networkMonitor: NetworkMonitoring = NetworkMonitor(dependencies: self)
    lazy var urlSession: URLSessionWrapping = URLSessionWrapper()
    lazy var network: Networking = Network(dependencies: self)
    lazy var registerAppAPI: RegisterAppAPIServicing = RegisterAppAPIService(dependencies: self)
    lazy var registerUserAPI: RegisterUserAPIServicing = RegisterUserAPIService(dependencies: self)
    lazy var loginAPI: LoginAPIServicing = LoginAPIService(dependencies: self)
    lazy var forgotPasswordAPI: ForgotPasswordAPIServicing = ForgotPasswordAPIService(dependencies: self)
    lazy var checkSumAPI: CheckSumAPIServicing = CheckSumAPIService(dependencies: self)
    lazy var userDataAPI: UserDataAPIServicing = UserDataAPIService(dependencies: self)
    
    // MARK: storage
    
    lazy var userDefaultsStorage: UserDefaultsStoraging = UserDefaultsStorage(dependencies: self)
    lazy var userDataStorage: UserDataStoraging = InMemoryUserDataStorage(dependencies: self)
    lazy var keychainHelper: KeychainHelping = KeychainHelper(dependencies: self)
    lazy var keychainStorage: KeychainStoraging = KeychainStorage(dependencies: self)
    
    // MARK: realm
    
    lazy var realmStorage: RealmStoraging = RealmStorage(dependencies: self)
    lazy var container: HasRealmRepositories = RepositoryContainer()
    lazy var storage: any PersistentUserDataStoraging = {
        let realmDependencies = RealmUserDataStorageDependencies(container: self.container, logger: self.logger)
        return RealmUserDataStorage(dependencies: realmDependencies)
    }()
    
    // MARK: user and data managers
    
    lazy var userManager: UserManaging = UserManager(dependencies: self)
    lazy var locationManager: LocationManaging = LocationManager(dependencies: self)
    lazy var gameDataManager: GameDataManaging = GameDataManager(dependencies: self)
    lazy var userPointManager: any UserPointManaging = UserPointManager(dependencies: self)
    lazy var userCategoryManager: any UserCategoryManaging = UserCategoryManager(dependencies: self)
    lazy var genericPointManager: any GenericPointManaging = GenericPointManager(dependencies: self)
    lazy var userRankManager: any UserRankManaging = UserRankManager(dependencies: self)
    lazy var scanningManager: ScanningManaging = ScanningManager(dependencies: self)
}

extension AppDependency: HasBaseNetwork {}
extension AppDependency: HasAPIDependencies {}
extension AppDependency: HasManagers {}
extension AppDependency: HasLoggers {}
extension AppDependency: HasStorage {}
extension AppDependency: HasRealm {}
