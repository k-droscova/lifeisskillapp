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
    let referenceUserId: String?
    
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


// TODO: ensure that the params are correct
struct GuardianInfo: Codable, Credentials {
    let firstName: String
    let lastName: String
    let phoneNumber: String
    let email: String
    let relationship: String
    
    var params: [String : String] {
        [
            "nameParent": firstName,
            "surnameParent": lastName,
            "phoneParent": phoneNumber,
            "emailParent": email,
            "relation": relationship
        ]
    }
}

struct FullRegistrationCredentials: Codable, Credentials {
    let firstName: String
    let lastName: String
    let phoneNumber: String
    let dateOfBirth: Date
    let gender: UserGender
    let postalCode: String
    let guardianInfo: GuardianInfo? // Optional, only needed if the user is a minor
    
    var params: [String: String] {
        var params = [
            "name": firstName,
            "surname": lastName,
            "phone": phoneNumber,
            "birthday": dateOfBirth.toPointListString(), // TODO: ask about format
            "sex": gender.rawValue,
            "zip": postalCode
        ]
        
        // If guardianInfo is not nil, merge its params with the existing params
        if let guardianParams = guardianInfo?.params {
            params.merge(guardianParams) { (current, _) in current }
        }
        
        return params
    }
}
