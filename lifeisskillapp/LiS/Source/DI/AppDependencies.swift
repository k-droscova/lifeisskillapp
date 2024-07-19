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
typealias HasUserDataManagers = HasUserCategoryManager & HasUserPointManager & HasGenericPointManager
typealias HasManagers = HasUserManager & HasLocationManager & HasUserDataManagers
typealias HasLoggers = HasLoggerServicing


final class AppDependency {
    lazy var userManager: UserManaging = {
        print("Initializing userManager")
        return UserManager(dependencies: self)
    }()
    
    lazy var locationManager: LocationManaging = {
        print("Initializing locationManager")
        return LocationManager(dependencies: self)
    }()
    
    lazy var urlSession: URLSessionWrapping = {
        print("Initializing urlSession")
        return URLSessionWrapper()
    }()
    
    lazy var userDefaultsStorage: UserDefaultsStoraging = {
        print("Initializing userDefaultsStorage")
        return UserDefaultsStorage(dependencies: self)
    }()
    
    lazy var userDataStorage: UserDataStoraging = {
        print("Initializing userDataStorage")
        return UserDataStorage(dependencies: self)
    }()
    
    lazy var network: Networking = {
        print("Initializing network")
        return Network(dependencies: self)
    }()
    
    lazy var logger: LoggerServicing = {
        print("Initializing logger")
        return OSLoggerService()
    }()
    
    lazy var registerAppAPI: RegisterAppAPIServicing = {
        print("Initializing registerAppAPI")
        return RegisterAppAPIService(dependencies: self)
    }()
    
    lazy var loginAPI: LoginAPIServicing = {
        print("Initializing loginAPI")
        return LoginAPIService(dependencies: self)
    }()
    
    lazy var checkSumAPI: CheckSumAPIServicing = {
        print("Initializing checkSumAPI")
        return CheckSumAPIService(dependencies: self)
    }()
    
    lazy var userDataAPI: UserDataAPIServicing = {
        print("Initializing userDataAPI")
        return UserDataAPIService(dependencies: self)
    }()
    
    lazy var userPointManager: any UserPointManaging = {
        print("Initializing userPointManager")
        return UserPointManager(dependencies: self)
    }()
    
    lazy var userCategoryManager: any UserCategoryManaging = {
        print("Initializing userCategoryManager")
        return UserCategoryManager(dependencies: self)
    }()
    
    lazy var genericPointManager: any GenericPointManaging = {
        print("Initializing genericPointManager")
        return GenericPointManager(dependencies: self)
    }()
}

extension AppDependency: HasBaseNetwork {}
extension AppDependency: HasAPIDependencies {}
extension AppDependency: HasManagers {}
extension AppDependency: HasLoggers {}
extension AppDependency: HasStorage {}


