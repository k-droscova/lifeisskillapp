//
//  UserDefaults.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 07.07.2024.
//

import Foundation
import CoreLocation

extension UserDefaults {
    /// Enum representing the keys used to store values in UserDefaults.
    private enum Keys: String {
        case appId = "appId"
        case appVersion = "appVersion"
    }
    
    /// Stores or retrieves the API key.
    ///
    /// - Returns: An optional string containing the API key.
    var appId: String? {
        get {
            object(forKey: Keys.appId.rawValue) as? String ?? nil
        }
        set {
            set(newValue, forKey: Keys.appId.rawValue)
        }
    }
    
    /// Stores or retrieves the app version.
    ///
    /// - Returns: An optional string containing the app version.
    var appVersion: String? {
        get {
            object(forKey: Keys.appVersion.rawValue) as? String ?? nil
        }
        set {
            set(newValue, forKey: Keys.appVersion.rawValue)
        }
    }
}
