//
//  NWPathMonitor.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 28.09.2024.
//

import Foundation
import Network

protocol NWPathMonitoring {
    var didStartMonitoring: Bool { get }
    var didStopMonitoring: Bool { get }
    
    func listen(queue: DispatchQueue)
    func stop()
    var pathUpdateHandler: (@Sendable (_ newPath: NWPath) -> Void)? { get set }
}

extension NWPathMonitor: NWPathMonitoring {
    var didStartMonitoring: Bool { false }
    var didStopMonitoring: Bool { false }
    
    func listen(queue: DispatchQueue) {
        start(queue: queue)
    }
    
    func stop() {
        cancel()
    }
}
