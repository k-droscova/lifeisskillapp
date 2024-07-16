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
}
