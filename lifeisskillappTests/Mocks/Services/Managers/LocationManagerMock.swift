//
//  LocationManagerMock.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 17.10.2024.
//

import Foundation
import Combine
import CoreLocation
@testable import lifeisskillapp

final class LocationManagerMock: LocationManaging {
    
    // MARK: - Public Properties
    
    weak var delegate: LocationManagerFlowDelegate?
    
    // Default return values for GPS status and location
    var gpsStatus: Bool = false {
        didSet {
            gpsSubject.send(gpsStatus)
        }
    }
    
    var location: UserLocation? {
        didSet {
            locationSubject.send(location)
        }
    }
    
    // Combine publishers for tracking GPS status and location
    private let gpsSubject = CurrentValueSubject<Bool, Never>(false)
    var gpsStatusPublisher: AnyPublisher<Bool, Never> {
        gpsSubject.eraseToAnyPublisher()
    }
    
    private let locationSubject = CurrentValueSubject<UserLocation?, Never>(nil)
    var locationPublisher: AnyPublisher<UserLocation?, Never> {
        locationSubject.eraseToAnyPublisher()
    }
    
    // Flags to track method calls
    var checkLocationAuthorizationCalled = false

    // MARK: - Mock Methods for LocationManaging
    
    // Simulates checking location authorization and updating the delegate if needed.
    func checkLocationAuthorization() {
        checkLocationAuthorizationCalled = true
        // Simulate an unsuccessful authorization
        if gpsStatus == false {
            delegate?.onLocationUnsuccess()
        }
    }
    
    // Helper methods to simulate GPS and location changes
    func simulateLocationUpdate(_ newLocation: UserLocation?) {
        location = newLocation
    }
    
    func simulateGPSStatusChange(_ status: Bool) {
        gpsStatus = status
    }
}
