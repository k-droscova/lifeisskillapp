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
                .debug
        case .info:
                .info
        case .warning:
                .default // No direct mapping for warning, using default
        case .error:
                .error
        case .fatal:
                .fault
        }
    }
}
