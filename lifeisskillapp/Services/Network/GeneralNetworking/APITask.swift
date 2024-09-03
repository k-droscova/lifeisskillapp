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
    case registerUser(credentials: RegistrationCredentials, location: UserLocation)
    
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
        case .login, .postScannedPoint: // forgot password and
            params.merge(appParams) { (_, new) in new }
        default:
            break
        }
        
        // Add specific parameters based on the case
        switch self {
        case .login(let credentials, let location):
            params.merge([
                "user": credentials.username,
                "pswd": credentials.password,
                "lat": String(location.latitude),
                "lng": String(location.longitude)
            ]) { (_, new) in new }
            
        case .postScannedPoint(let point):
            guard let location = point.location else {
                return [:] // will throw error when sent to API, but that is a good thing
            }
            let date = location.timestamp
            params.merge([
                "code": point.code,
                "codeSource": point.codeSource.rawValue,
                "lat": String(location.latitude),
                "lng": String(location.longitude),
                "acc": String(location.accuracy),
                "alt": String(location.altitude),
                "time": date.toPointListString()
            ]) { (_, new) in new }
            
        case .renewPassword(let credentials):
            params.merge([
                "pin": credentials.pin,
                "newPswd": credentials.newPassword,
                "email": credentials.email
            ]) { (_, new) in new }
            
        case .registerUser(let credentials, let location):
            params.merge([
                "nick": credentials.username,
                "email": credentials.email,
                "pswd": credentials.password,
                "lat": String(location.latitude),
                "lng": String(location.longitude)
            ]) { (_, new) in new }
        }
        
        return params
    }
    
    private var taskName: String {
        switch self {
        case .login:
            return "login"
        case .postScannedPoint:
            return "userPoints"
        case .renewPassword:
            return "renewPswd"
        case .registerUser:
            return "registerNewUser"
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
