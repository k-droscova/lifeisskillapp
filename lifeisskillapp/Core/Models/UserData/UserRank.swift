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
