//
//  LogSeverity.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 06.07.2024.
//

import Foundation
import OSLog

public enum LogSeverity: String, Codable {
    case debug, info, warning, error, fatal
    
    // Method to convert LogSeverity to OSLogType
    var osLogType: OSLogType {
        switch self {
        case .debug:
            return .debug
        case .info:
            return .info
        case .warning:
            return .default // No direct mapping for warning, using default
        case .error:
            return .error
        case .fatal:
            return .fault
        }
    }
}
