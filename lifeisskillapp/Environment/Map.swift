//
//  Map.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 18.08.2024.
//

import Foundation
import CoreLocation

struct MapConstants {
    static let pointNoPublic: Int = 0b1_0000_0000
    static let mapDetailViewSheetHeight: CGFloat = 200
    static let mapDetailImageHeight: CGFloat = 100
    static let maxClusterZoomLevel: Double = 12.0
    static let latitudeDelta = 0.05
    static let longitudeDelta = 0.05
    static let virtualPointDistance: Double = {
            if let value = Bundle.main.infoDictionary?["MAP_VIRTUAL_POINT"] as? String,
               let doubleValue = Double(value) {
                return doubleValue
            }
            return 100.0 // Fallback in case of missing value
        }()
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
