//
//  LoginDetails.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 07.08.2024.
//

import Foundation
import RealmSwift

class RealmLoginDetails: Object {
    @objc dynamic var loginID: String = "LoginDetailsData" // Single instance identified by a constant ID
    @objc dynamic var userID: String = ""
    @objc dynamic var email: String = ""
    @objc dynamic var nick: String = ""
    @objc dynamic var sexRaw: String = ""
    @objc dynamic var rights: Int = 0
    @objc dynamic var rightsCoded: String = ""
    @objc dynamic var token: String = ""
    @objc dynamic var userRank: Int = 0
    @objc dynamic var userPoints: Int = 0
    @objc dynamic var distance: Int = 0
    @objc dynamic var mainCategory: String = ""
    @objc dynamic var fullActivation: Bool = false
    @objc dynamic var isLoggedIn: Bool = false

    override static func primaryKey() -> String? {
        "loginID"
    }

    override required init() {
        super.init()
    }
    
    convenience init(from loggedInUser: LoggedInUser) {
        self.init()
        self.userID = loggedInUser.userId
        self.email = loggedInUser.email
        self.nick = loggedInUser.nick
        self.sexRaw = loggedInUser.sex.rawValue
        self.rights = loggedInUser.rights
        self.rightsCoded = loggedInUser.rightsCoded
        self.token = loggedInUser.token
        self.userRank = loggedInUser.userRank
        self.userPoints = loggedInUser.userPoints
        self.distance = loggedInUser.distance
        self.mainCategory = loggedInUser.mainCategory
        self.fullActivation = loggedInUser.fullActivation
    }
    
    func toLoginData() -> LoginUserData? {
        guard let user = toLoggedInUser() else {
            return nil
        }
        return LoginUserData(from: user)
    }
    
    private func toLoggedInUser() -> LoggedInUser? {
        guard let sex = UserGender(rawValue: self.sexRaw) else {
            return nil
        }
        return LoggedInUser(
            userId: self.userID,
            email: self.email,
            nick: self.nick,
            sex: sex,
            rights: self.rights,
            rightsCoded: self.rightsCoded,
            token: self.token,
            userRank: self.userRank,
            userPoints: self.userPoints,
            distance: self.distance,
            mainCategory: self.mainCategory,
            fullActivation: self.fullActivation
        )
    }
}
