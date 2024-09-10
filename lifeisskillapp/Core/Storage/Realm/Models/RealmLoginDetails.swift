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
    @objc dynamic var activationStatus: Int = 0
    @objc dynamic var isLoggedIn: Bool = false
    
    // New fields from the updated LoggedInUser structure
    @objc dynamic var name: String = ""
    @objc dynamic var surname: String = ""
    @objc dynamic var mobil: String = ""
    @objc dynamic var postalCode: String = ""
    @objc dynamic var birthday: Date? = nil
    @objc dynamic var nameParent: String = ""
    @objc dynamic var surnameParent: String = ""
    @objc dynamic var emailParent: String = ""
    @objc dynamic var mobilParent: String = ""
    @objc dynamic var relation: String = ""
    
    override static func primaryKey() -> String? {
        "loginID"
    }
    
    override required init() {
        super.init()
    }
    
    /// Convenience initializer to populate from a `LoggedInUser`
    convenience init(from loggedInUser: LoggedInUser) {
        self.init()
        userID = loggedInUser.userId
        email = loggedInUser.email
        nick = loggedInUser.nick
        sexRaw = loggedInUser.sex.rawValue
        rights = loggedInUser.rights
        rightsCoded = loggedInUser.rightsCoded
        token = loggedInUser.token
        userRank = loggedInUser.userRank
        userPoints = loggedInUser.userPoints
        distance = loggedInUser.distance
        mainCategory = loggedInUser.mainCategory
        fullActivation = loggedInUser.fullActivation
        activationStatus = loggedInUser.activationStatus.rawValue
        
        // Assign the new optional fields, replacing nil with empty strings where needed
        name = loggedInUser.name ?? ""
        surname = loggedInUser.surname ?? ""
        mobil = loggedInUser.mobil ?? ""
        postalCode = loggedInUser.postalCode ?? ""
        birthday = loggedInUser.birthday // Date? type is supported in Realm
        nameParent = loggedInUser.nameParent ?? ""
        surnameParent = loggedInUser.surnameParent ?? ""
        emailParent = loggedInUser.emailParent ?? ""
        mobilParent = loggedInUser.mobilParent ?? ""
        relation = loggedInUser.relation ?? ""
    }
    
    func loginUserData() -> LoginUserData? {
        guard let user = loggedInUser() else {
            return nil
        }
        return LoginUserData(from: user)
    }
    
    func loggedInUser() -> LoggedInUser? {
        guard let sex = UserGender(rawValue: self.sexRaw),
              let status = UserActivationStatus(rawValue: self.activationStatus) else {
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
            fullActivation: self.fullActivation,
            activationStatus: status,
            name: self.name.isEmpty ? nil : self.name,
            surname: self.surname.isEmpty ? nil : self.surname,
            mobil: self.mobil.isEmpty ? nil : self.mobil,
            postalCode: self.postalCode.isEmpty ? nil : self.postalCode,
            birthday: self.birthday,
            nameParent: self.nameParent.isEmpty ? nil : self.nameParent,
            surnameParent: self.surnameParent.isEmpty ? nil : self.surnameParent,
            emailParent: self.emailParent.isEmpty ? nil : self.emailParent,
            mobilParent: self.mobilParent.isEmpty ? nil : self.mobilParent,
            relation: self.relation.isEmpty ? nil : self.relation
        )
    }
}
