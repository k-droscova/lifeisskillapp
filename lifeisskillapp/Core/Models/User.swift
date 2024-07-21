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

// Model for user data from the listUserRank endpoint
struct RankedUser: UserProtocol, Codable {
    let userId: String         // Unique identifier for the user
    let email: String          // User's email address
    let nick: String           // User's nickname
    let sex: UserGender        // User's sex
    let order: String          // User's order in the ranking list
    let points: String         // User's points
    let lastTime: String       // Last time the user was active
    let psc: String            // Postal code
    let emailr: String         // Secondary email address
    let mobil: String          // Mobile phone number
    let mobilr: String         // Secondary mobile phone number
}

// Model for user data from the login endpoint
struct LoggedInUser: UserProtocol, Codable {
    let userId: String         // Unique identifier for the user
    let email: String          // User's email address
    let nick: String           // User's nickname
    let sex: UserGender        // User's sex
    let rights: Int            // User's rights (permissions level)
    let rightsCoded: String    // Coded representation of user's rights
    let token: String          // Authentication token
    let userRank: Int          // User's rank
    let userPoints: Int        // User's points
    let distance: Int          // Distance to some reference point
    let mainCategory: String   // User's main category
    let fullActivation: Bool   // Whether the user's account is fully activated
}

// Extend the UserProtocol to provide a default implementation for the id property
extension UserProtocol {
    var id: String {
        return userId
    }
}
