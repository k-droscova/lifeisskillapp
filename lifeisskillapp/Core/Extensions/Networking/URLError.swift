//
//  URLError.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 25.09.2024.
//

import Foundation

extension URLError {
    
    var errorCode: ErrorCodes.NetworkCodes {
        switch self.code {
        case .notConnectedToInternet, .dataNotAllowed, .networkConnectionLost, .internationalRoamingOff, .cannotConnectToHost:
            .noConnection
        case .badURL, .unsupportedURL, .cannotFindHost:
            .invalidURL
        case .timedOut:
            .timeout
        default:
            .unknown
        }
    }
    
    var errorMessage: String {
        switch self.code {
        case .notConnectedToInternet, .dataNotAllowed, .networkConnectionLost, .internationalRoamingOff, .cannotConnectToHost:
            return "Connection"
        case .badURL, .unsupportedURL, .cannotFindHost:
            return "URL"
        case .timedOut:
            return "Time Out"
        default:
            return "Generic"
        }
    }
}
