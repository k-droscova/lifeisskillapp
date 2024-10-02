//
//  NetworkMonitorMock.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 02.10.2024.
//

@testable import lifeisskillapp
import Combine
import Foundation

final class NetworkMonitorMock: NetworkMonitoring {

    // MARK: - Mock Properties
    
    var mockOnlineStatus: Bool = false
    var delegate: NetworkManagerFlowDelegate?
    var mockErrorToThrow: Error? = nil
    var startMonitoringCalled: Bool = false
    var stopMonitoringCalled: Bool = false

    private let onlineStatusSubject = CurrentValueSubject<Bool, Never>(true)

    // MARK: - NetworkMonitoring Conformance
    var onlineStatus: Bool {
        mockOnlineStatus
    }

    var onlineStatusPublisher: AnyPublisher<Bool, Never> {
        onlineStatusSubject.eraseToAnyPublisher()
    }

    func startMonitoring() {
        startMonitoringCalled = true
    }

    func stopMonitoring() {
        stopMonitoringCalled = true
    }

    // MARK: - Methods to Simulate Network Changes
    
    func simulateNetworkChange(isOnline: Bool) {
        mockOnlineStatus = isOnline
        onlineStatusSubject.send(isOnline)
    }
}
