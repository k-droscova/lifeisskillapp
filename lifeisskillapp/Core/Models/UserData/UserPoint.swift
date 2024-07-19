//
//  UserPoint.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 16.07.2024.
//
import Foundation
import CoreLocation

struct UserPoint: UserData {
    let id: String
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
    
    var location: CLLocation {
        CLLocation(coordinate: CLLocationCoordinate2D(latitude: pointLat, longitude: pointLng),
                   altitude: pointAlt,
                   horizontalAccuracy: accuracy,
                   verticalAccuracy: accuracy,
                   timestamp: pointTime)
    }
}

extension UserPoint {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        recordKey = try container.decode(String.self, forKey: .recordKey)
        id = try container.decode(String.self, forKey: .id)
        let pointTimeString = try container.decode(String.self, forKey: .pointTime)
        pointTime = Date().fromPointList(dateString: pointTimeString)
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
            duration = TimeInterval.parseDuration(durationString)
        } else {
            duration = nil
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(recordKey, forKey: .recordKey)
        try container.encode(id, forKey: .id) // Correctly map id to pointId for encoding
        try container.encode(pointTime.toPointListString(), forKey: .pointTime)
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
            try container.encode(duration.getDurationString(), forKey: .duration)
        }
    }
}

