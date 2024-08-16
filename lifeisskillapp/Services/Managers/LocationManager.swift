//
//  LocationManager.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 13.07.2024.
//

import Foundation
import CoreLocation
import Combine

/// Protocol for the flow delegate to handle location updates and errors. This is handled by AppFlowCoordinator
protocol LocationManagerFlowDelegate: NSObject {
    /// Called when the location authorization is unsuccessful.
    func onLocationUnsuccess()
}

/// Protocol to provide a LocationManager instance.
protocol HasLocationManager {
    var locationManager: LocationManaging { get }
}

/// Protocol defining the interface for managing location services.
protocol LocationManaging {
    var delegate: LocationManagerFlowDelegate? { get set }
    var gpsStatus: Bool { get }
    var gpsStatusPublisher: AnyPublisher<Bool, Never> { get }
    var location: UserLocation? { get }
    var locationPublisher: AnyPublisher<UserLocation?, Never> { get }
    /// Checks the location authorization status and requests permission if needed.
    func checkLocationAuthorization()
}

/// A class responsible for managing location services and handling location updates.
public final class LocationManager: BaseClass, LocationManaging {
    typealias Dependencies = HasLoggerServicing
    
    // MARK: - Private Properties
    
    private let locationManager = CLLocationManager()
    private let logger: LoggerServicing
    private let gpsSubject = CurrentValueSubject<Bool, Never>(false) // default false -> handles case when user starts the app without location services
    private let locationSubject = CurrentValueSubject<UserLocation?, Never>(nil) // same reason for default nil
    
    // MARK: - Public Properties
    
    weak var delegate: LocationManagerFlowDelegate?
    var location: UserLocation? {
        locationSubject.value
    }
    var gpsStatus: Bool {
        gpsSubject.value
    }
    var gpsStatusPublisher: AnyPublisher<Bool, Never> {
        return gpsSubject.eraseToAnyPublisher()
    }
    var locationPublisher: AnyPublisher<UserLocation?, Never> {
        return locationSubject.eraseToAnyPublisher()
    }
    
    // MARK: - Initialization
    
    /// Initializes a new instance of LocationManager with the specified dependencies.
    /// - Parameter dependencies: The dependencies required by the LocationManager (Logging and Storage)
    init(dependencies: Dependencies) {
        self.logger = dependencies.logger
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    // MARK: - Public Interface
    
    /// Checks the location authorization status and requests permission if needed.
    public func checkLocationAuthorization() {
        switch locationManager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()
            logger.log(message: "Location Manager - SUCCESS")
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .denied, .restricted:
            logger.log(message: "Location Manager - UNSUCCESS")
            delegate?.onLocationUnsuccess()
        default:
            break
        }
    }
    
    // MARK: - Private Helpers
    
    private func triggerLocationPublisher(_ location: UserLocation?) {
        Task { @MainActor [weak self] in
            self?.locationSubject.send(location)
        }
    }
    
    private func triggerGPSPublisher(_ status: Bool) {
        Task { @MainActor [weak self] in
            self?.gpsSubject.send(status)
        }
    }
}

extension LocationManager: CLLocationManagerDelegate {
    /// Called when the location manager updates the locations.
    /// - Parameters:
    ///   - manager: The location manager object that generated the update event.
    ///   - locations: An array of CLLocation objects representing the locations that were updated.
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        triggerLocationPublisher(location.toUserLocation())
        // Update gps status only if the last value has been false
        guard !gpsSubject.value else { return }
        triggerGPSPublisher(true)
    }
    
    /// Called when the location manager fails to update locations.
    /// - Parameters:
    ///   - manager: The location manager object that was unable to retrieve the location.
    ///   - error: The error object containing the reason for the failure.
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        logger.log(
            message: "ERROR: CCLocationManager failed with Error: \(error.localizedDescription)"
        )
        triggerLocationPublisher(nil)
        // Update gps status only if the last value has been true
        guard gpsSubject.value else { return }
        triggerGPSPublisher(false)
    }
    
    /// Called when the location authorization status changes.
    /// - Parameters:
    ///   - manager: The location manager object that generated the update event.
    ///   - status: The new authorization status.
    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        self.checkLocationAuthorization()
    }
}
