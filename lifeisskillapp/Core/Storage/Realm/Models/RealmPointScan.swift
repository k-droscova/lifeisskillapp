//
//  PointScan.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 07.08.2024.
//

import Foundation
import RealmSwift

class RealmPointScan: Object {
    @objc dynamic var scanId: String = ""
    @objc dynamic var recordKey: String = ""
    @objc dynamic var pointTime: Date = Date()
    @objc dynamic var accuracy: Double = 0.0
    @objc dynamic var codeSource: Int = 0
    @objc dynamic var doesPointCount: Bool = true
    @objc dynamic var genericPoint: RealmPoint?
    let pointCategory = List<String>()
    @objc dynamic var duration: TimeInterval = 0.0

    override static func primaryKey() -> String? {
        return "scanId"
    }

    override required init() {
        super.init()
    }
}
