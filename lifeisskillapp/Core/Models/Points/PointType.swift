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
    case gastro = 7
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
        case .gastro:
            return Color.colorLisPurple
        case .unknown:
            return Color.lighterGrey
        }
    }
    
    var icon: Image {
        SwiftUI.Image(iconName) // Use the iconName for the image
    }
    
    var iconName: String {
        switch self {
        case .sport:
            return CustomImages.Map.sport.fullPath
        case .environment:
            return CustomImages.Map.environment.fullPath
        case .culture:
            return CustomImages.Map.culture.fullPath
        case .tourist:
            return CustomImages.Map.tourist.fullPath
        case .energySponsor:
            return CustomImages.Map.energySponsor.fullPath
        case .virtual:
            return CustomImages.Map.virtual.fullPath
        case .gastro:
            return CustomImages.Map.gastro.fullPath
        case .unknown:
            return CustomImages.Map.unknown.fullPath
        }
    }
}
