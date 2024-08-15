//
//  RealmScannedPoint.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 15.08.2024.
//

import Foundation
import RealmSwift

class RealmScannedPoint: Object {
    @objc dynamic var pointID: String = UUID.init().uuidString
    @objc dynamic var code: String = ""
    @objc dynamic var codeSource: String = ""
    @objc dynamic var location: RealmUserLocation?
    
    override static func primaryKey() -> String? {
        "pointID"
    }
    
    override required init() {
        super.init()
    }
    // Initializer to create ScannedPointRealm from ScannedPoint struct
    convenience init(from scannedPoint: ScannedPoint) {
        self.init()
        self.code = scannedPoint.code
        self.codeSource = scannedPoint.codeSource.rawValue
        if let loc = scannedPoint.location {
            self.location = RealmUserLocation(from: loc)
        }
    }
    
    // Method to convert ScannedPointRealm back to ScannedPoint struct
    func toScannedPoint() -> ScannedPoint {
        return ScannedPoint(
            code: code,
            codeSource: CodeSource(rawValue: codeSource) ?? .unknown,
            location: location?.toUserLocation()
        )
    }
}

class RealmUserLocation: EmbeddedObject, Codable {
    @objc dynamic var latitude: Double = 0.0
    @objc dynamic var longitude: Double = 0.0
    @objc dynamic var altitude: Double = 0.0
    @objc dynamic var accuracy: Double = 0.0
    @objc dynamic var timestamp: Date = Date()
    
    // Initializer to create UserLocationRealm from UserLocation struct
    convenience init(from userLocation: UserLocation) {
        self.init()
        self.latitude = userLocation.latitude
        self.longitude = userLocation.longitude
        self.altitude = userLocation.altitude
        self.accuracy = userLocation.accuracy
        self.timestamp = userLocation.timestamp
    }
    
    // Method to convert UserLocationRealm back to UserLocation struct
    func toUserLocation() -> UserLocation {
        return UserLocation(
            latitude: latitude,
            longitude: longitude,
            altitude: altitude,
            accuracy: accuracy,
            timestamp: timestamp
        )
    }
}
