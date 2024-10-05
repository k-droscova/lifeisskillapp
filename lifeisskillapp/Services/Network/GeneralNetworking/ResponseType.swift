//
//  ResponseType.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 25.09.2024.
//

import Foundation

enum ResponseType {

    /// - informational: This class of status code indicates a provisional response, consisting only of the Status-Line and optional headers, and is terminated by an empty line.
    case informational

    /// - success: This class of status codes indicates the action requested by the client was received, understood, accepted, and processed successfully.
    case success

    /// - redirection: This class of status code indicates the client must take additional action to complete the request.
    case redirection

    /// - clientError: This class of status code is intended for situations in which the client seems to have erred.
    case clientError

    /// - serverError: This class of status code indicates the server failed to fulfill an apparently valid request.
    case serverError

    /// - undefined: The class of the status code cannot be resolved.
    case undefined

    /// Initialize `ResponseType` from an HTTP status code.
    init(from statusCode: Int) {
        switch statusCode {
        case 100..<200:
            self = .informational
        case 200..<300:
            self = .success
        case 300..<400:
            self = .redirection
        case 400..<500:
            self = .clientError
        case 500..<600:
            self = .serverError
        default:
            self = .undefined
        }
    }
}
