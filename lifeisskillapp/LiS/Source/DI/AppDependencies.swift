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
typealias HasUserDataManagers = HasUserCategoryManager & HasUserPointManager
typealias HasManagers = HasUserManager & HasLocationManager & HasUserDataManagers
typealias HasLoggers = HasLoggerServicing


final class AppDependency {
    lazy var userManager: UserManaging = UserManager(dependencies: self)
    lazy var locationManager: LocationManaging = LocationManager(dependencies: self)
    lazy var urlSession: URLSessionWrapping = URLSessionWrapper()
    lazy var userDefaultsStorage: UserDefaultsStoraging = UserDefaultsStorage(dependencies: self)
    lazy var userDataStorage: UserDataStoraging = UserDataStorage(dependencies: self)
    lazy var network: Networking = Network(dependencies: self)
    lazy var logger: LoggerServicing = OSLoggerService()
    lazy var registerAppAPI: RegisterAppAPIServicing = RegisterAppAPIService(dependencies: self)
    lazy var loginAPI: LoginAPIServicing = LoginAPIService(dependencies: self)
    lazy var checkSumAPI: CheckSumAPIServicing = CheckSumAPIService(dependencies: self)
    lazy var userDataAPI: UserDataAPIServicing = UserDataAPIService(dependencies: self)
    lazy var userPointManager: UserPointManaging = UserPointManager(dependencies: self)
    lazy var userCategoryManager: UserCategoryManaging = UserCategoryManager(dependencies: self)

}

extension AppDependency: HasBaseNetwork {}
extension AppDependency: HasAPIDependencies {}
extension AppDependency: HasManagers {}
extension AppDependency: HasLoggers {}
extension AppDependency: HasStorage {}


