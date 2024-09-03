//
//  UserGender.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 15.07.2024.
//

import Foundation

enum UserGender: String, Codable {
    case male
    case female
    case unspecified // unfinished registration

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .male:
            try container.encode("M")
        case .female:
            try container.encode("F")
        case .unspecified:
            try container.encode("")
        }
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let gender = try container.decode(String.self)
        switch gender {
        case "M":
            self = .male
        case "F":
            self = .female
        default:
            self = .unspecified
        }
    }
    
    var icon: String {
        switch self {
        case .male, .unspecified:
            CustomImages.Avatar.male.fullPath
        case .female:
            CustomImages.Avatar.female.fullPath
        }
    }
}
