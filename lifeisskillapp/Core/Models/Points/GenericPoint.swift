//
//  GenericPoint.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 15.07.2024.
//
import Foundation
import CoreLocation


struct GeneralPoint: Codable {
    let pointLat: Double
    let pointLng: Double
    let pointAlt: Double
    let pointName: String
    let pointValue: Int
    let pointType: PointType
    let pointID: String
    let cluster: String
    let pointSpec: Int
    let sponsorId: String
    let hasDetail: Bool
    let active: Bool
    let param: PointParam?

    enum CodingKeys: String, CodingKey {
        case pointLat
        case pointLng
        case pointAlt
        case pointName
        case pointValue
        case pointType
        case pointID
        case cluster
        case pointSpec
        case sponsorId
        case hasDetail
        case active
        case param
    }

    var location: CLLocation? {
        return CLLocation(coordinate: CLLocationCoordinate2D(latitude: pointLat, longitude: pointLng),
                          altitude: pointAlt,
                          horizontalAccuracy: -1,
                          verticalAccuracy: -1,
                          timestamp: API.baseDate)
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        pointLat = try container.decode(Double.self, forKey: .pointLat)
        pointLng = try container.decode(Double.self, forKey: .pointLng)
        pointAlt = try container.decode(Double.self, forKey: .pointAlt)
        pointName = try container.decode(String.self, forKey: .pointName)
        pointValue = try container.decode(Int.self, forKey: .pointValue)
        
        let pointTypeInt = try container.decode(Int.self, forKey: .pointType)
        let pointTypeMapped = PointType(rawValue: pointTypeInt & 0xF) ?? .unknown
        pointType = pointTypeMapped
        
        pointID = try container.decode(String.self, forKey: .pointID)
        cluster = try container.decode(String.self, forKey: .cluster)
        pointSpec = try container.decode(Int.self, forKey: .pointSpec)
        sponsorId = try container.decode(String.self, forKey: .sponsorId)
        hasDetail = try container.decode(Bool.self, forKey: .hasDetail)
        active = try container.decode(Bool.self, forKey: .active)
        param = try container.decodeIfPresent(PointParam.self, forKey: .param)
    }
}

struct PointParam: Codable {
    let timer: TimerParam?
    let status: StatusParam?

    enum CodingKeys: String, CodingKey {
        case timer = "TIMER"
        case status = "STATUS"
    }
}

struct TimerParam: Codable {
    let base: Int
    let done: Int
    let maxTime: Int
    let minTime: Int
    let distance: Int
}

struct StatusParam: Codable {
    let color: String
    let isValid: Bool

    enum CodingKeys: String, CodingKey {
        case color = "COLOR"
        case isValid = "IS_VALID"
    }
}
