//
//  AppDependencies.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 01.07.2024.
//

import Foundation

let appDependencies = AppDependency()

typealias HasBaseNetwork = HasNetwork & HasUrlSessionWrapper
typealias HasAPIDependencies = HasRegisterAppAPIService & HasLoginAPIService & HasCheckSumAPIService & HasUserDataAPIService
typealias HasStorage = HasUserDefaultsStorage & HasUserDataStorage
typealias HasUserDataManagers = HasGameDataManager & HasUserCategoryManager & HasUserPointManager & HasGenericPointManager & HasUserRankManager & HasUserLoginManager
typealias HasManagers = HasUserManager & HasLocationManager & HasUserDataManagers
typealias HasLoggers = HasLoggerServicing


final class AppDependency {
    // MARK: logger
    
    lazy var logger: LoggerServicing = OSLoggerService()
    
    // MARK: network
    
    lazy var urlSession: URLSessionWrapping = URLSessionWrapper()
    lazy var network: Networking = Network(dependencies: self)
    lazy var registerAppAPI: RegisterAppAPIServicing = RegisterAppAPIService(dependencies: self)
    lazy var loginAPI: LoginAPIServicing = LoginAPIService(dependencies: self)
    lazy var checkSumAPI: CheckSumAPIServicing = CheckSumAPIService(dependencies: self)
    lazy var userDataAPI: UserDataAPIServicing = UserDataAPIService(dependencies: self)
    
    // MARK: storage
    
    lazy var userDefaultsStorage: UserDefaultsStoraging = UserDefaultsStorage(dependencies: self)
    lazy var userDataStorage: UserDataStoraging = UserDataStorage(dependencies: self)
    
    // MARK: user and data managers
    
    lazy var userManager: UserManaging = UserManager(dependencies: self)
    lazy var locationManager: LocationManaging = LocationManager(dependencies: self)
    lazy var gameDataManager: GameDataManaging = GameDataManager(dependencies: self)
    lazy var userPointManager: any UserPointManaging = UserPointManager(dependencies: self)
    lazy var userCategoryManager: any UserCategoryManaging = UserCategoryManager(dependencies: self)
    lazy var genericPointManager: any GenericPointManaging = GenericPointManager(dependencies: self)
    lazy var userRankManager: any UserRankManaging = UserRankManager(dependencies: self)
    lazy var userLoginManager: UserLoginDataManaging = UserLoginDataManager(dependencies: self)
}

extension AppDependency: HasBaseNetwork {}
extension AppDependency: HasAPIDependencies {}
extension AppDependency: HasManagers {}
extension AppDependency: HasLoggers {}
extension AppDependency: HasStorage {}


