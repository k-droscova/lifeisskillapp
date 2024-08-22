//
//  UserRank.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 21.07.2024.
//

import Foundation

struct UserRank: UserData {
    var id: String { catId }   // Implement id to correspond to catId
    let catId: String          // Category ID
    let catUserRank: Int       // User's rank in this category
    let listUserRank: [RankedUser] // List of users ranked in this category
}

/// Model for user data from the Rank endpoint
struct RankedUser: UserProtocol, Codable {
    /// Unique identifier for the user
    let userId: String
    
    /// User's email address
    let email: String
    
    /// User's nickname
    let nick: String
    
    /// User's sex
    let sex: UserGender
    
    /// User's order in the ranking list
    let order: String
    
    /// User's points
    let points: String
    
    /// Last time the user was active
    let lastTime: String
    
    /// Postal code
    let psc: String
    
    /// Secondary email address
    let emailr: String
    
    /// Mobile phone number
    let mobil: String
    
    /// Secondary mobile phone number
    let mobilr: String
}

struct Ranking: Identifiable {
    let id: String
    let rank: Int
    let username: String
    let points: Int
    let gender: UserGender     
    
    // Optional image of a trophy
    var trophyImage: String?
    
    // Initialize from RankedUser
    init(from rankedUser: RankedUser) {
        self.id = rankedUser.userId
        self.rank = Int(rankedUser.order) ?? 0
        self.username = rankedUser.nick
        self.points = Int(rankedUser.points) ?? 0
        self.gender = rankedUser.sex
        
        // Assign trophy image based on rank
        switch self.rank {
        case 1:
            self.trophyImage = CustomImages.Rankings.first.fullPath
        case 2:
            self.trophyImage = CustomImages.Rankings.second.fullPath
        case 3:
            self.trophyImage = CustomImages.Rankings.third.fullPath
        default:
            self.trophyImage = nil
        }
    }
    
    // Internal initializer
    internal init(id: String, rank: Int, username: String, points: Int, gender: UserGender, trophyImage: String? = nil) {
        self.id = id
        self.rank = rank
        self.username = username
        self.points = points
        self.gender = gender
        
        // Assign trophy image based on rank
        switch self.rank {
        case 1:
            self.trophyImage = trophyImage ?? CustomImages.Rankings.first.fullPath
        case 2:
            self.trophyImage = trophyImage ?? CustomImages.Rankings.second.fullPath
        case 3:
            self.trophyImage = trophyImage ?? CustomImages.Rankings.third.fullPath
        default:
            self.trophyImage = trophyImage
        }
    }
}
