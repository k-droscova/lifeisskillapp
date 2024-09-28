//
//  LogEvent.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 06.07.2024.
//

import Foundation

public protocol Loggable: CustomStringConvertible, Codable {
    var id: String { get }
    var message: String { get }
    var dateString: String { get }
    
    var source: LogSource { get }
    var severity: LogSeverity { get }
    var context: LogContext { get }
}

public class LogEvent: Loggable {
    
    public var id: String
    public var message: String
    public var dateString: String
    public var source: LogSource
    public var severity: LogSeverity
    public var context: LogContext
    public var description: String {
        (try? JsonMapper.jsonString(from: self)) ?? "Mapping Failed"
    }
    
    public init(
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
