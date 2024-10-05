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

    private struct Dependencies: NetworkMonitor.Dependencies {
        let logger: LoggerServicing
    }

    var logger: LoggerServicing!
    var nwMonitor: NWPathMonitoring!
    var monitor: NetworkMonitoring!

    override func setUpWithError() throws {
        try super.setUpWithError()
        logger = LoggingServiceMock()
        nwMonitor = NWPathMonitorMock()
        let dependencies = Dependencies(logger: logger)
        monitor = NetworkMonitor(
            dependencies: dependencies,
            monitor: nwMonitor
        )
    }

    override func tearDownWithError() throws {
        logger = nil
        monitor = nil
        nwMonitor = nil
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
