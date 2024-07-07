//
//  RegisterAppAPIResponse.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 07.07.2024.
//

import Foundation

// Example inner data structures conforming to the protocol
public struct RegisterAppAPIResponse: DataProtocol {
    let appId: String
    let versionCode: Int
    
    enum CodingKeys: CodingKey {
        case appId
        case versionCode
    }
    
}

public struct LoginAPIResponse: DataProtocol {
    let userId: String
    let email: String
    let nick: String
    let rights: Int
    let rightsCoded: String
    let token: String
    let userRank: Int
    let userPoints: Int
    let sex: UserGender
    let distance: Int
    let mainCategory: String
    let fullActivation: Bool
    
    enum CodingKeys: String, CodingKey {
        case userId
        case email
        case nick
        case rights
        case rightsCoded
        case token
        case userRank
        case userPoints
        case sex
        case distance
        case mainCategory
        case fullActivation
    }
}

