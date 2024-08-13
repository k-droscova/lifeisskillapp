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
    var location: UserLocation? { get set }
    var locationPublisher: AnyPublisher<UserLocation?, Never> { get }
}

final class UserDefaultsStorage: UserDefaultsStoraging {
    typealias Dependencies = HasLoggerServicing
    
    // MARK: - Private Properties
    
    private let logger: LoggerServicing
    private let locationSubject = CurrentValueSubject<UserLocation?, Never>(nil)
    
    // MARK: - Public Properties
    
    var location: UserLocation? {
        get {
            UserDefaults.standard.location // uses UserDefaults extension for custom key
        }
        set {
            UserDefaults.standard.location = newValue
            triggerLocationPublisher()
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
    
    // MARK: - Publisher
    
    var locationPublisher: AnyPublisher<UserLocation?, Never> {
        return locationSubject.eraseToAnyPublisher()
    }
    
    // MARK: - Initialization
    
    init(dependencies: Dependencies) {
        self.logger = dependencies.logger
        self.locationSubject.send(self.location) // Initialize with the current location
    }
    
    // MARK: - Private Helpers
    
    private func triggerLocationPublisher() {
        Task { @MainActor [weak self] in
            self?.locationSubject.send(self?.location)
        }
    }
}
