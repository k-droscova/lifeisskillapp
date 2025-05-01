//
//  DataCheckSum.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 15.07.2024.
//

import Foundation

struct CheckSumData: Codable, Equatable {
    var userPoints: String
    var rank: String
    var messages: String
    var events: String
    var points: String
    
    enum CheckSumType: Int {
        case userPoints = 1
        case rank = 2
        case messages = 3
        case events = 4
        case points = 5
    }
    
    // Internal initializer to create CheckSumData from RealmCheckSumData
    internal init(from realmCheckSum: RealmCheckSumData) {
        self.userPoints = realmCheckSum.userPoints
        self.rank = realmCheckSum.rank
        self.messages = realmCheckSum.messages
        self.events = realmCheckSum.events
        self.points = realmCheckSum.points
    }
    
    init(userPoints: String, rank: String, messages: String, events: String, points: String) {
        self.userPoints = userPoints
        self.events = events
        self.messages = messages
        self.points = points
        self.rank = rank
    }
}
