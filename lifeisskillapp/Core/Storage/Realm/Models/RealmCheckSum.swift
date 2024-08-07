//
//  CheckSum.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 07.08.2024.
//

import Foundation
import RealmSwift

class RealmCheckSumData: Object {
    @objc dynamic var id: String = "checksum" // Single instance identified by a constant ID
    @objc dynamic var userPoints: String = ""
    @objc dynamic var rank: String = ""
    @objc dynamic var messages: String = ""
    @objc dynamic var events: String = ""
    @objc dynamic var points: String = ""

    override static func primaryKey() -> String? {
        return "id"
    }

    override required init() {
        super.init()
    }
}
