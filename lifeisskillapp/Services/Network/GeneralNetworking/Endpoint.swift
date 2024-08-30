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
    case appId
    case login
    case usercategory, userpoints, rank, events, messages, points
    case sponsorImage(sponsorId: String, width: Int, height: Int)
    case request(username: String)
    case confirm
    
    var path: String {
        switch self {
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
        case .request(let username):
            "/pswd/?user=\(username)"
        case .confirm:
            "/pswd"
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
        case .appId, .login, .request, .confirm:
            false
        case .usercategory, .userpoints, .rank, .events, .messages, .points, .sponsorImage:
            true
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
