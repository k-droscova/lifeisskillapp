//
//  UserLocationMock.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 28.09.2024.
//

import lifeisskillapp
import Foundation

extension UserLocation {
    static func mock(
        latitude: Double = 50.0755,  // Latitude for Prague
        longitude: Double = 14.4378,  // Longitude for Prague
        altitude: Double = 0.0,
        accuracy: Double = 5.0, 
        timestamp: Date = Date(timeIntervalSince1970: 1725120000)  // 1st of September 2024
    ) -> UserLocation {
        return UserLocation(
            latitude: latitude,
            longitude: longitude,
            altitude: altitude,
            accuracy: accuracy,
            timestamp: timestamp
        )
    }
}
