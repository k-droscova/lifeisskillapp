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
    
    init(catId: String, catUserRank: Int, listUserRank: [RankedUser]) {
        self.catId = catId
        self.catUserRank = catUserRank
        self.listUserRank = listUserRank
    }
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
    
    init(userId: String, email: String, nick: String, sex: UserGender, order: String, points: String, lastTime: String, psc: String, emailr: String, mobil: String, mobilr: String) {
        self.userId = userId
        self.email = email
        self.nick = nick
        self.sex = sex
        self.order = order
        self.points = points
        self.lastTime = lastTime
        self.psc = psc
        self.emailr = emailr
        self.mobil = mobil
        self.mobilr = mobilr
    }
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
    
    init(id: String, rank: Int, username: String, points: Int, gender: UserGender, trophyImage: String? = nil) {
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

struct MockData {
    static func generateRankings(count: Int) -> [Ranking] {
        var rankings: [Ranking] = []
        
        // Define a base points range
        let maxPoints = 1500
        let minPoints = 500
        
        // Calculate step decrement for points based on the count
        let pointsDecrement = (maxPoints - minPoints) / max(count - 1, 1)
        
        for i in 1...count {
            let username = "User\(i)"
            
            // Calculate points in decreasing order
            let points = maxPoints - (i - 1) * pointsDecrement
            
            let gender: UserGender = (i % 2 == 0) ? .male : .female
            rankings.append(Ranking(id: UUID().uuidString, rank: i, username: username, points: points, gender: gender))
        }
        return rankings
    }
    
    static func generateRankedUsers(count: Int) -> [RankedUser] {
        var rankedUsers: [RankedUser] = []
        // Define a base points range
        let maxPoints = 1500
        let minPoints = 500
        
        // Calculate step decrement for points based on the count
        let pointsDecrement = (maxPoints - minPoints) / max(count - 1, 1)
        for i in 1...count {
            let username = "User\(i)"
            
            // Calculate points in decreasing order
            let points = maxPoints - (i - 1) * pointsDecrement
            
            let gender: UserGender = (i % 2 == 0) ? .male : .female
            rankedUsers.append(RankedUser.init(userId: "Mock\(i)", email: "", nick: "RankedUser\(i)", sex: gender, order: "\(i)", points: "\(points)", lastTime: "", psc: "", emailr: "", mobil: "", mobilr: ""))
        }
        return rankedUsers
    }
}
