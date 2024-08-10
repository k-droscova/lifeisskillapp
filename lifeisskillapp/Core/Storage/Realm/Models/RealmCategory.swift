//
//  RealmCategory.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 07.08.2024.
//

import Foundation
import RealmSwift

class RealmCategory: Object {
    @objc dynamic var categoryID: String = ""
    @objc dynamic var name: String = ""
    @objc dynamic var detail: String = ""
    @objc dynamic var isPublic: Bool = false
    let rankings = List<RealmRanking>()
    
    override static func primaryKey() -> String? {
        "categoryID"
    }
    
    override required init() {
        super.init()
    }
    
    internal init(from userCategory: UserCategory) {
        super.init()
        self.categoryID = userCategory.id
        self.name = userCategory.name
        self.detail = userCategory.detail
        self.isPublic = userCategory.isPublic
    }
}
