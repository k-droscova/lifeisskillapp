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
        var userDefaultsStorage: UserDefaultsStoraging
        var logger: LoggerServicing
        var userDataAPI: UserDataAPIServicing
        var storage: PersistentUserDataStoraging
        var scanningManager: ScanningManaging
        var networkMonitor: NetworkMonitoring
    }
    
    var logger: LoggerServicing!
    var userDefaultStorageMock: UserDefaultsStorageMock!
    var userDataAPIMock: UserDataAPIServiceMock!
    var persistentStorageMock: PersistentUserDataStorageMock!
    var scanningManagerMock: ScanningManagerMock!
    var networkMonitorMock: NetworkMonitorMock!
    var scanPointFlowDelegateMock: ScanPointFlowDelegateMock!
    var userPointManager: UserPointManager!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        logger = LoggingServiceMock()
        userDefaultStorageMock = UserDefaultsStorageMock()
        userDataAPIMock = UserDataAPIServiceMock()
        persistentStorageMock = PersistentUserDataStorageMock()
        scanningManagerMock = ScanningManagerMock()
        networkMonitorMock = NetworkMonitorMock()
        scanPointFlowDelegateMock = ScanPointFlowDelegateMock()
        
        let dependencies = Dependencies(
            userDefaultsStorage: userDefaultStorageMock,
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
    
    func testFetchWithToken_SuccessfulFetch() async throws {
        // Arrange
        userDefaultStorageMock.mockToken = "mockToken"
        
        do {
            // Act
            try await userPointManager.fetch()

            // Assert
            XCTAssertTrue(userDataAPIMock.userPointsCalled, "userPoints API should be called")
            XCTAssertEqual(userDataAPIMock.userTokenArgument, userDefaultStorageMock.token, "Correct token should be passed to userPoints API")
        } catch {
            XCTFail("Expected fetch to succeed, but it threw an error: \(error)")
        }
    }

    func testFetchWithToken_TokenIsMissing_ThrowsError() async throws {
        // Arrange
        userDefaultStorageMock.token = nil // No token

        // Act & Assert
        do {
            try await userPointManager.fetch()
            XCTFail("fetch() should throw an error when token is missing")
        } catch let error as BaseError {
            XCTAssertEqual(error.code, ErrorCodes.general(.missingToken).code, "Expected missing token error")
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }

    func testFetchWithToken_ApiFailure_ThrowsError() async throws {
        // Arrange
        let mockToken = "mockToken"
        userDefaultStorageMock.token = mockToken
        let mockApiError = BaseError(context: .api, message: "API Failure", logger: logger)
        userDataAPIMock.errorToThrow = mockApiError

        // Act & Assert
        do {
            try await userPointManager.fetch(withToken: mockToken)
            XCTFail("fetch() should throw an API error")
        } catch let error as BaseError {
            XCTAssertEqual(error.code, mockApiError.code, "Expected API error")
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }
    
    func testGetById_ReturnsCorrectPoint() async {
        // Arrange
        let mockPoint = UserPoint.mock(id: "testPoint")
        persistentStorageMock.mockUserPointData = UserPointData.mock(data: [mockPoint])
        await userPointManager.loadFromRepository()
        // Act
        let retrievedPoint = userPointManager.getById(id: "testPoint")
        
        // Assert
        XCTAssertEqual(retrievedPoint?.id, mockPoint.id, "getById should return the correct point by ID")
        XCTAssertEqual(retrievedPoint?.pointValue, mockPoint.pointValue, "getById should return the correct pointValue")
    }
    
    func testGetById_ReturnsNothingWhenIdInvalid() async {
        // Arrange
        let mockPoint = UserPoint.mock(id: "testPoint")
        persistentStorageMock.mockUserPointData = UserPointData.mock(data: [mockPoint])
        await userPointManager.loadFromRepository()
        
        // Act
        let retrievedPoint = userPointManager.getById(id: "testPointInvalid")
        
        // Assert
        XCTAssertNil(retrievedPoint, "getById should return nil when point not present")
    }
    
    func testGetAll_ReturnsAllPoints() async {
        // Arrange
        let mockPoints = [UserPoint.mock(id: "point1"), UserPoint.mock(id: "point2")]
        persistentStorageMock.mockUserPointData = UserPointData.mock(data: mockPoints)
        await userPointManager.loadFromRepository()

        // Act
        let points = userPointManager.getAll()

        // Assert
        XCTAssertEqual(points.count, mockPoints.count, "getAll should return all points stored")
    }
    
    func testGetPointsByCategory_ReturnsCorrectPoints() async {
        // Arrange
        let mockPoints = [
            UserPoint.mock(id: "point1", pointCategory: ["category1"]),
            UserPoint.mock(id: "point2", pointCategory: ["category2"]),
            UserPoint.mock(id: "point3", pointCategory: ["category1", "category2"])
        ]
        persistentStorageMock.mockUserPointData = UserPointData.mock(data: mockPoints)
        await userPointManager.loadFromRepository()

        // Act
        let points = userPointManager.getPoints(byCategory: "category1")

        // Assert
        XCTAssertEqual(points.count, 2, "getPoints should return points that match the category")
        XCTAssertEqual(points[0].id, "point1", "First point ID should match")
        XCTAssertEqual(points[1].id, "point3", "Second point ID should match")
    }
    
    func testGetTotalPointsByCategory_ReturnsCorrectTotal() async {
        // Arrange
        let mockPoints = [
            UserPoint.mock(id: "point1", pointValue: 10, pointCategory: ["category1"]),
            UserPoint.mock(id: "point2", pointValue: 20, pointCategory: ["category2"]),
            UserPoint.mock(id: "point3", pointValue: 15, pointCategory: ["category1"])
        ]
        persistentStorageMock.mockUserPointData = UserPointData.mock(data: mockPoints)
        await userPointManager.loadFromRepository()

        // Act
        let totalPoints = userPointManager.getTotalPoints(byCategory: "category1")

        // Assert
        XCTAssertEqual(totalPoints, 25, "getTotalPoints should return the correct sum for the given category")
    }
    
    func testHandleScannedPointWhileOnline_ValidPoint() async throws {
        // Arrange
        networkMonitorMock.mockOnlineStatus = true

        // Act
        try await userPointManager.handleScannedPoint(.mock(location: .mock()))

        // Assert
        XCTAssertTrue(scanningManagerMock.handleScannedPointOnlineCalled, "Online handling should be called on manager")
    }
    
    func testHandleStoredScannedPoints_CallsScanningManager() async throws {
        // Arrange
        networkMonitorMock.mockOnlineStatus = false

        // Act
        try await userPointManager.handleScannedPoint(.mock(location: .mock()))

        // Assert
        XCTAssertTrue(scanningManagerMock.handleScannedPointOfflineCalled, "Offline handling should be called on manager")
    }
    
    func testHandleStoredScannedPoints_CallsDelegate_NoLocation() async throws {
        // Act
        try await userPointManager.handleScannedPoint(.mock(location: nil))

        // Assert
        XCTAssertTrue(scanPointFlowDelegateMock.onScanPointNoLocationCalled, "No location delegate method expected to be called")
    }
    
    func testHandleAllStoredScannedPoints_CallsScanningManager() async throws {
        // Act
        try await userPointManager.handleAllStoredScannedPoints()

        // Assert
        XCTAssertTrue(scanningManagerMock.sendAllStoredScannedPointsCalled, "All stored scanned points should be handled")
    }
    
    func testOnLogout_ClearsUserPointData() async {
        // Arrange
        persistentStorageMock.mockUserPointData = UserPointData.mock()
        await userPointManager.loadFromRepository()

        // Act
        userPointManager.onLogout()

        // Assert
        XCTAssertEqual(userPointManager.getAll().count, 0, "User point data should be cleared on logout")
        XCTAssertNil(userPointManager.checkSum(), "CheckSum should be cleared on logout")
    }
    
    func testCheckSum_ReturnsCorrectCheckSum() async {
        // Arrange
        let expectedChecksum = "mockCheckSum"
        persistentStorageMock.mockUserPointData = UserPointData.mock(checkSum: expectedChecksum)
        await userPointManager.loadFromRepository()

        // Act
        let checkSum = userPointManager.checkSum()

        // Assert
        XCTAssertEqual(checkSum, expectedChecksum, "checkSum should return the correct checksum from storage")
    }
}
