//
//  NetworkMonitorTests.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 28.09.2024.
//

import XCTest
import Combine
@testable import lifeisskillapp
import Network

final class NetworkMonitorTests: XCTestCase {
    
    // Mock delegate to capture delegate calls
    class NetworkDelegateMock: NetworkManagerFlowDelegate {
        var didCallOnNoInternetConnection = false

        func onNoInternetConnection() {
            didCallOnNoInternetConnection = true
        }
    }

    private struct Dependencies: NetworkMonitor.Dependencies {
        let logger: LoggerServicing
    }

    var delegate: NetworkManagerFlowDelegate!
    var logger: LoggerServicing!
    var nwMonitor: NWPathMonitoring!
    var monitor: NetworkMonitoring!

    override func setUpWithError() throws {
        try super.setUpWithError()
        logger = LoggingServiceMock()
        nwMonitor = NWPathMonitorMock()
        delegate = NetworkDelegateMock()
        let dependencies = Dependencies(logger: logger)
        monitor = NetworkMonitor(
            dependencies: dependencies,
            monitor: nwMonitor
        )
        monitor.delegate = delegate
    }

    override func tearDownWithError() throws {
        monitor = nil
        delegate = nil
        try super.tearDownWithError()
    }

    func testMonitorStartsListeningOnInit() {
        XCTAssertTrue((nwMonitor as! NWPathMonitorMock).didStartMonitoring, "NWMonitor should start listening upon initialization")
    }
    
    func testMonitorStopsListeningOnDeinit() {
        // Deallocate the monitor to simulate deinitialization
        monitor = nil
        
        XCTAssertTrue((nwMonitor as! NWPathMonitorMock).didStopMonitoring, "NWMonitor should stop listening upon deinitialization")
    }
    
    func testPathUpdateHandlerIsNotNil() {
        XCTAssertNotNil((nwMonitor as! NWPathMonitorMock).pathUpdateHandler, "pathUpdateHandler should be set and not nil upon initialization")
    }
}
