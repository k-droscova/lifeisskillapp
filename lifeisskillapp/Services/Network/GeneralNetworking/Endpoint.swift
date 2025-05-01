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
    case signature
    case parentEmailActivation(email: String)
    
    var path: String {
        switch self {
        case .resetPassword(let action):
            switch action {
            case .request(let username):
                "/pswd/?user=\(username)"
            case .confirm:
                "/pswd"
            }
            
        case .registration(let action):
            switch action {
            case .checkUsernameAvailability(let username):
                "/nick/\(username)/check"
            case .checkEmailAvailability(let email):
                "/email/\(email)/check"
            case .registerUser, .completeRegistration, .deleteUser:
                "/users"
            }
            
        case .appId:
            "/appid"
        case .login:
            "/login"
        case .usercategory:
            "/usercategory"
        case .userpoints:
            "/userpoints"
        case .rank:
            "/rank"
        case .events:
            "/events"
        case .messages:
            "/messages"
        case .points:
            "/points"
        case .sponsorImage(let sponsorId, let width, let height):
            "/files?type=partners&partnerId=\(sponsorId)&width=\(width)&height=\(height)"
        case .signature:
            "/signature"
        case .parentEmailActivation(let email):
            "/parentLink/\(email.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? email)/users"
        }
    }
    
    var typeHeaders: [String: String] {
        switch self {
        case .sponsorImage:
            ["accept": "image/png"]
        default:
            ["accept": "application/json"]
        }
    }
    
    var isUserTokenRequired: Bool {
        switch self {
        case .appId,
                .login,
                .resetPassword,
                .registration(.checkUsernameAvailability),
                .registration(.checkEmailAvailability),
                .registration(.registerUser):
            return false
        case .usercategory,
                .userpoints,
                .rank,
                .events,
                .messages,
                .points,
                .sponsorImage,
                .signature,
                .parentEmailActivation,
                .registration(.completeRegistration),
                .registration(.deleteUser):
            return true
        }
    }
    
    func headers(userToken: String? = nil) -> [String: String] {
        var finalHeaders = typeHeaders
        
        // Conditionally add the User-Token header if required
        if isUserTokenRequired, let token = userToken {
            finalHeaders.merge(APIHeader.apiTokenHeader(token: token)) { (_, new) in new }
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
        case registerUser
        case completeRegistration
        case deleteUser
    }
}
