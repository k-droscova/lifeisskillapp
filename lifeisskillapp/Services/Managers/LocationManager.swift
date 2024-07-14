//
//  LocationManager.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 13.07.2024.
//

import Foundation
import CoreLocation

/// Protocol for the flow delegate to handle location updates and errors. This is handled by AppFlowCoordinator
protocol LocationManagerFlowDelegate: NSObject {
    /// Called when the location authorization is unsuccessful.
    func onLocationUnsuccess()
    /// Called when the location authorization is successful.
    func onLocationSuccess()
    /// Called when there is an error with location services.
    /// - Parameter error: The error that occurred.
    func onLocationError(_ error: Error)
}

/// Protocol to provide a LocationManager instance.
protocol HasLocationManager {
    var locationManager: LocationManaging { get }
}

/// Protocol defining the interface for managing location services.
protocol LocationManaging {
    var delegate: LocationManagerFlowDelegate? { get set }
    
    /// The current location coordinates of the user.
    var locationCoordinate: CLLocationCoordinate2D? { get }
    /// The current altitude of the user.
    var locationAltitude: CLLocationDistance? { get }
    /// Checks the location authorization status and requests permission if needed.
    func checkLocationAuthorization()
}

/// A class responsible for managing location services and handling location updates.
public final class LocationManager: NSObject, LocationManaging {
    typealias Dependencies = HasLoggerServicing & HasUserDefaultsStorage
    private let locationManager = CLLocationManager()
    private var dependencies: Dependencies
    
    public var locationCoordinate: CLLocationCoordinate2D?
    public var locationAltitude: CLLocationDistance?
    
    weak var delegate: LocationManagerFlowDelegate?
    
    /// Initializes a new instance of LocationManager with the specified dependencies.
    /// - Parameter dependencies: The dependencies required by the LocationManager (Logging and Storage)
    init(dependencies: Dependencies) {
        self.dependencies = dependencies
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    /// Checks the location authorization status and requests permission if needed.
    public func checkLocationAuthorization() {
        switch locationManager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()
            delegate?.onLocationSuccess()
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .denied, .restricted:
            delegate?.onLocationUnsuccess()
        default:
            break
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
        dependencies.userDefaultsStorage.beginTransaction()
        dependencies.logger.log(message: "New location saved:\n"
                                + "LAT: \(location.coordinate.latitude.description), "
                                + "LON: \(location.coordinate.longitude.description), "
                                + "ALT: \(location.altitude.description)"
        )
        dependencies.userDefaultsStorage.location = location
        dependencies.userDefaultsStorage.commitTransaction()
        locationCoordinate = location.coordinate
        locationAltitude = location.altitude
    }
    
    /// Called when the location manager fails to update locations.
    /// - Parameters:
    ///   - manager: The location manager object that was unable to retrieve the location.
    ///   - error: The error object containing the reason for the failure.
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        delegate?.onLocationError(error)
    }
    
    /// Called when the location authorization status changes.
    /// - Parameters:
    ///   - manager: The location manager object that generated the update event.
    ///   - status: The new authorization status.
    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        self.checkLocationAuthorization()
    }
}
