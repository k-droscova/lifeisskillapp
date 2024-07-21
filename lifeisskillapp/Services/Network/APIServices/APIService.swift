//
//  APIService.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 07.07.2024.
//

import Foundation

protocol APIServicing {
    var task: ApiTask { get }
}

enum ApiTask: String {
    case login = "login"
    case register = "register"
    
    var isLocationSecuredTask: Bool {
        switch self {
        case .register: false
        default: true
        }
    }
    
    var isTokenSecuredTask: Bool {
        switch self {
        case .register, .login:
            false
        default:
            true
        }
    }
    
    var taskHeaders: [String: String] {
        var headers: [String: String] = ["Content-Lis": "47639"]
        
        if isTokenSecuredTask {
            let token = UserDefaults.standard.token ?? ""
            headers["User-Token"] = token
        }
        return headers
    }
    
    var taskParams: [String: String] {
        let appVersion = UserDefaults.standard.appVersion ?? ""
        let appId = UserDefaults.standard.appId ?? ""
        var commonParams = [
            "appVer": "I\(appVersion)",
            "appID": appId
        ]
        if isLocationSecuredTask {
            let location = UserDefaults.standard.location
            let locationParams = [
                "lat": String(location?.latitude ?? 0),
                "lng": String(location?.longitude ?? 0)
            ]
            commonParams = commonParams.merging(locationParams) { (lhs, rhs) -> String in
                lhs
            }
        }
        return commonParams
    }
}
