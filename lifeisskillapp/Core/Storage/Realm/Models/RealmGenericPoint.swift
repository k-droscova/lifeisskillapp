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
        checkSum = genericPointData.checkSum
        let points = genericPointData.data.map { RealmGenericPoint(from: $0) }
        data.append(objectsIn: points)
    }
    
    func genericPointData() -> GenericPointData {
        let points = data.map { $0.genericPoint() }
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
        "pointID"
    }
    
    override required init() {
        super.init()
    }
    
    convenience init(from genericPoint: GenericPoint) {
        self.init()
        pointID = genericPoint.id
        pointLat = genericPoint.pointLat
        pointLng = genericPoint.pointLng
        pointAlt = genericPoint.pointAlt
        pointName = genericPoint.pointName
        pointValue = genericPoint.pointValue
        pointType = genericPoint.pointType.rawValue
        cluster = genericPoint.cluster
        pointSpec = genericPoint.pointSpec
        sponsorID = genericPoint.sponsorId
        hasDetail = genericPoint.hasDetail
        active = genericPoint.active
        if let param = genericPoint.param {
            let realmParam = RealmPointParam(from: param)
            if realmParam.timer != nil || realmParam.status != nil {
                self.param = realmParam
            } else {
                self.param = nil
            }
        }
    }
    
    func genericPoint() -> GenericPoint {
        GenericPoint(from: self)
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
        timer = param.timer.map(RealmTimerParam.init(from:))
        status = param.status.map(RealmStatusParam.init(from:))
    }
    
    func pointParam() -> PointParam {
        PointParam(
            timer: timer?.timerParam(),
            status: status?.statusParam()
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
        base = timerParam.base
        done = timerParam.done
        maxTime = timerParam.maxTime
        minTime = timerParam.minTime
        distance = timerParam.distance
    }
    
    func timerParam() -> TimerParam {
        TimerParam(
            base: base,
            done: done,
            maxTime: maxTime,
            minTime: minTime,
            distance: distance
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
        color = statusParam.color
        isValid = statusParam.isValid
    }
    
    func statusParam() -> StatusParam {
        StatusParam(
            color: color,
            isValid: isValid
        )
    }
}
