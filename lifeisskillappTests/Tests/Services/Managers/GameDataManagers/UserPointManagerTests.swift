//
//  UserPointManagerTests.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 02.10.2024.
//

import XCTest
@testable import lifeisskillapp

final class UserPointManagerTests: XCTestCase {

    private struct Dependencies: UserPointManager.Dependencies {
        var logger: LoggerServicing
        var userDataAPI: UserDataAPIServicing
        var storage: PersistentUserDataStoraging
        var scanningManager: ScanningManaging
        var networkMonitor: NetworkMonitoring
    }
    
    var logger: LoggerServicing!
    var userDataAPIMock: UserDataAPIServiceMock!
    var persistentStorageMock: PersistentUserDataStorageMock!
    var scanningManagerMock: ScanningManagerMock!
    var networkMonitorMock: NetworkMonitorMock!
    var scanPointFlowDelegateMock: ScanPointFlowDelegateMock!
    var userPointManager: UserPointManager!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        logger = LoggingServiceMock()
        userDataAPIMock = UserDataAPIServiceMock()
        persistentStorageMock = PersistentUserDataStorageMock()
        scanningManagerMock = ScanningManagerMock()
        networkMonitorMock = NetworkMonitorMock()
        scanPointFlowDelegateMock = ScanPointFlowDelegateMock()
        
        let dependencies = Dependencies(
            logger: logger,
            userDataAPI: userDataAPIMock,
            storage: persistentStorageMock,
            scanningManager: scanningManagerMock,
            networkMonitor: networkMonitorMock
        )
        
        userPointManager = UserPointManager(dependencies: dependencies)
        userPointManager.scanningDelegate = scanPointFlowDelegateMock
    }
    
    override func tearDownWithError() throws {
        logger = nil
        userDataAPIMock = nil
        persistentStorageMock = nil
        scanningManagerMock = nil
        networkMonitorMock = nil
        scanPointFlowDelegateMock = nil
        userPointManager = nil
        try super.tearDownWithError()
    }
    
    // Existing Tests
    func testHandleScannedPointNoLocation() async throws {
        // Arrange
        let mockScannedPoint = ScannedPoint.mock(location: nil) // No location
        
        do {
            // Act
            try await userPointManager.handleScannedPoint(mockScannedPoint)
            
            // Assert
            XCTAssertTrue(scanPointFlowDelegateMock.onScanPointNoLocationCalled, "Expected delegate's onScanPointNoLocation to be called")
            XCTAssertFalse(scanningManagerMock.handleScannedPointOnlineCalled, "Expected no online point handling")
            XCTAssertFalse(scanningManagerMock.handleScannedPointOfflineCalled, "Expected no offline point handling")
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }
    
    func testHandleScannedPointInvalid() async throws {
        // Arrange
        let mockScannedPoint = ScannedPoint.mock()
        scanningManagerMock.isValid = false
        
        do {
            // Act
            try await userPointManager.handleScannedPoint(mockScannedPoint)
            
            // Assert
            XCTAssertTrue(scanPointFlowDelegateMock.onScanPointInvalidPointCalled, "Expected delegate's onScanPointInvalidPoint to be called")
            XCTAssertFalse(scanningManagerMock.handleScannedPointOnlineCalled, "Expected no online point handling")
            XCTAssertFalse(scanningManagerMock.handleScannedPointOfflineCalled, "Expected no offline point handling")
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }
    
    func testHandleScannedPointOnlineSuccess() async throws {
        // Arrange
        networkMonitorMock.mockOnlineStatus = true
        let mockScannedPoint = ScannedPoint.mock()
        
        do {
            // Act
            try await userPointManager.handleScannedPoint(mockScannedPoint)
            
            // Assert
            XCTAssertTrue(scanningManagerMock.handleScannedPointOnlineCalled, "Expected scanned point to be handled online")
            XCTAssertEqual(scanningManagerMock.scannedPointArgument?.code, mockScannedPoint.code)
            XCTAssertTrue(scanPointFlowDelegateMock.onScanPointProcessSuccessOnlineCalled, "Expected delegate's onScanPointProcessSuccessOnline to be called")
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }
    
    func testHandleScannedPointOfflineSuccess() async throws {
        // Arrange
        networkMonitorMock.mockOnlineStatus = false
        let mockScannedPoint = ScannedPoint.mock()
        
        do {
            // Act
            try await userPointManager.handleScannedPoint(mockScannedPoint)
            
            // Assert
            XCTAssertTrue(scanningManagerMock.handleScannedPointOfflineCalled, "Expected scanned point to be handled offline")
            XCTAssertEqual(scanningManagerMock.scannedPointArgument?.code, mockScannedPoint.code)
            XCTAssertTrue(scanPointFlowDelegateMock.onScanPointProcessSuccessOfflineCalled, "Expected delegate's onScanPointProcessSuccessOffline to be called")
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }
    
    // New Tests
    
    func testHandleScannedPointPropagatesInvalidTokenError() async throws {
        // Arrange
        networkMonitorMock.mockOnlineStatus = true
        let mockScannedPoint = ScannedPoint.mock()
        let mockInvalidTokenError = BaseError(
            context: .api,
            message: "Invalid Token",
            code: ErrorCodes.specificStatusCode(.invalidToken),
            logger: logger
        )
        scanningManagerMock.errorToThrow = mockInvalidTokenError
        
        do {
            // Act
            try await userPointManager.handleScannedPoint(mockScannedPoint)
            XCTFail("Expected error for invalid token to be propagated, but no error was thrown")
        } catch let error as BaseError {
            // Assert
            XCTAssertEqual(error.code, ErrorCodes.specificStatusCode(.invalidToken).code)
            XCTAssertTrue(scanningManagerMock.handleScannedPointOnlineCalled, "Expected scanned point to be handled online")
            XCTAssertFalse(scanPointFlowDelegateMock.onScanPointOnlineProcessErrorCalled, "Delegate should not be called for invalid token error")
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }
    
    func testHandleScannedPointHandlesApiErrorAndCallsDelegate() async throws {
        // Arrange
        networkMonitorMock.mockOnlineStatus = true // Simulate online mode
        let mockScannedPoint = ScannedPoint.mock()
        let mockApiError = BaseError(
            context: .api,
            message: "Some API Error",
            logger: logger
        )
        scanningManagerMock.errorToThrow = mockApiError
        
        // Act
        try await userPointManager.handleScannedPoint(mockScannedPoint)
        
        // Assert
        XCTAssertTrue(scanningManagerMock.handleScannedPointOnlineCalled, "Expected scanned point to be handled online")
        XCTAssertTrue(scanPointFlowDelegateMock.onScanPointOnlineProcessErrorCalled, "Expected delegate's onScanPointOnlineProcessError to be called")
    }
    
    func testHandleScannedPointOfflineFailureCallsDelegate() async throws {
        // Arrange
        networkMonitorMock.mockOnlineStatus = false
        let mockScannedPoint = ScannedPoint.mock()
        let mockError = BaseError(context: .system, message: "Failed to store point", logger: logger)
        scanningManagerMock.errorToThrow = mockError
        
        // Act
        try await userPointManager.handleScannedPoint(mockScannedPoint)
        
        // Assert
        XCTAssertTrue(scanningManagerMock.handleScannedPointOfflineCalled, "Expected scanned point to be handled offline")
        XCTAssertTrue(scanPointFlowDelegateMock.onScanPointOfflineProcessErrorCalled, "Expected delegate's onScanPointOfflineProcessError to be called")
    }
}
