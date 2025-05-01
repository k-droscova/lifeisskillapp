//
//  GameDataManagerTests.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 18.10.2024.
//

import XCTest
import Combine
@testable import lifeisskillapp

final class GameDataManagerTests: XCTestCase {
    
    // MARK: - Mocks and Dependencies
    
    private struct Dependencies: GameDataManager.Dependencies {
        var userPointManager: any UserPointManaging
        var genericPointManager: any GenericPointManaging
        var userRankManager: any UserRankManaging
        var userCategoryManager: any UserCategoryManaging
        var checkSumAPI: CheckSumAPIServicing
        var logger: LoggerServicing
        var storage: PersistentUserDataStoraging
        var networkMonitor: NetworkMonitoring
        var userDefaultsStorage: UserDefaultsStoraging
    }
    
    var userPointManagerMock: UserPointManagerMock!
    var genericPointManagerMock: GenericPointManagerMock!
    var userRankManagerMock: UserRankManagerMock!
    var userCategoryManagerMock: UserCategoryManagerMock!
    var checkSumAPIMock: CheckSumAPIServiceMock!
    var loggerMock: LoggerServicing!
    var persistentStorageMock: PersistentUserDataStorageMock!
    var networkMonitorMock: NetworkMonitorMock!
    var userDefaultsStorageMock: UserDefaultsStorageMock!
    var gameDataManager: GameDataManager!
    var delegateMock: GameDataManagerFlowDelegateMock!
    var cancellables: Set<AnyCancellable>!
    
    // MARK: - Setup and Teardown
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        loggerMock = LoggingServiceMock()
        userPointManagerMock = UserPointManagerMock()
        genericPointManagerMock = GenericPointManagerMock()
        userRankManagerMock = UserRankManagerMock()
        userCategoryManagerMock = UserCategoryManagerMock()
        checkSumAPIMock = CheckSumAPIServiceMock()
        persistentStorageMock = PersistentUserDataStorageMock()
        networkMonitorMock = NetworkMonitorMock()
        userDefaultsStorageMock = UserDefaultsStorageMock()
        delegateMock = GameDataManagerFlowDelegateMock()
        
        let dependencies = Dependencies(
            userPointManager: userPointManagerMock,
            genericPointManager: genericPointManagerMock,
            userRankManager: userRankManagerMock,
            userCategoryManager: userCategoryManagerMock,
            checkSumAPI: checkSumAPIMock,
            logger: loggerMock,
            storage: persistentStorageMock,
            networkMonitor: networkMonitorMock,
            userDefaultsStorage: userDefaultsStorageMock
        )
        
        gameDataManager = GameDataManager(dependencies: dependencies)
        gameDataManager.delegate = delegateMock
        cancellables = []
    }
    
    override func tearDownWithError() throws {
        loggerMock = nil
        userPointManagerMock = nil
        genericPointManagerMock = nil
        userRankManagerMock = nil
        userCategoryManagerMock = nil
        checkSumAPIMock = nil
        persistentStorageMock = nil
        networkMonitorMock = nil
        userDefaultsStorageMock = nil
        gameDataManager = nil
        delegateMock = nil
        cancellables = nil
        
        try super.tearDownWithError()
    }
    
    // MARK: - Test Cases
    
    func testPerformOnlineLogin_Success() async throws {
        // Arrange
        userDefaultsStorageMock.mockToken = "mockToken"
        
        // Act
        try await gameDataManager.performOnlineLogin()
        
        // Assert
        XCTAssertTrue(userPointManagerMock.fetchWithTokenCalled, "User points should be fetched")
        XCTAssertTrue(userRankManagerMock.fetchWithTokenCalled, "User ranks should be fetched")
        XCTAssertTrue(genericPointManagerMock.fetchWithTokenCalled, "Generic points should be fetched")
        XCTAssertTrue(userCategoryManagerMock.fetchWithTokenCalled, "User categories should be fetched")
        XCTAssertFalse(delegateMock.onErrorCalled, "Delegate's onError should not be called for a successful login")
    }
    
    func testPerformOnlineLogin_InvalidToken() async throws {
        // Arrange
        let invalidTokenError = BaseError(
            context: .api,
            message: "Invalid Token",
            code: ErrorCodes.specificStatusCode(.invalidToken),
            logger: loggerMock
        )
        // Simulate invalid token error in one of the managers (e.g., userPointManager)
        userPointManagerMock.errorToThrow = invalidTokenError
        userDefaultsStorageMock.mockToken = "mockToken"
        
        // Act
        try await gameDataManager.performOnlineLogin()
        
        // Assert
        XCTAssertTrue(delegateMock.onInvalidTokenCalled, "Delegate's onInvalidToken should be called when token is invalid")
        XCTAssertFalse(delegateMock.onErrorCalled, "Delegate's onError should not be called for invalid token error")
    }
    
    func testPerformOnlineLogin_OnError_AnyOtherError() async throws {
        // Arrange
        let randomError = BaseError(
            context: .api,
            message: "Random Error",
            code: ErrorCodes.default,
            logger: loggerMock
        )
        userPointManagerMock.errorToThrow = randomError
        // Act
        try await gameDataManager.performOnlineLogin()
        
        // Assert
        XCTAssertTrue(delegateMock.onErrorCalled, "Delegate's onError should be called for missing token error")
        
        userPointManagerMock.errorToThrow = nil
        userRankManagerMock.errorToThrow = randomError
        
        // Act
        try await gameDataManager.performOnlineLogin()
        
        // Assert
        XCTAssertTrue(delegateMock.onErrorCalled, "Delegate's onError should be called for missing token error")
        
        userRankManagerMock.errorToThrow = nil
        userCategoryManagerMock.errorToThrow = randomError
        
        // Act
        try await gameDataManager.performOnlineLogin()
        
        // Assert
        XCTAssertTrue(delegateMock.onErrorCalled, "Delegate's onError should be called for missing token error")
        
        userCategoryManagerMock.errorToThrow = nil
        genericPointManagerMock.errorToThrow = randomError
        
        // Act
        try await gameDataManager.performOnlineLogin()
        
        // Assert
        XCTAssertTrue(delegateMock.onErrorCalled, "Delegate's onError should be called for missing token error")
    }
    
    func testPerformOnlineLogin_SavesNewUserPointCheckSumWhenCheckSumChanges() async throws {
        persistentStorageMock.mockCheckSumData = .mock(userPoints: "")
        let mockCheckSum = "mock-checksum-userpoints"
        userPointManagerMock.checkSumReturnValue = mockCheckSum
        
        // Act
        try await gameDataManager.performOnlineLogin()
        
        // Assert
        XCTAssertTrue(persistentStorageMock.saveCheckSumDataCalled, "Check sum for user points should be updates when it changes")
        XCTAssertEqual(persistentStorageMock.mockCheckSumData?.userPoints, mockCheckSum, "Expected checksum data to be saved correctly")

    }
    
    func testPerformOnlineLogin_SameUserPointCheckSum_DoesntSaveData() async throws {
        let mockCheckSum = "mock-checksum-userpoints"
        persistentStorageMock.mockCheckSumData = .mock(userPoints: mockCheckSum)
        userPointManagerMock.checkSumReturnValue = mockCheckSum
        
        // Act
        try await gameDataManager.performOnlineLogin()
        
        // Assert
        XCTAssertFalse(persistentStorageMock.saveUserPointDataCalled, "User points should not be updated when it is the same")
    }
    
    func testPerformOnlineLogin_SavesNewGenericPointCheckSumWhenCheckSumChanges() async throws {
        persistentStorageMock.mockCheckSumData = .mock(points: "")
        let mockCheckSum = "mock-checksum-genericpoints"
        genericPointManagerMock.checkSumReturnValue = mockCheckSum

        // Act
        try await gameDataManager.performOnlineLogin()

        // Assert
        XCTAssertTrue(persistentStorageMock.saveCheckSumDataCalled, "Check sum for generic points should be updated when it changes")
        XCTAssertEqual(persistentStorageMock.mockCheckSumData?.points, mockCheckSum, "Expected generic points checksum data to be saved correctly")
    }

    func testPerformOnlineLogin_SameGenericPointCheckSum_DoesntSaveData() async throws {
        let mockCheckSum = "mock-checksum-genericpoints"
        persistentStorageMock.mockCheckSumData = .mock(points: mockCheckSum)
        genericPointManagerMock.checkSumReturnValue = mockCheckSum

        // Act
        try await gameDataManager.performOnlineLogin()

        // Assert
        XCTAssertFalse(persistentStorageMock.saveGenericPointDataCalled, "Generic points should not be updated when the checksum is the same")
    }
    
    func testPerformOnlineLogin_SavesNewUserRankCheckSumWhenCheckSumChanges() async throws {
        persistentStorageMock.mockCheckSumData = .mock(rank: "")
        let mockCheckSum = "mock-checksum-userrank"
        userRankManagerMock.checkSumReturnValue = mockCheckSum

        // Act
        try await gameDataManager.performOnlineLogin()

        // Assert
        XCTAssertTrue(persistentStorageMock.saveCheckSumDataCalled, "Check sum for user ranks should be updated when it changes")
        XCTAssertEqual(persistentStorageMock.mockCheckSumData?.rank, mockCheckSum, "Expected user rank checksum data to be saved correctly")
    }

    func testPerformOnlineLogin_SameUserRankCheckSum_DoesntSaveData() async throws {
        let mockCheckSum = "mock-checksum-userrank"
        persistentStorageMock.mockCheckSumData = .mock(rank: mockCheckSum)
        userRankManagerMock.checkSumReturnValue = mockCheckSum

        // Act
        try await gameDataManager.performOnlineLogin()

        // Assert
        XCTAssertFalse(persistentStorageMock.saveUserRankDataCalled, "User ranks should not be updated when the checksum is the same")
    }
    
    func testPerformOfflineLogin_Success() async throws {
        // Arrange
        
        // Act
        try await gameDataManager.performOfflineLogin()
        
        // Assert
        XCTAssertTrue(userPointManagerMock.loadFromRepositoryCalled, "User points should be loaded from repository")
        XCTAssertTrue(userRankManagerMock.loadFromRepositoryCalled, "User ranks should be loaded from repository")
        XCTAssertTrue(genericPointManagerMock.loadFromRepositoryCalled, "Generic points should be loaded from repository")
        XCTAssertTrue(userCategoryManagerMock.loadFromRepositoryCalled, "User categories should be loaded from repository")
    }
    
    func testLoadData_OnlineMode() async {
        // Arrange
        networkMonitorMock.mockOnlineStatus = true
        userDefaultsStorageMock.mockToken = "mock-token"
        checkSumAPIMock.userPointsResponseToReturn = .init(data: .mock(pointsProtect: "mock-check-sums"))
        persistentStorageMock.mockCheckSumData = .mock(userPoints: "")

        // Act
        await gameDataManager.loadData(for: .userPoints)

        // Assert
        XCTAssertTrue(userPointManagerMock.fetchWithTokenCalled, "User points should be fetched in online mode")
    }
    
    func testLoadData_InvalidTokenError() async {
        // Arrange
        let invalidTokenError = BaseError(
            context: .api,
            message: "Invalid Token",
            code: ErrorCodes.specificStatusCode(.invalidToken),
            logger: loggerMock
        )
        userPointManagerMock.errorToThrow = invalidTokenError
        networkMonitorMock.mockOnlineStatus = true

        // Act
        await gameDataManager.loadData(for: .userPoints)

        // Assert
        XCTAssertTrue(delegateMock.onInvalidTokenCalled, "Delegate's onInvalidToken should be called when an invalid token is encountered")
    }
    
    func testLoadData_OnError() async {
        // Arrange
        let mockError = BaseError(
            context: .api,
            message: "Some API Error",
            code: ErrorCodes.default,
            logger: loggerMock
        )
        userPointManagerMock.errorToThrow = mockError
        checkSumAPIMock.errorToThrow = mockError
        networkMonitorMock.mockOnlineStatus = true

        // Act
        await gameDataManager.loadData(for: .userPoints)

        // Assert
        XCTAssertTrue(delegateMock.onErrorCalled, "Delegate's onError should be called when an API error occurs")
    }
    
    func testReloadAfterRegistration_Success() async throws {
        // Act
        try await gameDataManager.reloadAfterRegistration()

        // Assert
        XCTAssertTrue(userCategoryManagerMock.fetchWithTokenCalled, "User categories should be fetched after registration")
        XCTAssertFalse(delegateMock.onErrorCalled, "Delegate's onError should not be called for a successful category fetch")
    }

    func testReloadAfterRegistration_OnError() async throws {
        // Arrange
        let mockError = BaseError(
            context: .api,
            message: "Some API Error",
            code: ErrorCodes.default,
            logger: loggerMock
        )
        userCategoryManagerMock.errorToThrow = mockError

        // Act
        do {
            try await gameDataManager.reloadAfterRegistration()
            XCTFail("Expected an error to be thrown")
        } catch {
        }
    }
    
    func testLoadData_WithoutCheckSum_NewDataFetched() async throws {
        // Arrange
        networkMonitorMock.mockOnlineStatus = true

        // Act
        await gameDataManager.loadData(for: .categories)

        // Assert
        XCTAssertTrue(userCategoryManagerMock.fetchWithTokenCalled, "User categories should be fetched regardless of checksum")
    }
    
    func testNetworkStatusChange_FromOfflineToOnline_ProcessesStoredPoints() async throws {
        // Arrange
        networkMonitorMock.mockOnlineStatus = true
        networkMonitorMock.simulateNetworkChange(isOnline: true)
        userDefaultsStorageMock.mockIsLoggedIn = true

        // Create an expectation
        let expectation = XCTestExpectation(description: "Stored scanned points should be processed")

        // Act
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) {
            expectation.fulfill()
        }
        
        // Wait for the network change and processing
        await fulfillment(of: [expectation], timeout: 2)
        
        // Assert
        XCTAssertTrue(userPointManagerMock.handleAllStoredScannedPointsCalled, "Stored scanned points should be processed when transitioning to online")
        XCTAssertFalse(delegateMock.storedScannedPointsFailedToSendCalled, "Delegate's storedScannedPointsFailedToSend should not be called for a successful stored scanned points processing")
    }
    
    func testNetworkStatusChange_FromOfflineToOnline_ProcessesStoredPoints_InvalidToken() async throws {
        // Arrange
        let invalidTokenError = BaseError(
            context: .api,
            message: "Invalid Token",
            code: ErrorCodes.specificStatusCode(.invalidToken),
            logger: loggerMock
        )
        userPointManagerMock.errorToThrow = invalidTokenError
        networkMonitorMock.mockOnlineStatus = true
        networkMonitorMock.simulateNetworkChange(isOnline: true)
        userDefaultsStorageMock.mockIsLoggedIn = true

        // Create an expectation
        let expectation = XCTestExpectation(description: "Stored scanned points should be processed with invalid token error")

        // Act
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) {
            expectation.fulfill()
        }
        
        // Wait for the network change and processing
        await fulfillment(of: [expectation], timeout: 2)
        
        // Assert
        XCTAssertTrue(delegateMock.onInvalidTokenCalled, "Delegate's onInvalidToken should be called when the token is invalid")
        XCTAssertFalse(delegateMock.storedScannedPointsFailedToSendCalled, "Delegate's storedScannedPointsFailedToSend should not be called for an invalid token error")
    }

    func testNetworkStatusChange_FromOfflineToOnline_ProcessesStoredPoints_OtherError() async throws {
        // Arrange
        let otherError = BaseError(
            context: .api,
            message: "Some API Error",
            code: ErrorCodes.default,
            logger: loggerMock
        )
        // Simulate error in the userPointManager when handling stored points
        userPointManagerMock.errorToThrow = otherError
        // Simulate network change from offline to online
        networkMonitorMock.mockOnlineStatus = true
        userDefaultsStorageMock.mockIsLoggedIn = true

        // Create an expectation for processing stored points
        let processingExpectation = XCTestExpectation(description: "Stored scanned points should be processed and an error should occur")

        // Act
        DispatchQueue.global().async {
            self.networkMonitorMock.simulateNetworkChange(isOnline: true)
            processingExpectation.fulfill()
        }

        // Wait for the expectation to be fulfilled (network change simulation)
        await fulfillment(of: [processingExpectation], timeout: 2)
        
        // Assert
        XCTAssertTrue(delegateMock.storedScannedPointsFailedToSendCalled, "Delegate's storedScannedPointsFailedToSend should be called when processing stored points fails with an API error")
        XCTAssertFalse(delegateMock.onInvalidTokenCalled, "Delegate's onInvalidToken should not be called for a general error")
    }
    
    func testOnPointScanned_Success() async throws {
        // Arrange
        let mockPoint = ScannedPoint.mock()

        // Act
        await gameDataManager.onPointScanned(mockPoint)

        // Assert
        XCTAssertTrue(userPointManagerMock.handleScannedPointCalled, "UserPointManager should handle the scanned point")
        XCTAssertFalse(delegateMock.onErrorCalled, "Delegate's onError should not be called for a successful point scan")
        XCTAssertFalse(delegateMock.onInvalidTokenCalled, "Delegate's onInvalidToken should not be called for a successful point scan")
    }

    func testOnPointScanned_InvalidToken() async throws {
        // Arrange
        let mockPoint = ScannedPoint.mock()
        let invalidTokenError = BaseError(
            context: .api,
            message: "Invalid Token",
            code: ErrorCodes.specificStatusCode(.invalidToken),
            logger: loggerMock
        )
        userPointManagerMock.errorToThrow = invalidTokenError

        // Act
        await gameDataManager.onPointScanned(mockPoint)

        // Assert
        XCTAssertTrue(delegateMock.onInvalidTokenCalled, "Delegate's onInvalidToken should be called when the token is invalid")
        XCTAssertFalse(delegateMock.onErrorCalled, "Delegate's onError should not be called for an invalid token error")
    }

    func testOnPointScanned_OnError() async throws {
        // Arrange
        let mockPoint = ScannedPoint.mock()
        let mockError = BaseError(
            context: .api,
            message: "Some API Error",
            code: ErrorCodes.default,
            logger: loggerMock
        )
        userPointManagerMock.errorToThrow = mockError

        // Act
        await gameDataManager.onPointScanned(mockPoint)

        // Assert
        XCTAssertTrue(delegateMock.onErrorCalled, "Delegate's onError should be called when an API error occurs")
        XCTAssertFalse(delegateMock.onInvalidTokenCalled, "Delegate's onInvalidToken should not be called for a general error")
    }
    
    func testClosestVirtualPointUpdate_TriggersGameDataManagerReactionAndProcessesVirtualPointCorrectly() async {
        // Arrange
        let mockVirtualPoint = GenericPoint.mock(id: "virtualPoint")
        let mockLocation = UserLocation.mock(latitude: 50.0, longitude: 14.0)
        let expectedScannedPoint = ScannedPoint(
            code: mockVirtualPoint.id,
            codeSource: .virtual,
            location: mockLocation
        )
        // Create an expectation to observe the publisher's output
        let publisherExpectation = XCTestExpectation(description: "isVirtualAvailablePublisher should publish true after virtual point update")
        
        var receivedIsVirtualAvailable = false

        // Subscribe to the isVirtualAvailablePublisher
        gameDataManager.isVirtualAvailablePublisher
            .sink { isAvailable in
                receivedIsVirtualAvailable = isAvailable
                if isAvailable {
                    publisherExpectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        // Act: Simulate the update of the closest virtual point in the GenericPointManagerMock
        genericPointManagerMock.simulateClosestVirtualPointUpdate(to: mockVirtualPoint)

        // Wait for the publisher to emit the value
        await fulfillment(of: [publisherExpectation], timeout: 2)
        await gameDataManager.processVirtual(location: mockLocation)
        
        // Assert: Verify that GameDataManager reacted to the virtual point update
        XCTAssertTrue(receivedIsVirtualAvailable, "GameDataManager should publish true to isVirtualAvailablePublisher when the closest virtual point is updated.")
        XCTAssertTrue(userPointManagerMock.handleScannedPointCalled, "handleScannedPoint should be called")
        XCTAssertEqual(userPointManagerMock.scannedPointToHandle?.code, expectedScannedPoint.code, "Scanned point code should match the virtual point ID")
        XCTAssertEqual(userPointManagerMock.scannedPointToHandle?.codeSource, .virtual, "Code source should be 'virtual'")
        XCTAssertEqual(userPointManagerMock.scannedPointToHandle?.location?.latitude, mockLocation.latitude, "Location latitude should match")
        XCTAssertEqual(userPointManagerMock.scannedPointToHandle?.location?.longitude, mockLocation.longitude, "Location longitude should match")
    }
    
    func testClosestVirtualPointUpdate_TriggersInvalidTokenErrorDuringProcessVirtual() async {
        // Arrange
        let mockVirtualPoint = GenericPoint.mock(id: "virtualPoint")
        let mockLocation = UserLocation.mock(latitude: 50.0, longitude: 14.0)
        
        // Simulate the "Invalid Token" error in userPointManagerMock
        let invalidTokenError = BaseError(
            context: .api,
            message: "Invalid Token",
            code: ErrorCodes.specificStatusCode(.invalidToken),
            logger: loggerMock
        )
        userPointManagerMock.errorToThrow = invalidTokenError

        // Create an expectation to observe the publisher's output
        let publisherExpectation = XCTestExpectation(description: "isVirtualAvailablePublisher should publish true after virtual point update")
        
        var receivedIsVirtualAvailable = false

        // Subscribe to the isVirtualAvailablePublisher
        gameDataManager.isVirtualAvailablePublisher
            .sink { isAvailable in
                receivedIsVirtualAvailable = isAvailable
                if isAvailable {
                    publisherExpectation.fulfill()
                }
            }
            .store(in: &cancellables)

        // Act: Simulate the update of the closest virtual point in the GenericPointManagerMock
        genericPointManagerMock.simulateClosestVirtualPointUpdate(to: mockVirtualPoint)

        // Wait for the publisher to emit the value
        await fulfillment(of: [publisherExpectation], timeout: 2)
        
        // Act: Call processVirtual
        await gameDataManager.processVirtual(location: mockLocation)

        // Assert: Verify that GameDataManager reacted to the virtual point update
        XCTAssertTrue(receivedIsVirtualAvailable, "GameDataManager should publish true to isVirtualAvailablePublisher when the closest virtual point is updated.")
        XCTAssertTrue(userPointManagerMock.handleScannedPointCalled, "handleScannedPoint should be called")
        XCTAssertTrue(delegateMock.onInvalidTokenCalled, "onInvalidToken should be called when an invalid token is encountered.")
        XCTAssertFalse(delegateMock.onErrorCalled, "onError should not be called for an invalid token error.")
    }
    
    func testClosestVirtualPointUpdate_TriggersGeneralErrorDuringProcessVirtual() async {
        // Arrange
        let mockVirtualPoint = GenericPoint.mock(id: "virtualPoint")
        let mockLocation = UserLocation.mock(latitude: 50.0, longitude: 14.0)
        
        // Simulate a general error in userPointManagerMock
        let generalError = BaseError(
            context: .api,
            message: "Some API Error",
            code: ErrorCodes.default,
            logger: loggerMock
        )
        userPointManagerMock.errorToThrow = generalError

        // Create an expectation to observe the publisher's output
        let publisherExpectation = XCTestExpectation(description: "isVirtualAvailablePublisher should publish true after virtual point update")
        
        var receivedIsVirtualAvailable = false

        // Subscribe to the isVirtualAvailablePublisher
        gameDataManager.isVirtualAvailablePublisher
            .sink { isAvailable in
                receivedIsVirtualAvailable = isAvailable
                if isAvailable {
                    publisherExpectation.fulfill()
                }
            }
            .store(in: &cancellables)

        // Act: Simulate the update of the closest virtual point in the GenericPointManagerMock
        genericPointManagerMock.simulateClosestVirtualPointUpdate(to: mockVirtualPoint)

        // Wait for the publisher to emit the value
        await fulfillment(of: [publisherExpectation], timeout: 2)
        
        // Act: Call processVirtual
        await gameDataManager.processVirtual(location: mockLocation)

        // Assert: Verify that GameDataManager reacted to the virtual point update
        XCTAssertTrue(receivedIsVirtualAvailable, "GameDataManager should publish true to isVirtualAvailablePublisher when the closest virtual point is updated.")
        XCTAssertTrue(userPointManagerMock.handleScannedPointCalled, "handleScannedPoint should be called")
        XCTAssertTrue(delegateMock.onErrorCalled, "onError should be called when a general error occurs.")
        XCTAssertFalse(delegateMock.onInvalidTokenCalled, "onInvalidToken should not be called for a general error.")
    }
    
    func testProcessVirtual_WithNilClosestVirtualPoint_DoesNothing() async {
        // Arrange: Set the closestVirtualPoint to nil in the GenericPointManagerMock
        genericPointManagerMock.simulateClosestVirtualPointUpdate(to: nil)
        let mockLocation = UserLocation.mock(latitude: 50.0, longitude: 14.0)

        // Create an expectation for asynchronous operation
        let publisherExpectation = XCTestExpectation(description: "isVirtualAvailablePublisher should publish false after closestVirtualPoint is nil")
        
        var receivedIsVirtualAvailable = true // Default to true

        // Subscribe to the isVirtualAvailablePublisher
        gameDataManager.isVirtualAvailablePublisher
            .sink { isAvailable in
                receivedIsVirtualAvailable = isAvailable
                if !isAvailable {
                    publisherExpectation.fulfill()
                }
            }
            .store(in: &cancellables)

        // Act: Wait for the virtual point to be updated to `nil`
        await fulfillment(of: [publisherExpectation], timeout: 2)
        
        // Call processVirtual with a mock location
        await gameDataManager.processVirtual(location: mockLocation)

        // Assert: Verify that GameDataManager did not process the virtual point since it's nil
        XCTAssertFalse(receivedIsVirtualAvailable, "GameDataManager should publish false to isVirtualAvailablePublisher when the closest virtual point is nil.")
        XCTAssertFalse(userPointManagerMock.handleScannedPointCalled, "handleScannedPoint should not be called when the closest virtual point is nil.")
        XCTAssertFalse(delegateMock.onErrorCalled, "onError should not be called when the closest virtual point is nil.")
        XCTAssertFalse(delegateMock.onInvalidTokenCalled, "onInvalidToken should not be called when the closest virtual point is nil.")
    }
}
