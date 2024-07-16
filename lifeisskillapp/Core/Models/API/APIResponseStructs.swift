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

public struct CheckSumUserPointsData: DataProtocol {
    let pointsProtect: String
}

public struct CheckSumRankData: DataProtocol {
    let rankProtect: String
}

public struct CheckSumMessagesData: DataProtocol {
    let msgProtect: String
}

public struct CheckSumEventsData: DataProtocol {
    let eventsProtect: String
}

public struct CheckSumPointsData: DataProtocol {
    let pointsProtect: String
    let clusterProtect: String?
}

struct UserCategoryData: DataProtocol {
    let main: UserCategory
    let data: [UserCategory]
    
    enum CodingKeys: String, CodingKey {
        case main = "userMainCategory"
        case data = "allUserCategoryList"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        // Decode the main category ID
        let mainCategoryID = try container.decode(String.self, forKey: .main)
        // Decode the list of all user categories
        var allUserCategories = try container.decode([UserCategory].self, forKey: .data)
        // Find the main category from the list
        guard let mainCategory = allUserCategories.first(where: { $0.id == mainCategoryID }) else {
            throw DecodingError.dataCorruptedError(forKey: .main, in: container, debugDescription: "Main category ID does not match any category in the list")
        }
        // Assign the found main category and the list of categories
        self.main = mainCategory
        self.data = allUserCategories
    }
}

struct UserPointData: DataProtocol {
    let checkSum: String
    let data: [UserPoint]
    
    enum CodingKeys: String, CodingKey {
        case data = "listPoints"
        case checkSum = "userPointsProtect"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        checkSum = try container.decode(String.self, forKey: .checkSum)
        data = try container.decode([UserPoint].self, forKey: .data)
    }
}
