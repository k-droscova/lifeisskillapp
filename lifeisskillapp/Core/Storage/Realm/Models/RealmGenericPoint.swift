//
//  Point.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 07.08.2024.
//

import Foundation
import RealmSwift

class RealmGenericPointData: Object {
    @objc dynamic var checkSum: String = ""
    let data = List<RealmGenericPoint>()
    
    override required init() {
        super.init()
    }
    
    // Custom initializer to create RealmGenericPointData from GenericPointData
    internal init(from genericPointData: GenericPointData) {
        super.init()
        self.checkSum = genericPointData.checkSum
        let points = genericPointData.data.map { RealmGenericPoint(from: $0) }
        self.data.append(objectsIn: points)
    }
    
    // Method to convert RealmGenericPointData back to GenericPointData
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
    
    // Custom initializer to create RealmGenericPoint from GenericPoint
    internal init(from genericPoint: GenericPoint) {
        super.init()
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
    
    // Method to convert RealmGenericPoint back to GenericPoint
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
    
    // Custom initializer to create RealmPointParam from PointParam
    internal init(from param: PointParam) {
        super.init()
        self.timer = param.timer.map { RealmTimerParam(from: $0) }
        self.status = param.status.map { RealmStatusParam(from: $0) }
    }
    
    // Method to convert RealmPointParam back to PointParam
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
    
    // Custom initializer to create RealmTimerParam from TimerParam
    internal init(from timerParam: TimerParam) {
        super.init()
        self.base = timerParam.base
        self.done = timerParam.done
        self.maxTime = timerParam.maxTime
        self.minTime = timerParam.minTime
        self.distance = timerParam.distance
    }
    
    // Method to convert RealmTimerParam back to TimerParam
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
    
    // Custom initializer to create RealmStatusParam from StatusParam
    internal init(from statusParam: StatusParam) {
        super.init()
        self.color = statusParam.color
        self.isValid = statusParam.isValid
    }
    
    // Method to convert RealmStatusParam back to StatusParam
    func toStatusParam() -> StatusParam {
        return StatusParam(
            color: self.color,
            isValid: self.isValid
        )
    }
}
