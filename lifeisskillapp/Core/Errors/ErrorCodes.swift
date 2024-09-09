//
//  ErrorCodes.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 04.07.2024.
//

import Foundation

/// Enum representing various error codes for tracking errors within the app.
///
/// This enum is used to categorize and manage different types of errors that can occur within the app.
/// API response errors (400 and 500) are mapped to `statusCode`.
public enum ErrorCodes {
    case `default`
    case genericStatusCode(Int)
    case specificStatusCode(SpecificStatusCodes)
    case login(LoginCodes)
    case general(GeneralCodes)
    case networking(NetworkCodes)
    
    /// Returns the integer value of the error code.
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
    
    public enum SpecificStatusCodes: Int {
        case invalidToken = 401
        case invalidUserPoint = 470
        case invalidUser = 465
        case invalidPin = 466
        case userNotActivated = 471
    }
    
    /// Enum representing general error codes with a prefix of `5xxx`.
    public enum GeneralCodes: Int {
        /// JSON string decoding error - `5000`
        case jsonDecoding = 5000
        /// Encoding to JSON string error - `5002`
        case jsonEncoding = 5002
        /// Received QR code has an invalid format - `5101`
        case invalidQRFormat = 5101
        /// Cannot proceed with the action due to missing config data (e.g., missing URL) - `5200`
        case missingConfigItem = 5200
        /// Config authorization token is missing - `5201`
        case missingToken = 5201
    }
    
    public enum LoginCodes: Int {
        case onlineInvalidCredentials = 1000
        case offlineInvalidCredentials = 1001
    }
    
    /// Enum representing networking error codes with a prefix of `6xxx`.
    public enum NetworkCodes: Int {
        // MARK: - General network codes
        
        /// Cannot decode object from API - `6000`
        case apiDecoding = 6000
        /// Cannot encode object that should be sent to API - `6001`
        case apiEncoding = 6001
        
        // MARK: - URL session error codes
        
        /// Unknown network error - `6100`
        case unknownNetworkError = 6100
        /// The device is not connected to the internet - `6101`
        ///
        /// Possible underlying errors:
        /// - kCFURLErrorNetworkConnectionLost `-1005`
        /// - kCFURLErrorNotConnectedToInternet `-1009`
        /// - kCFURLErrorDataNotAllowed `-1020`
        case noConnection = 6101
        /// The request URL is not valid - `6102`
        ///
        /// Possible underlying errors:
        /// - kCFURLErrorBadURL `-1000`
        /// - kCFURLErrorUnsupportedURL `-1002`
        /// - kCFURLErrorCannotFindHost `-1003`
        case invalidURL = 6102
        /// Timeout - `6103`
        ///
        /// Possible underlying error:
        /// - kCFURLErrorTimedOut `-1001`
        case timeout = 6103
    }
}
