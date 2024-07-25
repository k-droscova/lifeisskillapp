//
//  UserDefaultsStorage.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 10.07.2024.
//

import Foundation
import CoreLocation

protocol HasUserDefaultsStorage {
    var userDefaultsStorage: UserDefaultsStoraging { get set }
}

protocol UserDefaultsStoraging {
    var appId: String? { get set }
    var location: UserLocation? { get set }
    var checkSumData: CheckSumData? { get set }
}

final class UserDefaultsStorage: UserDefaultsStoraging {
    typealias Dependencies = HasLoggerServicing
    
    // MARK: - Private Properties
    
    private let logger: LoggerServicing
    
    // MARK: - Public Properties
    
    var checkSumData: CheckSumData? {
        get {
            UserDefaults.standard.checkSumData // uses UserDefaults extension for custom key
        }
        set {
            UserDefaults.standard.checkSumData = newValue
        }
    }
    
    var location: UserLocation? {
        get {
            UserDefaults.standard.location // uses UserDefaults extension for custom key
        }
        set {
            UserDefaults.standard.location = newValue
        }
    }
    
    var appId: String? {
        get {
            UserDefaults.standard.appId // uses UserDefaults extension for custom key
        }
        set {
            UserDefaults.standard.appId = newValue
        }
    }
    
    // MARK: - Initialization
    
    init(dependencies: Dependencies) {
        self.logger = dependencies.logger
    }
}
