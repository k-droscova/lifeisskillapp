//
//  Credentials.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 03.09.2024.
//

import Foundation

protocol Credentials {
    var params: [String: String] { get }
}

struct LoginCredentials: Codable, Credentials {
    let username: String
    let password: String
    
    var params: [String: String] {
        [
            "user": username,
            "pswd": password
        ]
    }
}

struct NewRegistrationCredentials: Credentials {
    let username: String
    let email: String
    let password: String
    let referenceUserId: String? = nil
    
    var params: [String: String] {
        var params: [String: String] = [
            "nick": username,
            "email": email,
            "pswd": password
        ]
        
        if let referenceUserId = referenceUserId {
            params["refId"] = referenceUserId
        }
        
        return params
    }
}

struct ForgotPasswordCredentials: Codable, Credentials {
    let email: String
    let newPassword: String
    let pin: String
    
    var params: [String: String] {
        [
            "email": email,
            "newPswd": newPassword,
            "pin": pin
        ]
    }
}
