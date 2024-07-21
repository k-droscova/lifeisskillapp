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
        case location = "location"
        case token = "token"
        case logoutError = "logoutError"
        case checkSumData = "checkSumData"
    }
    
    // CheckSumData
    var checkSumData: CheckSumData? {
        get {
            guard let data = data(forKey: Keys.checkSumData.rawValue) else { return nil }
            return try? JSONDecoder().decode(CheckSumData.self, from: data)
        }
        set {
            let data = try? JSONEncoder().encode(newValue)
            set(data, forKey: Keys.checkSumData.rawValue)
        }
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
    var location: UserLocation? {
        get {
            guard let data = data(forKey: Keys.location.rawValue) else { return nil }
            return try? JSONDecoder().decode(UserLocation.self, from: data)
        }
        set {
            if let location = newValue {
                let data = try? JSONEncoder().encode(location)
                set(data, forKey: Keys.location.rawValue)
            } else {
                removeObject(forKey: Keys.location.rawValue)
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
