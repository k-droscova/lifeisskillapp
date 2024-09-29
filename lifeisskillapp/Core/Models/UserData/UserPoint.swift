//
//  UserPoint.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 16.07.2024.
//
import Foundation
import CoreLocation

struct UserPoint: UserData {
    public let id: String
    let recordKey: String
    let pointTime: Date
    let pointName: String
    let pointValue: Int
    let pointType: PointType
    let pointSpec: Int
    let pointLat: Double
    let pointLng: Double
    let pointAlt: Double
    let accuracy: Double
    let codeSource: CodeSource
    let pointCategory: [String]
    let duration: TimeInterval?
    let doesPointCount: Bool
    
    enum CodingKeys: String, CodingKey {
        case recordKey
        case id = "pointId"
        case pointTime
        case pointName
        case pointValue
        case pointType
        case pointSpec
        case pointLat
        case pointLng
        case pointAlt
        case accuracy
        case codeSource
        case pointCategory
        case duration
        case doesPointCount
    }
    
    var location: UserLocation {
        UserLocation(
            latitude: pointLat,
            longitude: pointLng,
            altitude: pointAlt,
            accuracy: accuracy,
            timestamp: pointTime
        )
    }
    
    init(
        id: String,
        recordKey: String,
        pointTime: Date,
        pointName: String,
        pointValue: Int,
        pointType: PointType,
        pointSpec: Int,
        pointLat: Double,
        pointLng: Double,
        pointAlt: Double,
        accuracy: Double,
        codeSource: CodeSource,
        pointCategory: [String],
        duration: TimeInterval? = nil,
        doesPointCount: Bool
    ) {
        self.id = id
        self.recordKey = recordKey
        self.pointTime = pointTime
        self.pointName = pointName
        self.pointValue = pointValue
        self.pointType = pointType
        self.pointSpec = pointSpec
        self.pointLat = pointLat
        self.pointLng = pointLng
        self.pointAlt = pointAlt
        self.accuracy = accuracy
        self.codeSource = codeSource
        self.pointCategory = pointCategory
        self.duration = duration
        self.doesPointCount = doesPointCount
    }
}

extension UserPoint {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        recordKey = try container.decode(String.self, forKey: .recordKey)
        id = try container.decode(String.self, forKey: .id)
        let pointTimeString = try container.decode(String.self, forKey: .pointTime)
        pointTime = Date.Backend.fromUserPointString(dateString: pointTimeString)
        pointName = try container.decode(String.self, forKey: .pointName)
        pointValue = try container.decode(Int.self, forKey: .pointValue)
        
        let pointTypeInt = try container.decode(Int.self, forKey: .pointType)
        let doesPointCount = (pointTypeInt & (1 << 11)) == 0
        self.doesPointCount = doesPointCount
        let pointTypeMapped = PointType(rawValue: pointTypeInt & 0xF) ?? .unknown
        pointType = pointTypeMapped
        
        pointSpec = try container.decode(Int.self, forKey: .pointSpec)
        pointLat = try container.decode(Double.self, forKey: .pointLat)
        pointLng = try container.decode(Double.self, forKey: .pointLng)
        pointAlt = try container.decode(Double.self, forKey: .pointAlt)
        accuracy = try container.decode(Double.self, forKey: .accuracy)
        codeSource = try container.decode(CodeSource.self, forKey: .codeSource)
        let pointCategoryString = try container.decode(String.self, forKey: .pointCategory)
        pointCategory = pointCategoryString
            .components(separatedBy: "}{")
            .map { $0.trimmingCharacters(in: CharacterSet(charactersIn: "{}")) }
        if let durationString = try container.decodeIfPresent(String.self, forKey: .duration) {
            duration = TimeInterval.Backend.parseDuration(durationString)
        } else {
            duration = nil
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(recordKey, forKey: .recordKey)
        try container.encode(id, forKey: .id) // Correctly map id to pointId for encoding
        try container.encode(Date.Backend.getUserPointString(from: pointTime), forKey: .pointTime)
        try container.encode(pointName, forKey: .pointName)
        try container.encode(pointValue, forKey: .pointValue)
        try container.encode(pointType.rawValue | (doesPointCount ? 0 : (1 << 11)), forKey: .pointType)
        try container.encode(pointSpec, forKey: .pointSpec)
        try container.encode(pointLat, forKey: .pointLat)
        try container.encode(pointLng, forKey: .pointLng)
        try container.encode(pointAlt, forKey: .pointAlt)
        try container.encode(accuracy, forKey: .accuracy)
        try container.encode(codeSource, forKey: .codeSource)
        try container.encode(pointCategory.joined(separator: "}{"), forKey: .pointCategory)
        if let duration = duration {
            try container.encode(TimeInterval.Backend.getDurationString(from: duration), forKey: .duration)
        }
    }
}

struct Point: Identifiable {
    public let id: String
    let pointId: String
    let name: String
    let value: Int
    let type: PointType
    let time: Date
    let location: UserLocation
    let doesPointCount: Bool

    init(from userPoint: UserPoint) {
        /*
         Note that id is record key in this case, since one specific point can be scanned multiple times (across multiple days).
         Record key is the "id" of the scanned point instance, hence is unique for the user point.
         */
        self.id = userPoint.recordKey
        self.pointId = userPoint.id
        self.name = userPoint.pointName
        self.value = userPoint.pointValue
        self.type = userPoint.pointType
        self.time = userPoint.pointTime
        self.location = userPoint.location
        self.doesPointCount = userPoint.doesPointCount
    }
}

extension Point {
    // solely for previews
    private init(id: String, name: String, value: Int, type: PointType, doesPointCount: Bool) {
        self.id = UUID().uuidString // ensures unique id for all points, didnt want to initialize mocks with record keys
        self.pointId = id
        self.name = name
        self.value = value
        self.type = type
        self.time = Date()
        self.location = UserLocation(
            latitude: MapConstants.defaultCoordinate.coordinate.latitude,
            longitude: MapConstants.defaultCoordinate.coordinate.longitude,
            altitude: MapConstants.defaultCoordinate.altitude,
            accuracy: MapConstants.defaultCoordinate.horizontalAccuracy,
            timestamp: Calendar.current.date(byAdding: .hour, value: -48, to: self.time)!
        )
        self.doesPointCount = doesPointCount
    }
    static let MockPoint1 = Point(id: "1", name: "Turistický bod AB123", value: 10, type: PointType.tourist, doesPointCount: true)
    static let MockPoint2 = Point(id: "2", name: "Point 2", value: 20, type: PointType.culture, doesPointCount: false)
}
