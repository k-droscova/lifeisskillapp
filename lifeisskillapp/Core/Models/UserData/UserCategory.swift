//
//  UserCategory.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 15.07.2024.
//

import Foundation

struct UserCategory: Codable {
    let id: String
    let name: String
    let description: String
    let isPublic: Bool

    enum CodingKeys: String, CodingKey {
        case id = "catID"
        case name = "catName"
        case description = "catDetail"
        case isPublic = "public"
    }
}
