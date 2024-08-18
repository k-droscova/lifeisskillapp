//
//  Map.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 18.08.2024.
//

import Foundation
import CoreLocation

public struct MapConstants {
    static let latitudeDelta = 0.05
    static let longitudeDelta = 0.05
    static let maxCenterCoordinateDistance = 20000.0
    static let defaultCoordinate = CLLocation(
        coordinate: CLLocationCoordinate2D(
            latitude: Prague.latitude,
            longitude: Prague.longitude
        ),
        altitude: Prague.altitude,
        horizontalAccuracy: 0,
        verticalAccuracy: 0,
        timestamp: Date.now
    )
    
    enum Prague {
        static let latitude: Double = 50.073658
        static let longitude: Double = 14.418540
        static let altitude: Double = 225
    }
}
