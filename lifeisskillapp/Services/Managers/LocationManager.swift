//
//  LocationManager.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 13.07.2024.
//

import Foundation
import CoreLocation


protocol LocationManagerFlowDelegate: NSObject {
    func onLocationDenied()
    func onLocationRestricted()
    func onLocationSuccess()
}

protocol HasLocationManager {
    var locationManager: LocationManaging { get }
}

protocol LocationManaging {
    var delegate: LocationManagerFlowDelegate? { get set }
    var locationCoordinates: CLLocationCoordinate2D? { get }
    var isLocationSet: Bool { get }
    
    
}
