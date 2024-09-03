//
//  Endpoint.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 30.08.2024.
//

import Foundation

protocol Endpointing {
    var path: String { get }
    var isUserTokenRequired: Bool { get }
    func headers(userToken: String?) -> [String: String]
    func urlWithPath() throws -> URL
}

enum Endpoint: Endpointing {
    case resetPassword(ResetPassword)
    case registration(Registration)
    case appId
    case login
    case usercategory, userpoints, rank, events, messages, points
    case sponsorImage(sponsorId: String, width: Int, height: Int)
    
    var path: String {
        switch self {
        case .resetPassword(let action):
            switch action {
            case .request(let username):
                return "/pswd/?user=\(username)"
            case .confirm:
                return "/pswd"
            }
            
        case .registration(let action):
            switch action {
            case .checkUsernameAvailability(let username):
                return "/nick/\(username)/check"
            case .checkEmailAvailability(let email):
                return "/email/\(email)/check"
            case .registerUser:
                return "/register"
            }
            
        case .appId:
            return "/appid"
        case .login:
            return "/login"
        case .usercategory:
            return "/usercategory"
        case .userpoints:
            return "/userpoints"
        case .rank:
            return "/rank"
        case .events:
            return "/events"
        case .messages:
            return "/messages"
        case .points:
            return "/points"
        case .sponsorImage(let sponsorId, let width, let height):
            return "/files?type=partners&partnerId=\(sponsorId)&width=\(width)&height=\(height)"
        }
    }
    
    var typeHeaders: [String: String] {
        switch self {
        case .sponsorImage:
            return ["accept": "image/png"]
        default:
            return ["accept": "application/json"]
        }
    }
    
    var isUserTokenRequired: Bool {
        switch self {
        case .resetPassword, .registration, .appId, .login:
            return false
        case .usercategory, .userpoints, .rank, .events, .messages, .points, .sponsorImage:
            return true
        }
    }
    
    func headers(userToken: String? = nil) -> [String: String] {
        var finalHeaders = typeHeaders
        
        // Conditionally add the User-Token header if required
        if isUserTokenRequired, let userToken = userToken {
            let userHeader = APIHeader.apiTokenHeader(token: userToken)
            finalHeaders[userHeader.key] = userHeader.val
        }
        
        return finalHeaders
    }
    
    func urlWithPath() throws -> URL {
        let finalURLString = APIUrl.base + path
        guard let url = URL(string: finalURLString) else {
            throw BaseError(
                context: .network,
                message: "Invalid URL",
                logger: appDependencies.logger
            )
        }
        return url
    }
}

extension Endpoint {
    // MARK: nested enums for separate flows
    enum ResetPassword {
        case request(username: String)
        case confirm
    }
    enum Registration {
        case checkUsernameAvailability(username: String)
        case checkEmailAvailability(email: String)
        case registerUser(details: [String: Any]) // Example additional case
    }
}
