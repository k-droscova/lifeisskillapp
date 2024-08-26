//
//  LocationStatusBarVM.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 26.08.2024.
//

import Foundation

final class MockLocationStatusBarViewModel: BaseClass, LocationStatusBarViewModeling {
    var appVersion: String = "DEBUG"
    var isOnline: Bool = false
    var isGpsOk: Bool = false
    var userLocation: UserLocation? = nil
    
    required init(dependencies: HasLoggers & HasLocationManager & HasNetworkMonitor) {
        // No-op for mock
    }
    
    // Mock methods to simulate state
    func simulateGpsStatus(isOk: Bool) {
        self.isGpsOk = isOk
    }
    
    func simulateOnlineStatus(isOnline: Bool) {
        self.isOnline = isOnline
    }
    
    func simulateLocation(_ location: UserLocation?) {
        self.userLocation = location
    }
}
