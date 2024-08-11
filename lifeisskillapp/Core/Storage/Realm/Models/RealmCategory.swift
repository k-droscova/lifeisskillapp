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

class RealmUserCategoryData: Object {
    @objc dynamic var dataID: String = "UserCategoryData"
    @objc dynamic var mainCategory: RealmCategory?
    let allCategories = List<RealmCategory>()

    override static func primaryKey() -> String? {
        "dataID"
    }
    
    override required init() {
        super.init()
    }
    
    internal init(from userCategoryData: UserCategoryData) {
        super.init()
        self.mainCategory = RealmCategory(from: userCategoryData.main)
        let categories = userCategoryData.data.map { RealmCategory(from: $0) }
        self.allCategories.append(objectsIn: categories)
    }
    
    func toUserCategoryData() -> UserCategoryData? {
        guard let mainCategory = mainCategory else { return nil }
        let main = UserCategory(id: mainCategory.categoryID, name: mainCategory.name, detail: mainCategory.detail, isPublic: mainCategory.isPublic)
        let categories = Array(allCategories.map { UserCategory(id: $0.categoryID, name: $0.name, detail: $0.detail, isPublic: $0.isPublic) })
        return UserCategoryData(main: main, data: categories)
    }
}
