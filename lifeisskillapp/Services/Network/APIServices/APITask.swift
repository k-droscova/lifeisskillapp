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
    
    var taskParams: [String: String] {
        let appVersion = UserDefaults.standard.appVersion ?? ""
        let appId = UserDefaults.standard.appId ?? ""
        let commonParams = [
            "appVer": "I\(appVersion)",
            "appId": appId
        ]
        return commonParams
    }
}
