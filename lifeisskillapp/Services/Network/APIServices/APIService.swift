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
    
    func isLocationSecuredTask() -> Bool {
        switch self {
        case .register:
            return false
        default:
            return true
        }
    }
    
    func isTokenSecuredTask() -> Bool {
        switch self {
        case .register, .login:
            return false
        default:
            return true
        }
    }
    
    func getTaskHeaders() -> [String: String] {
        var headers: [String: String] = ["Content-Lis": "47639"]
        
        if isTokenSecuredTask() {
            let token = UserDefaults.standard.token ?? ""
            headers["User-Token"] = token
        }
        return headers
    }
    
    func getTaskParams() -> [String: String] {
        let appVersion = UserDefaults.standard.appVersion ?? ""
        let appId = UserDefaults.standard.appId ?? ""
        var commonParams = [
            "appVer": "I\(appVersion)",
            "appID": appId
        ]
        if isLocationSecuredTask() {
            let location = UserDefaults.standard.location
            let locationParams = [
                "lat": String(location?.coordinate.latitude ?? 0),
                "lng": String(location?.coordinate.longitude ?? 0)
            ]
            commonParams = commonParams.merging(locationParams) { (lhs, rhs) -> String in
                lhs
            }
        }
        return commonParams
    }
}
