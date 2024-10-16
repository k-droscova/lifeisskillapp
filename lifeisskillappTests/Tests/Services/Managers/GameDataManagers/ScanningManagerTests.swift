//
//  ScanningManagerTests.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 02.10.2024.
//

import XCTest
@testable import lifeisskillapp

final class ScanningManagerTests: XCTestCase {
    
    private struct Dependencies: ScanningManager.Dependencies {
        var userDefaultsStorage: UserDefaultsStoraging
        var logger: LoggerServicing
        var userDataAPI: UserDataAPIServicing
        var storage: PersistentUserDataStoraging
        var container: HasRealmRepositories
        var networkMonitor: NetworkMonitoring
    }
    
    var userDefaultStorageMock: UserDefaultsStorageMock!
    var logger: LoggerServicing!
    var userDataAPIMock: UserDataAPIServiceMock!
    var persistentStorageMock: PersistentUserDataStorageMock!
    var scannedPointRepoMock: RealmScannedPointRepositoryMock!
    var networkMonitorMock: NetworkMonitorMock!
    var scanningManager: ScanningManager!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        userDefaultStorageMock = UserDefaultsStorageMock()
        logger = LoggingServiceMock()
        userDataAPIMock = UserDataAPIServiceMock()
        persistentStorageMock = PersistentUserDataStorageMock()
        scannedPointRepoMock = RealmScannedPointRepositoryMock()
        networkMonitorMock = NetworkMonitorMock()
        
        let containerMock = RepositoryContainerMock()
        containerMock.realmScannedPointRepository = scannedPointRepoMock
        
        let dependencies = Dependencies(
            userDefaultsStorage: userDefaultStorageMock,
            logger: logger,
            userDataAPI: userDataAPIMock,
            storage: persistentStorageMock,
            container: containerMock,
            networkMonitor: networkMonitorMock
        )
        
        scanningManager = ScanningManager(dependencies: dependencies)
    }
    
    override func tearDownWithError() throws {
        logger = nil
        userDataAPIMock = nil
        persistentStorageMock = nil
        scannedPointRepoMock = nil
        networkMonitorMock = nil
        scanningManager = nil
        try super.tearDownWithError()
    }
    
    func testHandleScannedPointOnlineThrowsErrorWhenTokenIsNil() async throws {
        // Arrange
        userDefaultStorageMock.mockToken = nil
        let mockScannedPoint = ScannedPoint.mock()
        
        // Act & Assert
        do {
            try await scanningManager.handleScannedPointOnline(mockScannedPoint)
            XCTFail("Expected an error to be thrown, but no error was thrown")
        } catch let error as BaseError {
            XCTAssertEqual(error.message, "Cannot send data to API, no access to userToken")
            XCTAssertEqual(error.context, .system)
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }
    
    func testHandleScannedPointOnlineSuccess() async throws {
        // Arrange
        userDefaultStorageMock.mockToken = "mockToken"
        let mockScannedPoint = ScannedPoint.mock(code: "testCode", location: UserLocation.mock())
        
        // Act
        try await scanningManager.handleScannedPointOnline(mockScannedPoint)
        
        // Assert
        XCTAssertEqual(userDataAPIMock.userTokenArgument, "mockToken")
        XCTAssertEqual(userDataAPIMock.scannedPointArgument?.code, mockScannedPoint.code)
        XCTAssertTrue(userDataAPIMock.updateUserPointsCalled, "Expected updateUserPoints to be called")
    }
    
    func testHandleScannedPointOnlineThrowsWhenUserDataAPIFails() async throws {
        // Arrange
        userDefaultStorageMock.mockToken = "mockToken"
        let mockScannedPoint = ScannedPoint.mock(code: "testCode", location: UserLocation.mock())
        let mockError = BaseError(context: .api, message: "API failure", logger: logger)
        userDataAPIMock.errorToThrow = mockError
        
        // Act & Assert
        do {
            try await scanningManager.handleScannedPointOnline(mockScannedPoint)
            XCTFail("Expected an error to be thrown, but no error was thrown")
        } catch let error as BaseError {
            XCTAssertEqual(error.message, "API failure")
            XCTAssertEqual(error.context, .api)
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
        XCTAssertTrue(userDataAPIMock.updateUserPointsCalled, "Expected updateUserPoints to be called")
    }
    
    func testHandleScannedPointOfflineSuccess() async throws {
        // Arrange
        let mockScannedPoint = ScannedPoint.mock(code: "offlineTestCode", location: UserLocation.mock())
        
        // Act
        do {
            try await scanningManager.handleScannedPointOffline(mockScannedPoint)
            
            // Assert
            XCTAssertFalse(userDataAPIMock.updateUserPointsCalled, "API should not be called in offline mode")
            XCTAssertEqual(persistentStorageMock.mockScannedPoints.count, 1, "Expected 1 scanned point in storage")
            XCTAssertEqual(persistentStorageMock.mockScannedPoints.first?.code, mockScannedPoint.code, "Expected the scanned point code to be saved correctly")
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }
    
    func testHandleMultipleScannedPointsOffline() async throws {
        // Arrange
        let mockScannedPoint1 = ScannedPoint.mock(code: "offlineTestCode1", location: UserLocation.mock())
        let mockScannedPoint2 = ScannedPoint.mock(code: "offlineTestCode2", location: UserLocation.mock())
        
        // Act
        do {
            try await scanningManager.handleScannedPointOffline(mockScannedPoint1)
            try await scanningManager.handleScannedPointOffline(mockScannedPoint2)
            
            // Assert
            XCTAssertFalse(userDataAPIMock.updateUserPointsCalled, "API should not be called in offline mode")
            XCTAssertEqual(persistentStorageMock.mockScannedPoints.count, 2, "Expected 2 scanned points in storage")
            XCTAssertEqual(persistentStorageMock.mockScannedPoints[0].code, mockScannedPoint1.code, "Expected the first scanned point code to be saved correctly")
            XCTAssertEqual(persistentStorageMock.mockScannedPoints[1].code, mockScannedPoint2.code, "Expected the second scanned point code to be saved correctly")
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }
    
    func testHandleScannedPointOfflineThrowsWhenSavingFails() async throws {
        // Arrange
        let mockScannedPoint = ScannedPoint.mock(code: "offlineTestCode", location: UserLocation.mock())
        let mockError = BaseError(context: .database, message: "Failed to save scanned point", logger: logger)
        
        persistentStorageMock.errorToThrow = mockError

        // Act & Assert
        do {
            try await scanningManager.handleScannedPointOffline(mockScannedPoint)
            XCTFail("Expected an error to be thrown, but no error was thrown")
        } catch let error as BaseError {
            XCTAssertEqual(error.message, "Failed to save scanned point", "Expected error message to match")
            XCTAssertEqual(error.context, .database, "Expected error context to be .storage")
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }
    
    func testSendAllStoredScannedPointsSuccess() async throws {
        // Arrange
        let mockScannedPoints = [
            ScannedPoint.mock(code: "testCode1", location: UserLocation.mock()),
            ScannedPoint.mock(code: "testCode2", location: UserLocation.mock())
        ]
        userDefaultStorageMock.mockToken = "mockToken"
        persistentStorageMock.mockScannedPoints = mockScannedPoints
        
        do {
            // Act
            try await scanningManager.sendAllStoredScannedPoints()
            
            // Assert
            XCTAssertTrue(scannedPointRepoMock.mockScannedPoints.isEmpty, "Expected deleteAll to be called to clear stored scanned points.")
            XCTAssertEqual(userDataAPIMock.scannedPointArgument?.code, "testCode2", "Expected the last point (testCode2) to be passed to updateUserPoints.")
            XCTAssertTrue(userDataAPIMock.updateUserPointsCalled, "API should not be called in offline mode")
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }
    
    func testSendAllStoredScannedPointsFailure() async throws {
        // Arrange
        let mockScannedPoints = [
            ScannedPoint.mock(code: "testCode1", location: UserLocation.mock()),
            ScannedPoint.mock(code: "testCode2", location: UserLocation.mock())
        ]
        userDefaultStorageMock.mockToken = "mockToken"
        persistentStorageMock.mockScannedPoints = mockScannedPoints

        // Simulate API failure for one of the scanned points
        let mockError = BaseError(context: .api, message: "API failure", logger: logger)
        userDataAPIMock.errorToThrow = mockError
        
        // Act & Assert
        do {
            try await scanningManager.sendAllStoredScannedPoints()
            XCTFail("Expected an error to be thrown, but no error was thrown")
        } catch let error as BaseError {
            // Assert: Ensure the error is the one we simulated
            XCTAssertEqual(error.message, "API failure")
            XCTAssertEqual(error.context, .api)
            
            // Assert: Verify that deleteAll was not called since we don't proceed after a failure
            XCTAssertFalse(scannedPointRepoMock.mockScannedPoints.isNotEmpty, "The storage should not be empty.")
            
            // Assert: Check that updateUserPoints was called for the first point, and it failed
            XCTAssertEqual(userDataAPIMock.scannedPointArgument?.code, "testCode1", "Expected the first point to be passed to updateUserPoints before the failure.")
            XCTAssertTrue(userDataAPIMock.updateUserPointsCalled, "Expected updateUserPoints to be called before the failure.")
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }
    
    func testCheckValidityReturnsFalseWhenLocationIsNil() throws {
        // Arrange
        let invalidScannedPoint = ScannedPoint.mock(location: nil) // Scanned point with no location
        
        // Act
        let isValid = scanningManager.checkValidity(invalidScannedPoint)
        
        // Assert
        XCTAssertFalse(isValid, "Expected validity check to return false when location is nil.")
    }

    func testCheckValidityReturnsTrueWhenLocationIsNotNil() throws {
        // Arrange
        let validScannedPoint = ScannedPoint.mock(location: UserLocation.mock()) // Scanned point with valid location
        
        // Act
        let isValid = scanningManager.checkValidity(validScannedPoint)
        
        // Assert
        XCTAssertTrue(isValid, "Expected validity check to return true when location is set.")
    }
}
