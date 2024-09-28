//
//  UserLocation.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 21.07.2024.
//

import CoreLocation

public struct UserLocation: Codable {
    let latitude: Double
    let longitude: Double
    let altitude: Double
    let accuracy: Double
    let timestamp: Date
    
    // for mocks in testing
    public init(
        latitude: Double,
        longitude: Double,
        altitude: Double,
        accuracy: Double,
        timestamp: Date
    ) {
        self.latitude = latitude
        self.longitude = longitude
        self.altitude = altitude
        self.accuracy = accuracy
        self.timestamp = timestamp
    }
    
    func toCLLocation() -> CLLocation {
        return CLLocation(
            coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude),
            altitude: altitude,
            horizontalAccuracy: accuracy,
            verticalAccuracy: -1, // Placeholder since vertical accuracy is omitted
            course: -1, // Placeholder since course is omitted
            speed: -1, // Placeholder since speed is omitted
            timestamp: timestamp
        )
    }
    
    var description: String {
        String(format: "%.5f, %.5f, %.2f, %.2f", latitude, longitude, altitude, accuracy)
    }
}

extension UserLocation {
    func distance(to location: UserLocation) -> Double {
        let currentLocation = self.toCLLocation()
        let targetLocation = location.toCLLocation()
        return currentLocation.distance(from: targetLocation)
    }
}
