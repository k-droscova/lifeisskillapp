//
//  UserCategory.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 15.07.2024.
//

import Foundation

struct UserCategory: UserData, CustomStringConvertible {
    let id: String
    let name: String
    let detail: String
    let isPublic: Bool

    enum CodingKeys: String, CodingKey {
        case id = "catID"
        case name = "catName"
        case detail = "catDetail"
        case isPublic = "public"
    }
    
    var description: String {
        name
    }
}
