//
//  AppDependencies.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 01.07.2024.
//

import Foundation

let appDependencies = AppDependency()

typealias HasBaseNetwork = HasNetwork & HasUrlSessionWrapper
typealias HasAPIDependencies = HasRegisterAppAPIService & HasLoginAPIService
typealias HasManagers = HasUserManager


final class AppDependency {
    lazy var userManager: UserManaging = UserManager(dependencies: self)
    lazy var urlSession: URLSessionWrapping = URLSessionWrapper()
    lazy var network: Networking = Network(dependencies: self)
    lazy var logger: LoggerServicing = OSLoggerService()
    lazy var registerAppAPI: RegisterAppAPIServicing = RegisterAppAPIService(dependencies: self)
    lazy var loginAPI: LoginAPIServicing = LoginAPIService(dependencies: self)
}

extension AppDependency: HasBaseNetwork {}
extension AppDependency: HasAPIDependencies {}
extension AppDependency: HasManagers {}
extension AppDependency: HasLoggerServicing {}


