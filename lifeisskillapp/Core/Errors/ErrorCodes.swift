//
//  ErrorCodes.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 04.07.2024.
//

import Foundation

public enum ErrorCodes {
    case `default`
    case statusCode(Int)
    case general(GeneralCodes)
    case networking(NetworkCodes)
    case api(APIErrorCodes)
    
    var code: Int {
        switch self {
            case .default: 1
            case .statusCode(let code): code
            case .general(let code): code.rawValue
            case .networking(let code): code.rawValue
            case .api(let code): code.rawValue
        }
    }
    
    public enum APIErrorCodes: Int {
        case invalidRegistration = 412 // status code is 412
        case loggedInOnOtherDevice = 401 // status code is 401
        case invalidPointCode = 470 // status code is 470
        case `default` = 400
    }
    
    /// General error codes `5xxx`
    ///
    /// - `50xx` codes are related to JSON string that are exchanged between RN app and native module
    /// - `51xx` codes are related to QR codes
    /// - `52xx` codes are related to `setConfig`, `setAuthToken`
    public enum GeneralCodes: Int {
        /// JSON string decoding error - `5000`
        case jsonDecoding = 5000
        /// Encoding to JSON string error - `5002`
        case jsonEncoding = 5002
        /// Received QR code has invalid format
        ///
        /// - `mdoc:` prefix is missing
        /// - Is not valid Base64URL
        /// - eReader link is not valid URL
        case invalidQRFormat = 5101
        /// Device engagement is not valid
        case invalidQREngagementContent = 5102
        
        /// Cannot proceed with the action. There is missing config data.
        ///
        /// - Fe. URL is missing
        case missingConfigItem = 5200
        /// Config autorization token is missing
        case missingToken = 5201
    }
    
    /// Networking error codes
    ///
    /// - `60xx` general errors as decoding/encoding
    /// - `61xx` codes are related to networking
    ///   - Errors that happened before receiving HTTP response.
    ///   - HTTP response was not received. This error does not contain 4xx and 5xx HTTP status codes.
    /// - `6200` API error codes
    public enum NetworkCodes: Int {
        // MARK: - General network codes
        
        /// Cannot decode object from API
        case apiDecoding = 6000
        /// Cannot encode object that should be send to API
        case apiEncoding = 6001
        
        // MARK: - URL session error codes
        
        /// Unknown network error -
        case unknownNetworkError = 6100
        /// The device is not connected to the internet
        ///
        /// - kCFURLErrorNetworkConnectionLost `-1005`
        /// - kCFURLErrorNotConnectedToInternet `-1009`
        /// - kCFURLErrorDataNotAllowed `-1020`
        case noConnection = 6101
        /// The request URL is not valid
        ///
        /// - kCFURLErrorBadURL `-1000`
        /// - kCFURLErrorUnsupportedURL `-1002`
        /// - kCFURLErrorCannotFindHost `-1003`
        case invalidURL = 6102
        /// Timeout
        ///
        /// - kCFURLErrorTimedOut - `-1001`
        case timeout = 6103
    }
}
