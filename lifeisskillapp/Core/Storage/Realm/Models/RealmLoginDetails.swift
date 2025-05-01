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
    @objc dynamic var isLoggedIn: Bool = true
    
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
        name = loggedInUser.name.emptyIfNil
        surname = loggedInUser.surname.emptyIfNil
        mobil = loggedInUser.mobil.emptyIfNil
        postalCode = loggedInUser.postalCode.emptyIfNil
        nameParent = loggedInUser.nameParent.emptyIfNil
        surnameParent = loggedInUser.surnameParent.emptyIfNil
        emailParent = loggedInUser.emailParent.emptyIfNil
        mobilParent = loggedInUser.mobilParent.emptyIfNil
        relation = loggedInUser.relation.emptyIfNil
        birthday = loggedInUser.birthday // Date? type is supported in Realm
    }
    
    func loginUserData() -> LoginUserData? {
        guard let user = loggedInUser() else {
            return nil
        }
        return LoginUserData(from: user)
    }
    
    func loggedInUser() -> LoggedInUser? {
        guard
            let sex = UserGender(rawValue: sexRaw),
            let status = UserActivationStatus(rawValue: activationStatus)
        else {
            return nil
        }
        return LoggedInUser(
            userId: userID,
            email: email,
            nick: nick,
            sex: sex,
            rights: rights,
            rightsCoded: rightsCoded,
            token: token,
            userRank: userRank,
            userPoints: userPoints,
            distance: distance,
            mainCategory: mainCategory,
            fullActivation: fullActivation,
            activationStatus: status,
            name: name.nilIfEmpty,
            surname: surname.nilIfEmpty,
            mobil: mobil.nilIfEmpty,
            postalCode: postalCode.nilIfEmpty,
            birthday: birthday,
            nameParent: nameParent.nilIfEmpty,
            surnameParent: surnameParent.nilIfEmpty,
            emailParent: emailParent.nilIfEmpty,
            mobilParent: mobilParent.nilIfEmpty,
            relation: relation.nilIfEmpty
        )
    }
}
