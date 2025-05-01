//
//  ErrorCodes.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 04.07.2024.
//

import Foundation

enum ErrorCodes {
    case `default`
    case genericStatusCode(Int)    // For any arbitrary HTTP status code
    case specificStatusCode(SpecificStatusCodes)  // Specific status codes for known errors
    case login(LoginCodes)         // Errors related to login
    case general(GeneralCodes)     // General, app-wide errors
    case networking(NetworkCodes)  // Networking-related errors
    
    // Retrieve associated error code value
    var code: Int {
        switch self {
        case .default: return 1
        case .specificStatusCode(let code): return code.rawValue
        case .genericStatusCode(let code): return code
        case .login(let code): return code.rawValue
        case .general(let code): return code.rawValue
        case .networking(let code): return code.rawValue
        }
    }
    
    // MARK: - Specific Status Codes (HTTP and other API-related codes)
    enum SpecificStatusCodes: Int {
        case invalidToken = 401
        case invalidUserPoint = 470
        case invalidUser = 465
        case invalidPin = 466
        case userNotActivated = 471
    }
    
    // MARK: - General Error Codes (Range: 1000-1999)
    enum GeneralCodes: Int {
        case jsonDecoding = 1000      // JSON decoding failure
        case jsonEncoding = 1001      // JSON encoding failure
        case invalidQRFormat = 1002   // Invalid QR code format
        case missingConfigItem = 1003 // Missing configuration item
        case missingToken = 1004      // Missing token in a required place
    }
    
    // MARK: - Login Error Codes (Range: 2000-2999)
    enum LoginCodes: Int {
        case onlineInvalidCredentials = 2000  // Invalid credentials for online login
        case offlineInvalidCredentials = 2001 // Invalid credentials for offline login
        case missingLocation = 2002 // Missing location, gps data required for login
    }
    
    // MARK: - Network Error Codes (Range: 3000-3999)
    enum NetworkCodes: Int {
        case apiDecoding = 3000        // API response decoding failure
        case apiEncoding = 3001        // API request encoding failure
        case unknown = 3002 // Unknown network error
        case noConnection = 3003       // No internet connection
        case invalidURL = 3004         // Invalid URL
        case timeout = 3005            // Request timed out
    }
}
