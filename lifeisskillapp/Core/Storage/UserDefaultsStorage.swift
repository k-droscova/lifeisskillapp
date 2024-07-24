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
            return UserDefaults.standard.checkSumData
        }
        set {
            UserDefaults.standard.checkSumData = newValue
        }
    }
    
    var location: UserLocation? {
        get {
            return UserDefaults.standard.location
        }
        set {
            UserDefaults.standard.location = newValue
        }
    }
    
    var appId: String? {
        get {
            return UserDefaults.standard.appId
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
