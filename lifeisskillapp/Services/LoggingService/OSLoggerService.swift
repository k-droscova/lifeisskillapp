//
//  OsLogger.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 04.07.2024.
//

import Foundation
import os.log

public final class OSLoggerService: LoggerServicing {
    public func _log(message: String?, event: (any Loggable)?) {
        if let logEvent = event {
            let log = OSLog(subsystem: Bundle.main.bundleIdentifier ?? "-", category: logEvent.context.rawValue)
            os_log("%{public}@", log: log, type: logEvent.severity.osLogType, logEvent.message)
        } else if let message = message {
            let log = OSLog(subsystem: Bundle.main.bundleIdentifier ?? "-", category: "General")
            os_log("%{public}@", log: log, type: .info, message)
        }
    }
}
