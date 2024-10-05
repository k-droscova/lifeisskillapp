//
//  Constants.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 26.08.2024.
//

import Foundation

enum Password {
    static let minLenght = 6
    static let pinValidityTime: Double = {
            if let value = Bundle.main.infoDictionary?["PIN_VALIDITY_TIME"] as? String,
               let doubleValue = Double(value) {
                return doubleValue
            }
        return 15.0 // Fallback in case of missing value
        }()
}

enum Username {
    static let minLength = 4
}

enum Email {
    static let emailPattern = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}$" // regex
}

enum ReferenceQRKeys {
    static let task = "task"
    static let username = "key"           // Username
    static let userId = "key1"            // Base64-encoded userId
    static let signature = "key2"         // Signature or userToken
    static let onlineStatus = "key3"      // true (offline) or false (online)
    static let game = "game"              // Game name
}

enum User {
    static let ageWhenConsideredNotMinor = 15 // in years
}

enum RankConstants {
    static let minForSeparation = 20
    static let topSection = 5
    static let aboveUser = 2
    static let belowUser = 2
    static let bottomSection = 5
}
