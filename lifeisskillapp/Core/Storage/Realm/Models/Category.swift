//
//  RealmCategory.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 07.08.2024.
//

import Foundation
import RealmSwift

class RealmCategory: Object {
    @objc dynamic var categoryId: String = ""
    @objc dynamic var name: String = ""
    @objc dynamic var detail: String = ""
    @objc dynamic var isPublic: Bool = false

    override static func primaryKey() -> String? {
        return "categoryId"
    }

    override required init() {
        super.init()
    }
}
