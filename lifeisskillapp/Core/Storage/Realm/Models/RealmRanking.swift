//
//  Ranking.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 07.08.2024.
//

import Foundation
import RealmSwift

class RealmRanking: Object {
    @objc dynamic var rankingId: String = ""
    @objc dynamic var userId: String = ""
    @objc dynamic var categoryId: String = ""
    @objc dynamic var rank: Int = 1
    @objc dynamic var points: Int = 0

    override static func primaryKey() -> String? {
        "rankingId"
    }

    override required init() {
        super.init()
    }
}
