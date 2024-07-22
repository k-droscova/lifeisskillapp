//
//  APIService.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 07.07.2024.
//

import Foundation

protocol APITasking {
    var task: ApiTask { get }
}

enum ApiTask: String {
    case login = "login"
    case userPoints = "userPoints"
    
    var isLocationSecuredTask: Bool {
        switch self {
        case .userPoints: true
        default: false
        }
    }
    
    var taskParams: [String: String] {
        let appVersion = UserDefaults.standard.appVersion ?? ""
        let appId = UserDefaults.standard.appId ?? ""
        var commonParams = [
            "appVer": "I\(appVersion)",
            "appId": appId
        ]
        if isLocationSecuredTask {
            let location = UserDefaults.standard.location
            let date = location?.timestamp ?? Date()
            let locationParams = [
                "lat": String(location?.latitude ?? 0),
                "lng": String(location?.longitude ?? 0),
                "acc": String(location?.accuracy ?? 0),
                "alt": String(location?.altitude ?? 0),
                "time": date.toPointListString()
            ]
            commonParams = commonParams.merging(locationParams) { (lhs, rhs) -> String in
                lhs
            }
        }
        return commonParams
    }
}
