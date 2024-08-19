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
    
    var color: Color {
        switch self {
        case .sport:
            return Color.colorLisRose
        case .environment:
            return Color.colorLisGreen
        case .culture:
            return Color.colorLisBlue
        case .tourist:
            return Color.colorLisOchre
        case .energySponsor:
            return Color.colorLisRed
        case .virtual:
            return Color.lightBlueA200
        case .unknown:
            return Color.lighterGrey
        }
    }
    
    var icon: Image {
        switch self {
        case .sport:
            return SwiftUI.Image("Icons/Map/sport")
        case .environment:
            return SwiftUI.Image("Icons/Map/nature")
        case .culture:
            return SwiftUI.Image("Icons/Map/culture")
        case .tourist:
            return SwiftUI.Image("Icons/Map/tourist")
        case .energySponsor:
            return SwiftUI.Image("Icons/Map/7en_green")
        case .virtual:
            return SwiftUI.Image("Icons/Map/virtual")
        case .unknown:
            return SwiftUI.Image("Icons/Map/unknown")
        }
    }
    
    var iconName: String {
        switch self {
        case .sport:
            "Icons/Map/sport"
        case .environment:
            "Icons/Map/nature"
        case .culture:
            "Icons/Map/culture"
        case .tourist:
            "Icons/Map/tourist"
        case .energySponsor:
            "Icons/Map/7en_green"
        case .virtual:
            "Icons/Map/virtual"
        case .unknown:
            "Icons/Map/unknown"
        }
    }
}
