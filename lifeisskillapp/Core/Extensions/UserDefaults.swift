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
        case credentials = "credentials"
        case appId = "appId"
        case appVersion = "appVersion"
        case firstOpened = "firstOpened"
        case clLocation = "clLocation"
        case token = "token"
        case logoutError = "logoutError"
    }

    /// Stores or retrieves the logout error message.
    ///
    /// - Returns: An optional string containing the logout error message.
    var logoutError: String? {
        get {
            object(forKey: Keys.logoutError.rawValue) as? String ?? nil
        }
        set {
            set(newValue, forKey: Keys.logoutError.rawValue)
        }
    }

    /// Stores or retrieves the user's login credentials.
    ///
    /// - Returns: An optional `LoginCredentials` object.
    var credentials: LoginCredentials? {
        get {
            guard let data = object(forKey: Keys.credentials.rawValue) as? Data else { return nil }
            return try? JSONDecoder().decode(LoginCredentials.self, from: data)
        }
        set {
            if let credentials = newValue {
                let data = try? JSONEncoder().encode(credentials)
                set(data, forKey: Keys.credentials.rawValue)
            } else {
                removeObject(forKey: Keys.credentials.rawValue)
            }
        }
    }

    /// Stores or retrieves the user's token.
    ///
    /// - Returns: An optional string containing the token.
    var token: String? {
        get {
            object(forKey: Keys.token.rawValue) as? String ?? nil
        }
        set {
            set(newValue, forKey: Keys.token.rawValue)
        }
    }

    /// Stores or retrieves the user's location.
    ///
    /// - Returns: An optional `CLLocation` object representing the user's location.
    var userLocation: CLLocation? {
        get {
            guard let data = object(forKey: Keys.clLocation.rawValue) as? [String: Double] else { return nil }
            return CLLocation(latitude: data["lat"] ?? 0.0, longitude: data["lon"] ?? 0.0)
        }
        set {
            if let location = newValue {
                let latitude = Double(location.coordinate.latitude)
                let longitude = Double(location.coordinate.longitude)
                set(["lat": latitude, "lon": longitude], forKey: Keys.clLocation.rawValue)
            }
        }
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

    /// Stores or retrieves a boolean value indicating whether the app was first opened.
    ///
    /// - Returns: A boolean value indicating whether the app was first opened.
    var firstOpened: Bool {
        get {
            object(forKey: Keys.firstOpened.rawValue) as? Bool ?? true
        }
        set {
            set(newValue, forKey: Keys.firstOpened.rawValue)
        }
    }
}

extension UserDefaults {
    /// Provides a `UserDefaults` instance for storing credentials using an app-specific suite name.
    static let credentials = UserDefaults(suiteName: (Bundle.main.bundleIdentifier ?? "") + ".credentials")!
}
