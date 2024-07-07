//
//  LogEvent.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 06.07.2024.
//

import Foundation

public protocol Loggable: CustomStringConvertible, Codable {
    var message: String { get }
    /// Custom identifier that is presented to the user and added as custom tag to Firebase
    var identifier: String { get }
    /// Time of occurrence
    var dateString: String { get }
    
    var source: LogSource { get }
    var severity: LogSeverity { get }
    var context: LogContext { get }
}

