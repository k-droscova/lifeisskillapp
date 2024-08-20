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
    
    convenience init(from scannedPoint: ScannedPoint) {
        self.init()
        code = scannedPoint.code
        codeSource = scannedPoint.codeSource.rawValue
        if let loc = scannedPoint.location {
            location = RealmUserLocation(from: loc)
        }
    }
    
    func scannedPoint() -> ScannedPoint {
        ScannedPoint(
            code: code,
            codeSource: CodeSource(rawValue: codeSource) ?? .unknown,
            location: location?.userLocation()
        )
    }
}

class RealmUserLocation: EmbeddedObject, Codable {
    @objc dynamic var latitude: Double = 0.0
    @objc dynamic var longitude: Double = 0.0
    @objc dynamic var altitude: Double = 0.0
    @objc dynamic var accuracy: Double = 0.0
    @objc dynamic var timestamp: Date = Date()
    
    convenience init(from userLocation: UserLocation) {
        self.init()
        latitude = userLocation.latitude
        longitude = userLocation.longitude
        altitude = userLocation.altitude
        accuracy = userLocation.accuracy
        timestamp = userLocation.timestamp
    }
    
    func userLocation() -> UserLocation {
        UserLocation(
            latitude: latitude,
            longitude: longitude,
            altitude: altitude,
            accuracy: accuracy,
            timestamp: timestamp
        )
    }
}
