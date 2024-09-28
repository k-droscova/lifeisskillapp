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

public struct LoginCredentials: Codable, Credentials {
    let username: String
    let password: String
    
    public init(username: String, password: String) {
        self.username = username
        self.password = password
    }
    
    var params: [String: String] {
        [
            "user": username,
            "pswd": password
        ]
    }
}

public struct NewRegistrationCredentials: Credentials {
    let username: String
    let email: String
    let password: String
    let referenceUserId: String?
    
    public init(username: String, email: String, password: String, referenceUserId: String? = nil) {
        self.username = username
        self.email = email
        self.password = password
        self.referenceUserId = referenceUserId
    }
    
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

public struct ForgotPasswordCredentials: Codable, Credentials {
    let email: String
    let newPassword: String
    let pin: String
    
    public init(email: String, newPassword: String, pin: String) {
        self.email = email
        self.newPassword = newPassword
        self.pin = pin
    }
    
    var params: [String: String] {
        [
            "email": email,
            "newPswd": newPassword,
            "pin": pin
        ]
    }
}

public struct GuardianInfo: Codable, Credentials {
    let firstName: String
    let lastName: String
    let phoneNumber: String
    let email: String
    let relationship: String
    
    public init(firstName: String, lastName: String, phoneNumber: String, email: String, relationship: String) {
        self.firstName = firstName
        self.lastName = lastName
        self.phoneNumber = phoneNumber
        self.email = email
        self.relationship = relationship
    }
    
    var params: [String: String] {
        [
            "nameParent": firstName,
            "surnameParent": lastName,
            "phoneParent": phoneNumber,
            "emailParent": email,
            "relation": relationship
        ]
    }
}

public struct FullRegistrationCredentials: Codable, Credentials {
    let firstName: String
    let lastName: String
    let phoneNumber: String
    let dateOfBirth: Date
    let gender: UserGender
    let postalCode: String
    let guardianInfo: GuardianInfo?
    
    public init(firstName: String, lastName: String, phoneNumber: String, dateOfBirth: Date, gender: UserGender, postalCode: String, guardianInfo: GuardianInfo? = nil) {
        self.firstName = firstName
        self.lastName = lastName
        self.phoneNumber = phoneNumber
        self.dateOfBirth = dateOfBirth
        self.gender = gender
        self.postalCode = postalCode
        self.guardianInfo = guardianInfo
    }
    
    var params: [String: String] {
        var params = [
            "name": firstName,
            "surname": lastName,
            "phone": phoneNumber,
            "birthday": Date.Backend.getBirthdayString(from: dateOfBirth),
            "sex": gender.rawValue,
            "zip": postalCode
        ]
        
        if let guardianParams = guardianInfo?.params {
            params.merge(guardianParams) { (current, _) in current }
        }
        
        return params
    }
}
