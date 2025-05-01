//
//  UserDefaultsStorage.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 10.07.2024.
//

import Foundation
import CoreLocation
import Combine

protocol HasUserDefaultsStorage {
    var userDefaultsStorage: UserDefaultsStoraging { get set }
}

protocol UserDefaultsStoraging {
    var appId: String? { get set }
    var isLoggedIn: Bool? { get set }
    var token: String? { get set }
}

final class UserDefaultsStorage: UserDefaultsStoraging {
    typealias Dependencies = HasLoggerServicing
    
    // MARK: - Private Properties
    
    private let logger: LoggerServicing
    
    // MARK: - Public Properties
    
    var appId: String? {
        get {
            UserDefaults.standard.appId
        }
        set {
            UserDefaults.standard.appId = newValue
        }
    }
    
    var isLoggedIn: Bool? {
        get {
            UserDefaults.standard.isLoggedIn
        }
        set {
            UserDefaults.standard.isLoggedIn = newValue
        }
    }
    
    var token: String? {
        get {
            UserDefaults.standard.token
        }
        set {
            UserDefaults.standard.token = newValue
        }
    }
    
    // MARK: - Initialization
    
    init(dependencies: Dependencies) {
        self.logger = dependencies.logger
    }
}
