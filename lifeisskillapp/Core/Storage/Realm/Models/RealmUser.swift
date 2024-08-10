//
//  RealmUser.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 07.08.2024.
//

import Foundation
import RealmSwift

class RealmUser: Object {
    @objc dynamic var userID: String = ""
    @objc dynamic var email: String = ""
    @objc dynamic var nick: String = ""
    @objc dynamic var sexRaw: String = ""
    @objc dynamic var mainCategory: String = ""
    let rankings = List<RealmRanking>()

    override static func primaryKey() -> String? {
        "userID"
    }

    var sex: UserGender {
        get { return UserGender(rawValue: sexRaw) ?? .male }
        set { sexRaw = newValue.rawValue }
    }

    override required init() {
        super.init()
    }
}
