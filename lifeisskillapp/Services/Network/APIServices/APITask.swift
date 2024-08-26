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
    case forgotPassword = "renewPswd"
    
    var taskParams: [String: String] {
        var taskParam: [String: String] = ["task": self.rawValue]
        
        switch self {
        case .login, .userPoints:
            taskParam.merge(appParams) { (_, new) in new }
        case .forgotPassword:
            break // No additional parameters needed for forgotPassword
        }
        
        return taskParam
    }
    
    var appParams: [String: String] {
        let appVersion = UserDefaults.standard.appVersion ?? ""
        let appId = UserDefaults.standard.appId ?? ""
        let commonParams = [
            "appVer": "I\(appVersion)",
            "appId": appId
        ]
        return commonParams
    }
}
