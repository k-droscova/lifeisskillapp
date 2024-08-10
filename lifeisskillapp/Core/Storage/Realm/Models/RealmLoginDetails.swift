//
//  LoginDetails.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 07.08.2024.
//

import Foundation
import RealmSwift

class RealmLoginDetails: Object {
    @objc dynamic var userID: String = ""
    @objc dynamic var rights: Int = 0
    @objc dynamic var rightsCoded: String = ""
    @objc dynamic var token: String = ""
    @objc dynamic var distance: Int = 0
    @objc dynamic var fullActivation: Bool = false
    @objc dynamic var user: RealmUser?

    override static func primaryKey() -> String? {
        "userID"
    }

    override required init() {
        super.init()
    }
}
