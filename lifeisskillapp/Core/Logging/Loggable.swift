//
//  LogEvent.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 06.07.2024.
//

import Foundation

protocol Loggable: CustomStringConvertible, Codable {
    var id: String { get }
    var message: String { get }
    var dateString: String { get }
    
    var source: LogSource { get }
    var severity: LogSeverity { get }
    var context: LogContext { get }
}

class LogEvent: Loggable {
    
    var id: String
    var message: String
    var dateString: String
    var source: LogSource
    var severity: LogSeverity
    var context: LogContext
    var description: String {
        (try? JsonMapper.jsonString(from: self)) ?? "Mapping Failed"
    }
    
    init(
        fileID: String = #fileID,
        fun: String = #function,
        line: Int = #line,
        message: String = "Unknown",
        context: LogContext = .system,
        severity: LogSeverity = .info,
        logger: LoggerServicing
    ) {
        self.id = UUID().uuidString
        self.source = .init(fileID: fileID, fun: fun, line: line)
        self.context = context
        self.message = message
        self.dateString = Date().ISO8601Format()
        self.severity = severity
        logger.log(event: self)
    }
}
