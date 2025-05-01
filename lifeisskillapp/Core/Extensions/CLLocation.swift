//
//  CLLocation.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 22.07.2024.
//

import CoreLocation

extension CLLocation {
    func toUserLocation() -> UserLocation {
        return UserLocation(
            latitude: self.coordinate.latitude,
            longitude: self.coordinate.longitude,
            altitude: self.altitude,
            accuracy: self.horizontalAccuracy,
            timestamp: self.timestamp
        )
    }

    static func fromData(_ data: Data) -> CLLocation? {
        let decoder = JSONDecoder()
        guard let userLocation = try? decoder.decode(UserLocation.self, from: data) else {
            return nil
        }
        return userLocation.toCLLocation()
    }

    func toData() -> Data? {
        let encoder = JSONEncoder()
        let userLocation = self.toUserLocation()
        return try? encoder.encode(userLocation)
    }
}
