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
}
