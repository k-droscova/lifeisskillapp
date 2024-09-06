//
//  Constants.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 26.08.2024.
//

import Foundation

enum Password {
    static let minLenght = 6
    #if DEBUG
    static let pinValidityTime = 0.5 // in minutes
    #else
    static let pinValidityTime = 15.0 // in minutes
    #endif
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

enum Phone {
    static let phonePattern = "^[0-9+()\\s-]{7,15}$" // regex
    static let defaultCountryCode = "+420" // czech republic, for phone pickers
}
