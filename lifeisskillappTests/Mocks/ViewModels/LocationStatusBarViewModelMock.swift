//
//  LocationStatusBarViewModelMock.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 17.10.2024.
//

@testable import lifeisskillapp
import SwiftUI

final class LocationStatusBarViewModelMock: BaseClass, LocationStatusBarViewModeling {
    
    // MARK: - Mock Properties
    
    @Published var appVersion: String = "DEBUG"
    @Published var isOnline: Bool = false
    @Published var isGpsOk: Bool = false
    @Published var userLocation: UserLocation? = nil
    
    // MARK: - Initialization
    
    required init(dependencies: HasLoggers & HasLocationManager & HasNetworkMonitor) {
        // This mock doesn't need to use the dependencies, so it's just an empty init
    }
    
    // MARK: - Helper Methods to Simulate Changes
    
    func simulateLocationUpdate(_ newLocation: UserLocation?) {
        self.userLocation = newLocation
    }
    
    func simulateGpsStatusChange(_ status: Bool) {
        self.isGpsOk = status
    }
    
    func simulateOnlineStatusChange(_ status: Bool) {
        self.isOnline = status
    }
}
