//
//  UserActivationStatus.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 10.09.2024.
//

import Foundation

public enum UserActivationStatus: Int, Codable {
    case incomplete = 0 // only short registration
    case parentActivationRequired = 1 // completed registration in profile, but user is a minor and requires email activation from guardian
    case fullyActivated = 2 // completed registration, including activation from guardian if minor
}
