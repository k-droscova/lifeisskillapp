//
//  LoggerProtocol.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 04.07.2024.
//

import Foundation

public protocol HasLoggerServicing {
    var logger: LoggerServicing { get }
}

public protocol LoggerServicing {
    func _log(message: String?, event: Loggable?)
}

public extension LoggerServicing {
    func log(message: String? = nil, event: Loggable? = nil) {
        _log(message: message, event: event)
    }
}

