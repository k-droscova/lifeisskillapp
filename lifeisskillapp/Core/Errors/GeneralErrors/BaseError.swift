//
//  BaseError.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 04.07.2024.
//

import Foundation

protocol BaseErroring: Error, CustomStringConvertible, CustomNSError, Codable, Identifiable {
    var id: String { get }
    var description: String { get }
    var message: String { get }
    var code: Int { get }
    var url: URL? { get }
    var dateString: String { get }
}

extension BaseErroring {
    var errorCode: Int {
        code
    }
    /// Error object serialized to JSON (string)
    var description: String {
        (try? JsonMapper.jsonString(from: self)) ?? "Mapping Failed"
    }
}

class BaseError: BaseErroring, Loggable {    
    
    // MARK: - Loggable Properties
    
    let source: LogSource
    var severity: LogSeverity = .error
    let context: LogContext
    
    // MARK: - Module Error Properties
    
    let id: String
    let code: Int
    let url: URL?
    let message: String
    let dateString: String

    // MARK: - Initialization
    
    init(
        fileID: String = #fileID,
        fun: String = #function,
        line: Int = #line,
        context: LogContext,
        message: String = "Unknown",
        code: ErrorCodes? = nil,
        url: URL? = nil,
        logger: LoggerServicing
    ) {
        self.source = .init(
            fileID: fileID,
            fun: fun,
            line: line
        )
        self.id = UUID().uuidString
        self.dateString = Date().ISO8601Format()
        self.context = context
        self.code = (code ?? .default).code
        self.url = url
        self.message = message
        logger.log(event: self)
    }
}
