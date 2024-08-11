//
//  Ranking.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 07.08.2024.
//

import Foundation
import RealmSwift

class RealmUserRankData: Object {
    @objc dynamic var dataID: String = "UserRankData"
    @objc dynamic var checkSum: String = ""
    let data = List<RealmUserRank>()

    override static func primaryKey() -> String? {
        "dataID"
    }
    
    override required init() {
        super.init()
    }
    
    // Custom initializer to create RealmUserRankData from UserRankData
    internal init(from userRankData: UserRankData) {
        super.init()
        self.checkSum = userRankData.checkSum
        let ranks = userRankData.data.map { RealmUserRank(from: $0) }
        self.data.append(objectsIn: ranks)
    }
    
    // Method to convert RealmUserRankData back to UserRankData
    func toUserRankData() -> UserRankData {
        let ranks = data.map { $0.toUserRank() }
        return UserRankData(checkSum: checkSum, data: Array(ranks))
    }
}

class RealmUserRank: Object {
    @objc dynamic var catId: String = ""
    @objc dynamic var catUserRank: Int = 0
    let listUserRank = List<RealmRankedUser>()

    override static func primaryKey() -> String? {
        return "catId"
    }
    
    override required init() {
        super.init()
    }
    
    // Custom initializer to create RealmUserRank from UserRank
    internal init(from userRank: UserRank) {
        super.init()
        self.catId = userRank.catId
        self.catUserRank = userRank.catUserRank
        let rankedUsers = userRank.listUserRank.map { RealmRankedUser(from: $0) }
        self.listUserRank.append(objectsIn: rankedUsers)
    }
    
    // Method to convert RealmUserRank back to UserRank
    func toUserRank() -> UserRank {
        let rankedUsers = listUserRank.compactMap { $0.toRankedUser() }
        return UserRank(catId: catId, catUserRank: catUserRank, listUserRank: Array(rankedUsers))
    }
}

class RealmRankedUser: Object {
    @objc dynamic var userId: String = ""
    @objc dynamic var email: String = ""
    @objc dynamic var nick: String = ""
    @objc dynamic var sexRaw: String = ""
    @objc dynamic var order: String = ""
    @objc dynamic var points: String = ""
    @objc dynamic var lastTime: String = ""
    @objc dynamic var psc: String = ""
    @objc dynamic var emailr: String = ""
    @objc dynamic var mobil: String = ""
    @objc dynamic var mobilr: String = ""

    override static func primaryKey() -> String? {
        return "userId"
    }
    
    override required init() {
        super.init()
    }
    
    // Custom initializer to create RealmRankedUser from RankedUser
    internal init(from rankedUser: RankedUser) {
        super.init()
        self.userId = rankedUser.userId
        self.email = rankedUser.email
        self.nick = rankedUser.nick
        self.sexRaw = rankedUser.sex.rawValue
        self.order = rankedUser.order
        self.points = rankedUser.points
        self.lastTime = rankedUser.lastTime
        self.psc = rankedUser.psc
        self.emailr = rankedUser.emailr
        self.mobil = rankedUser.mobil
        self.mobilr = rankedUser.mobilr
    }
    
    // Method to convert RealmRankedUser back to RankedUser
    func toRankedUser() -> RankedUser? {
        guard let sex = UserGender(rawValue: self.sexRaw) else {
            return nil
        }
        
        return RankedUser(
            userId: self.userId,
            email: self.email,
            nick: self.nick,
            sex: sex,
            order: self.order,
            points: self.points,
            lastTime: self.lastTime,
            psc: self.psc,
            emailr: self.emailr,
            mobil: self.mobil,
            mobilr: self.mobilr
        )
    }
}
