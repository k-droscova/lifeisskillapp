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
    var locationStream: AsyncStream<UserLocation?> { get }
}

final class UserDefaultsStorage: UserDefaultsStoraging {
    typealias Dependencies = HasLoggerServicing
    
    // MARK: - Private Properties
    
    private let logger: LoggerServicing
    private var locationContinuation: AsyncStream<UserLocation?>.Continuation?
    
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
            triggerLocationAsyncStream()
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
    
    // MARK: - Async Streams
    
    var locationStream: AsyncStream<UserLocation?> {
        AsyncStream { continuation in
            self.locationContinuation = continuation
            continuation.yield(self.location)
        }
    }
    
    // MARK: - Initialization
    
    init(dependencies: Dependencies) {
        self.logger = dependencies.logger
    }
    
    // MARK: - Private Helpers
    
    private func triggerLocationAsyncStream() {
        DispatchQueue.main.async {
            self.locationContinuation?.yield(self.location)
        }
    }
}
