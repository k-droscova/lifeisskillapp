//
//  PointScan.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 07.08.2024.
//

import Foundation
import RealmSwift

class RealmPointScan: Object {
    @objc dynamic var scanID: String = ""
    @objc dynamic var pointID: String = ""
    @objc dynamic var pointTime: Date = Date()
    @objc dynamic var accuracy: Double = 0.0
    @objc dynamic var codeSource: String = ""
    @objc dynamic var doesPointCount: Bool = true
    let pointCategory = List<String>()
    @objc dynamic var duration: TimeInterval = 0.0
    @objc dynamic var userID: String = ""
    
    override static func primaryKey() -> String? {
        "scanID"
    }
    
    override required init() {
        super.init()
    }
    
    internal init(from userPoint: UserPoint, userID: String) {
        super.init()
        self.pointID = userPoint.id  // Set pointID instead of genericPoint
        self.scanID = userPoint.recordKey  // Use recordKey as scanID
        self.pointTime = userPoint.pointTime
        self.accuracy = userPoint.accuracy
        self.codeSource = userPoint.codeSource.rawValue
        self.doesPointCount = userPoint.doesPointCount
        self.duration = userPoint.duration ?? 0.0
        self.pointCategory.append(objectsIn: userPoint.pointCategory)
        self.userID = userID
    }
}
