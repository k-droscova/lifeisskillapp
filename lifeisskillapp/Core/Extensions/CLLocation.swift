//
//  CLocation.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 15.07.2024.
//

import Foundation
import CoreLocation

extension CLLocation {
    func toData() -> Data? {
        try? NSKeyedArchiver.archivedData(withRootObject: self, requiringSecureCoding: false)
    }
    
    static func fromData(_ data: Data) -> CLLocation? {
        try? NSKeyedUnarchiver.unarchivedObject(ofClass: CLLocation.self, from: data)
    }
}
