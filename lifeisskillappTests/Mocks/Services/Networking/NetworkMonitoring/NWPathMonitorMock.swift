//
//  NWPathMonitorMock.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 28.09.2024.
//

import Foundation
import Network
@testable import lifeisskillapp

class NWPathMonitorMock: NWPathMonitoring {
    var didStartMonitoring: Bool = false
    var didStopMonitoring: Bool = false
    
    func listen(queue: DispatchQueue) {
        didStartMonitoring = true
    }
    
    func stop() {
        didStopMonitoring = true
    }
    
    var pathUpdateHandler: (@Sendable (NWPath) -> Void)?
}
