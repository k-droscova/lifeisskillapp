//
//  APIService.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 07.07.2024.
//

import Foundation

protocol ApiTasking {
    func encodeParams() throws -> Data
}

enum ApiTask: ApiTasking {
    case login(credentials: LoginCredentials, location: UserLocation)
    case postScannedPoint(point: ScannedPoint)
    case renewPassword(credentials: ForgotPasswordCredentials)
    case registerUser(credentials: NewRegistrationCredentials, location: UserLocation)
    case completeRegistration(credentials: FullRegistrationCredentials)
    
    // MARK: - Public Interface
    
    func encodeParams() throws -> Data {
        let params = taskParams
        let jsonString = try JsonMapper.jsonString(from: params)
        guard let jsonData = jsonString.data(using: .utf8) else {
            throw BaseError(
                context: .system,
                message: "Could not encode \(taskName) params",
                code: .general(.jsonEncoding),
                logger: appDependencies.logger
            )
        }
        return jsonData
    }
    
    // MARK: - Private Helper Properties
    
    private var taskParams: [String: String] {
        var params: [String: String] = ["task": taskName]
        
        switch self {
        case .login, .postScannedPoint:
            params.merge(appParams) { (_, new) in new }
        default:
            break
        }
        
        switch self {
        case .login(let credentials, let location):
            params.merge(credentials.params) { (_, new) in new }
            params.merge([
                "lat": String(location.latitude),
                "lng": String(location.longitude)
            ]) { (_, new) in new }
            
        case .postScannedPoint(let point):
            guard let location = point.location else {
                return [:]
            }
            let date = location.timestamp
            params.merge([
                "code": point.code,
                "codeSource": point.codeSource.rawValue,
                "lat": String(location.latitude),
                "lng": String(location.longitude),
                "acc": String(location.accuracy),
                "alt": String(location.altitude),
                "time": date.getUserPointString()
            ]) { (_, new) in new }
            
        case .renewPassword(let credentials):
            params.merge(credentials.params) { (_, new) in new }
            
        case .registerUser(let credentials, let location):
            params.merge(credentials.params) { (_, new) in new }
            params.merge([
                "lat": String(location.latitude),
                "lng": String(location.longitude)
            ]) { (_, new) in new }
        case .completeRegistration(let credentials):
            params.merge(credentials.params) { (_, new) in new }
        }
        
        return params
    }
    
    private var taskName: String {
        switch self {
        case .login:
            "login"
        case .postScannedPoint:
            "userPoints"
        case .renewPassword:
            "renewPswd"
        case .registerUser:
            "registerNewUser"
        case .completeRegistration:
            "completeRegistration"
        }
    }
    
    private var appParams: [String: String] {
        let appVersion = UserDefaults.standard.appVersion ?? ""
        let appId = UserDefaults.standard.appId ?? ""
        return [
            "appVer": "I\(appVersion)",
            "appId": appId
        ]
    }
}
