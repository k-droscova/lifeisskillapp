//
//  Point.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 07.08.2024.
//

import Foundation
import RealmSwift

class RealmGenericPointData: Object {
    @objc dynamic var dataID: String = "GenericPointData" // Single instance identified by a constant ID
    @objc dynamic var checkSum: String = ""
    let data = List<RealmGenericPoint>()
    
    override static func primaryKey() -> String? {
        "dataID"
    }
    
    override required init() {
        super.init()
    }
    
    convenience init(from genericPointData: GenericPointData) {
        self.init()
        self.checkSum = genericPointData.checkSum
        let points = genericPointData.data.map { RealmGenericPoint(from: $0) }
        self.data.append(objectsIn: points)
    }
    
    func toGenericPointData() -> GenericPointData {
        let points = data.map { $0.toGenericPoint() }
        return GenericPointData(checkSum: checkSum, data: Array(points))
    }
}

class RealmGenericPoint: Object {
    @objc dynamic var pointID: String = ""
    @objc dynamic var pointLat: Double = 0.0
    @objc dynamic var pointLng: Double = 0.0
    @objc dynamic var pointAlt: Double = 0.0
    @objc dynamic var pointName: String = ""
    @objc dynamic var pointValue: Int = 0
    @objc dynamic var pointType: Int = 0
    @objc dynamic var cluster: String = ""
    @objc dynamic var pointSpec: Int = 0
    @objc dynamic var sponsorID: String = ""
    @objc dynamic var hasDetail: Bool = false
    @objc dynamic var active: Bool = true
    @objc dynamic var param: RealmPointParam?
    
    override static func primaryKey() -> String? {
        return "pointID"
    }
    
    override required init() {
        super.init()
    }
    
    convenience init(from genericPoint: GenericPoint) {
        self.init()
        self.pointID = genericPoint.id
        self.pointLat = genericPoint.pointLat
        self.pointLng = genericPoint.pointLng
        self.pointAlt = genericPoint.pointAlt
        self.pointName = genericPoint.pointName
        self.pointValue = genericPoint.pointValue
        self.pointType = genericPoint.pointType.rawValue
        self.cluster = genericPoint.cluster
        self.pointSpec = genericPoint.pointSpec
        self.sponsorID = genericPoint.sponsorId
        self.hasDetail = genericPoint.hasDetail
        self.active = genericPoint.active
        if let param = genericPoint.param {
            self.param = RealmPointParam(from: param)
        }
    }
    
    func toGenericPoint() -> GenericPoint {
        return GenericPoint(from: self)
    }
}

class RealmPointParam: Object {
    @objc dynamic var timer: RealmTimerParam?
    @objc dynamic var status: RealmStatusParam?
    
    override required init() {
        super.init()
    }
    
    convenience init(from param: PointParam) {
        self.init()
        self.timer = param.timer.map { RealmTimerParam(from: $0) }
        self.status = param.status.map { RealmStatusParam(from: $0) }
    }
    
    func toPointParam() -> PointParam {
        return PointParam(
            timer: self.timer?.toTimerParam(),
            status: self.status?.toStatusParam()
        )
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
    
    convenience init(from timerParam: TimerParam) {
        self.init()
        self.base = timerParam.base
        self.done = timerParam.done
        self.maxTime = timerParam.maxTime
        self.minTime = timerParam.minTime
        self.distance = timerParam.distance
    }
    
    func toTimerParam() -> TimerParam {
        return TimerParam(
            base: self.base,
            done: self.done,
            maxTime: self.maxTime,
            minTime: self.minTime,
            distance: self.distance
        )
    }
}

class RealmStatusParam: Object {
    @objc dynamic var color: String = ""
    @objc dynamic var isValid: Bool = false
    
    override required init() {
        super.init()
    }
    
    convenience init(from statusParam: StatusParam) {
        self.init()
        self.color = statusParam.color
        self.isValid = statusParam.isValid
    }
    
    func toStatusParam() -> StatusParam {
        return StatusParam(
            color: self.color,
            isValid: self.isValid
        )
    }
}
