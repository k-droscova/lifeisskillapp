//
//  UserDefaultsStorageMock.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 16.10.2024.
//

@testable import lifeisskillapp
import Foundation

final class UserDefaultsStorageMock: UserDefaultsStoraging {
    
    var mockAppId: String? = nil
    var mockIsLoggedIn: Bool? = nil
    var mockToken: String? = nil

    // MARK: - UserDefaultsStoraging Conformance
    
    var appId: String? {
        get {
            return mockAppId
        }
        set {
            mockAppId = newValue
        }
    }
    
    var isLoggedIn: Bool? {
        get {
            return mockIsLoggedIn
        }
        set {
            mockIsLoggedIn = newValue
        }
    }
    
    var token: String? {
        get {
            return mockToken
        }
        set {
            mockToken = newValue
        }
    }
}
