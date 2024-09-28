//
//  User.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 07.07.2024.
//

import Foundation

// Define the protocol with common user attributes
protocol UserProtocol: UserData {
    var userId: String { get }
    var email: String { get }
    var nick: String { get }
    var sex: UserGender { get }
}

// Extend the protocol for Codable to make it easy to decode
extension UserProtocol where Self: Codable {}

/// Model for user data from the login endpoint. Saved using UserLoginDataManager, this data is retrieved throughout App UI
public struct LoggedInUser: UserProtocol, Codable {
    /// Unique identifier for the user
    let userId: String
    
    /// User's email address
    let email: String
    
    /// User's nickname
    let nick: String
    
    /// User's sex
    let sex: UserGender
    
    /// User's rights (permissions level)
    let rights: Int
    
    /// Coded representation of user's rights
    let rightsCoded: String
    
    /// Authentication token
    let token: String
    
    /// User's rank
    let userRank: Int
    
    /// User's points
    let userPoints: Int
    
    /// Distance to some reference point
    let distance: Int
    
    /// User's main category
    let mainCategory: String
    
    /// Whether the user's account is fully activated
    let fullActivation: Bool
    
    /// Different levels of activation
    let activationStatus: UserActivationStatus
    
    /// Optional Fields for user personal details
    let name: String?
    let surname: String?
    let mobil: String?
    let postalCode: String?
    let birthday: Date?
    
    /// Computed property to calculate the user's age based on the birthday
    var age: Int? {
        birthday?.age
    }
    
    /// Optional Fields for parent's information
    let nameParent: String?
    let surnameParent: String?
    let emailParent: String?
    let mobilParent: String?
    let relation: String?
    
    public init(
        userId: String,
        email: String,
        nick: String,
        sex: UserGender,
        rights: Int,
        rightsCoded: String,
        token: String,
        userRank: Int,
        userPoints: Int,
        distance: Int,
        mainCategory: String,
        fullActivation: Bool,
        activationStatus: UserActivationStatus = .incomplete,
        name: String? = nil,
        surname: String? = nil,
        mobil: String? = nil,
        postalCode: String? = nil,
        birthday: Date? = nil,
        nameParent: String? = nil,
        surnameParent: String? = nil,
        emailParent: String? = nil,
        mobilParent: String? = nil,
        relation: String? = nil
    ) {
        self.userId = userId
        self.email = email
        self.nick = nick
        self.sex = sex
        self.rights = rights
        self.rightsCoded = rightsCoded
        self.token = token
        self.userRank = userRank
        self.userPoints = userPoints
        self.distance = distance
        self.mainCategory = mainCategory
        self.fullActivation = fullActivation
        self.activationStatus = activationStatus
        self.name = name
        self.surname = surname
        self.mobil = mobil
        self.postalCode = postalCode
        self.birthday = birthday
        self.nameParent = nameParent
        self.surnameParent = surnameParent
        self.emailParent = emailParent
        self.mobilParent = mobilParent
        self.relation = relation
    }
}

// Extend the UserProtocol to provide a default implementation for the id property
extension UserProtocol {
    public var id: String {
        userId
    }
}
