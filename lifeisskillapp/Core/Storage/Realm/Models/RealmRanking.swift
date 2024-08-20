//
//  Ranking.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 07.08.2024.
//

import Foundation
import RealmSwift

class RealmUserRankData: Object {
    @objc dynamic var dataID: String = "UserRankData"  // Single instance identified by a constant ID
    @objc dynamic var checkSum: String = ""
    let data = List<RealmUserRank>()
    
    override static func primaryKey() -> String? {
        "dataID"
    }
    
    override required init() {
        super.init()
    }
    
    convenience init(from userRankData: UserRankData) {
        self.init()
        checkSum = userRankData.checkSum
        let ranks = userRankData.data.map { RealmUserRank(from: $0) }
        data.append(objectsIn: ranks)
    }
    
    func userRankData() -> UserRankData {
        let ranks = data.map { $0.userRank() }
        return UserRankData(checkSum: checkSum, data: Array(ranks))
    }
}

class RealmUserRank: Object {
    @objc dynamic var catID: String = ""
    @objc dynamic var catUserRank: Int = 0
    let listUserRank = List<RealmRankedUser>()
    
    override static func primaryKey() -> String? {
        return "catID"
    }
    
    override required init() {
        super.init()
    }
    
    convenience init(from userRank: UserRank) {
        self.init()
        catID = userRank.catId
        catUserRank = userRank.catUserRank
        let rankedUsers = userRank.listUserRank.map { RealmRankedUser(from: $0) }
        listUserRank.append(objectsIn: rankedUsers)
    }
    
    func userRank() -> UserRank {
        let rankedUsers = listUserRank.compactMap { $0.rankedUser() }
        return UserRank(catId: catID, catUserRank: catUserRank, listUserRank: Array(rankedUsers))
    }
}

class RealmRankedUser: Object {
    @objc dynamic var rankingID: String = UUID().uuidString // required since users can be ranked in multiple categories (cannot use userId)
    @objc dynamic var userID: String = ""
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
        "rankingID"
    }
    
    override required init() {
        super.init()
    }
    
    convenience init(from rankedUser: RankedUser) {
        self.init()
        userID = rankedUser.userId
        email = rankedUser.email
        nick = rankedUser.nick
        sexRaw = rankedUser.sex.rawValue
        order = rankedUser.order
        points = rankedUser.points
        lastTime = rankedUser.lastTime
        psc = rankedUser.psc
        emailr = rankedUser.emailr
        mobil = rankedUser.mobil
        mobilr = rankedUser.mobilr
    }
    
    func rankedUser() -> RankedUser? {
        guard let sex = UserGender(rawValue: self.sexRaw) else {
            return nil
        }
        return RankedUser(
            userId: self.userID,
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
