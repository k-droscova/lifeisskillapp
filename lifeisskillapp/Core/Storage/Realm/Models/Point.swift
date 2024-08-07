//
//  Point.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 07.08.2024.
//

import Foundation
import RealmSwift

class RealmPoint: Object {
    @objc dynamic var pointId: String = ""
    @objc dynamic var pointLat: Double = 0.0
    @objc dynamic var pointLng: Double = 0.0
    @objc dynamic var pointAlt: Double = 0.0
    @objc dynamic var pointName: String = ""
    @objc dynamic var pointValue: Int = 0
    @objc dynamic var pointType: Int = 0
    @objc dynamic var cluster: String = ""
    @objc dynamic var pointSpec: Int = 0
    @objc dynamic var sponsorId: String = ""
    @objc dynamic var hasDetail: Bool = false
    @objc dynamic var active: Bool = false
    @objc dynamic var param: RealmPointParam?

    override static func primaryKey() -> String? {
        return "pointId"
    }

    override required init() {
        super.init()
    }
}

class RealmPointParam: Object {
    @objc dynamic var timer: RealmTimerParam?
    @objc dynamic var status: RealmStatusParam?

    override required init() {
        super.init()
    }
}

class RealmTimerParam: Object {
    @objc dynamic var base: Int = 0
    @objc dynamic var done: Int = 0
    @objc dynamic var maxTime: Int = 0
    @objc dynamic var minTime: Int = 0
    @objc dynamic var distance: Int = 0

    override required init() {
        super.init()
    }
}

class RealmStatusParam: Object {
    @objc dynamic var color: String = ""
    @objc dynamic var isValid: Bool = false

    override required init() {
        super.init()
    }
}
