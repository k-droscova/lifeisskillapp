//
//  LogContext.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 06.07.2024.
//

import Foundation

public enum LogContext: String, Codable {
    case network
    case api
    case ui
    case database
    case system
    case location
}
