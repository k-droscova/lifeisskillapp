//
//  LoggingServiceMock.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 28.09.2024.
//

import Foundation
@testable import lifeisskillapp

final class LoggingServiceMock: LoggerServicing {
    func _log(message: String?, event: (any lifeisskillapp.Loggable)?) {
        if let logEvent = event {
            print("MOCK LOG:" + logEvent.message)
        } else if let message = message {
            print("MOCK LOG:" + message)
        }
    }
}
