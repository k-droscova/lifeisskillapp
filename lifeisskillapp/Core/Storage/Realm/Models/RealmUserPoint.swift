//
//  PointScan.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 07.08.2024.
//

import Foundation
import RealmSwift

class RealmUserPointData: Object {
    @objc dynamic var dataID: String = "UserPointData" // Single instance identified by a constant ID
    @objc dynamic var checkSum: String = ""
    let data = List<RealmUserPoint>()
    
    override static func primaryKey() -> String? {
        "dataID"
    }
    
    override required init() {
        super.init()
    }
    
    convenience init(from userPointData: UserPointData) {
        self.init()
        checkSum = userPointData.checkSum
        let points = userPointData.data.map { RealmUserPoint(from: $0) }
        data.append(objectsIn: points)
    }
    
    func userPointData() -> UserPointData {
        let points = data.map { $0.userPoint() }
        return UserPointData(checkSum: checkSum, data: Array(points))
    }
}

class RealmUserPoint: Object {
    @objc dynamic var pointID: String = ""
    @objc dynamic var recordKey: String = ""
    @objc dynamic var pointTime: Date = Date()
    @objc dynamic var pointName: String = ""
    @objc dynamic var pointValue: Int = 0
    @objc dynamic var pointType: Int = 0
    @objc dynamic var pointSpec: Int = 0
    @objc dynamic var pointLat: Double = 0.0
    @objc dynamic var pointLng: Double = 0.0
    @objc dynamic var pointAlt: Double = 0.0
    @objc dynamic var accuracy: Double = 0.0
    @objc dynamic var codeSource: String = ""
    let pointCategory = List<String>()
    @objc dynamic var duration: TimeInterval = 0.0
    @objc dynamic var doesPointCount: Bool = true
    
    override static func primaryKey() -> String? {
        "recordKey"
    }
    
    override required init() {
        super.init()
    }
    
    convenience init(from userPoint: UserPoint) {
        self.init()
        pointID = userPoint.id
        recordKey = userPoint.recordKey
        pointTime = userPoint.pointTime
        pointName = userPoint.pointName
        pointValue = userPoint.pointValue
        pointType = userPoint.pointType.rawValue
        pointSpec = userPoint.pointSpec
        pointLat = userPoint.pointLat
        pointLng = userPoint.pointLng
        pointAlt = userPoint.pointAlt
        accuracy = userPoint.accuracy
        codeSource = userPoint.codeSource.rawValue
        pointCategory.append(objectsIn: userPoint.pointCategory)
        duration = userPoint.duration ?? 0.0
        doesPointCount = userPoint.doesPointCount
    }
    
    func userPoint() -> UserPoint {
        UserPoint(
            id: self.pointID,
            recordKey: self.recordKey,
            pointTime: self.pointTime,
            pointName: self.pointName,
            pointValue: self.pointValue,
            pointType: PointType(rawValue: self.pointType) ?? .unknown,
            pointSpec: self.pointSpec,
            pointLat: self.pointLat,
            pointLng: self.pointLng,
            pointAlt: self.pointAlt,
            accuracy: self.accuracy,
            codeSource: CodeSource(rawValue: self.codeSource) ?? .unknown,
            pointCategory: Array(self.pointCategory),
            duration: self.duration,
            doesPointCount: self.doesPointCount
        )
    }
}
