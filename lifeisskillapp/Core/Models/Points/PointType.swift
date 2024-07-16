//
//  PointType.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 15.07.2024.
//

import Foundation
import UIKit
import SwiftUI

enum PointType: Int, Codable {
    case sport = 1
    case environment = 3
    case culture = 2
    case tourist = 4
    case energySponsor = 5
    case virtual = 6
    case unknown = 0 // Add an unknown case to handle unmapped values
       
    static func getPointType(from rawValue: Int) -> PointType? {
        guard let pointType = PointType(rawValue: rawValue) else {
            return nil
        }
        return pointType
    }
    
    /*var color: UIColor {
        switch self {
        case .sport:
            return UIColor.theme.pointSport
        case .environment:
            return UIColor.theme.pointEnvironment
        case .culture:
            return UIColor.theme.pointCulture
        }
    }

    var icon: Image {
        switch self {
        case .sport:
            return Asset.Map.sportMarker.swiftUIImage
        case .environment:
            return Asset.Map.environmentMarker.swiftUIImage
        case.culture:
            return Asset.Map.cultureMarker.swiftUIImage
        }
    }

    var listIcon: Image {
        switch self {
        case .sport:
            return Asset.PointList.sportIcon.swiftUIImage
        case .environment:
            return Asset.PointList.environmentIcon.swiftUIImage
        case.culture:
            return Asset.PointList.cultureIcon.swiftUIImage
        }
    }
     */
}
