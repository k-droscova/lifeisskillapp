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
}

/// Protocol to provide a LocationManager instance.
protocol HasLocationManager {
    var locationManager: LocationManaging { get }
}

/// Protocol defining the interface for managing location services.
protocol LocationManaging {
    var delegate: LocationManagerFlowDelegate? { get set }
    /// Checks the location authorization status and requests permission if needed.
    func checkLocationAuthorization()
}

/// A class responsible for managing location services and handling location updates.
public final class LocationManager: BaseClass, LocationManaging {
    typealias Dependencies = HasLoggerServicing & HasUserDefaultsStorage
    
    // MARK: - Private Properties
    
    private let locationManager = CLLocationManager()
    private let logger: LoggerServicing
    private var userDefaultsStorage: UserDefaultsStoraging
    
    // MARK: - Public Properties
    
    weak var delegate: LocationManagerFlowDelegate?
    
    // MARK: - Initialization
    
    /// Initializes a new instance of LocationManager with the specified dependencies.
    /// - Parameter dependencies: The dependencies required by the LocationManager (Logging and Storage)
    init(dependencies: Dependencies) {
        self.logger = dependencies.logger
        self.userDefaultsStorage = dependencies.userDefaultsStorage
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
}

extension LocationManager: CLLocationManagerDelegate {
    /// Called when the location manager updates the locations.
    /// - Parameters:
    ///   - manager: The location manager object that generated the update event.
    ///   - locations: An array of CLLocation objects representing the locations that were updated.
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        logger.log(message: "New location saved:\n"
                   + "LAT: \(location.coordinate.latitude.description), "
                   + "LON: \(location.coordinate.longitude.description), "
                   + "ALT: \(location.altitude.description)"
        )
        userDefaultsStorage.location = location.toUserLocation()
    }
    
    /// Called when the location manager fails to update locations.
    /// - Parameters:
    ///   - manager: The location manager object that was unable to retrieve the location.
    ///   - error: The error object containing the reason for the failure.
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        do {
            throw BaseError(context: .location, message: error.localizedDescription, logger: logger)
        } catch {
            logger.log(message: "CCLocationManager did fail with Error.")
        }
    }
    
    /// Called when the location authorization status changes.
    /// - Parameters:
    ///   - manager: The location manager object that generated the update event.
    ///   - status: The new authorization status.
    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        self.checkLocationAuthorization()
    }
}
