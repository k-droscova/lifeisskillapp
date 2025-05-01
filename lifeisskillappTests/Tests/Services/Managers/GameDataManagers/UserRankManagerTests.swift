//
//  UserRankManagerTests.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 18.10.2024.
//

import XCTest
@testable import lifeisskillapp

final class UserRankManagerTests: XCTestCase {

    // MARK: - Mocks and Dependencies

    private struct Dependencies: UserRankManager.Dependencies {
        var userManager: UserManaging
        var userDefaultsStorage: UserDefaultsStoraging
        var logger: LoggerServicing
        var userDataAPI: UserDataAPIServicing
        var storage: PersistentUserDataStoraging
        var networkMonitor: NetworkMonitoring
    }
    
    var logger: LoggerServicing!
    var userManagerMock: UserManagerMock!
    var userDefaultStorageMock: UserDefaultsStorageMock!
    var userDataAPIMock: UserDataAPIServiceMock!
    var persistentStorageMock: PersistentUserDataStorageMock!
    var networkMonitorMock: NetworkMonitorMock!
    var userRankManager: UserRankManager!

    // MARK: - Setup and Teardown

    override func setUpWithError() throws {
        try super.setUpWithError()

        logger = LoggingServiceMock()
        userManagerMock = UserManagerMock()
        userDefaultStorageMock = UserDefaultsStorageMock()
        userDataAPIMock = UserDataAPIServiceMock()
        persistentStorageMock = PersistentUserDataStorageMock()
        networkMonitorMock = NetworkMonitorMock()

        let dependencies = Dependencies(
            userManager: userManagerMock,
            userDefaultsStorage: userDefaultStorageMock,
            logger: logger,
            userDataAPI: userDataAPIMock,
            storage: persistentStorageMock,
            networkMonitor: networkMonitorMock
        )

        userRankManager = UserRankManager(dependencies: dependencies)
    }

    override func tearDownWithError() throws {
        logger = nil
        userDefaultStorageMock = nil
        userDataAPIMock = nil
        persistentStorageMock = nil
        networkMonitorMock = nil
        userRankManager = nil

        try super.tearDownWithError()
    }

    // MARK: - Test Cases

    // Test for successful fetch with token
    func testFetchWithToken_SuccessfulFetch() async throws {
        // Arrange
        userDefaultStorageMock.mockToken = "mockToken"
        
        // Act
        try await userRankManager.fetch()
        let data = userRankManager.getAll()
        
        // Assert
        XCTAssertTrue(userDataAPIMock.userRanksCalled, "userRanks API should be called")
        XCTAssertTrue(data.isNotEmpty, "User ranks should not be empty")
        XCTAssertEqual(userDataAPIMock.userTokenArgument, userDefaultStorageMock.token, "Correct token should be passed to userRanks API")
    }
    
    func testFetch_CallsAPIAndSavesToStorage() async throws {
        // Arrange
        let mockToken = "mockToken"
        userDefaultStorageMock.mockToken = mockToken
        let mockResponseData = UserRankData.mock()
        
        // Set up mock API response
        userDataAPIMock.userRanksResponseToReturn = APIResponse(data: mockResponseData)

        // Act
        try await userRankManager.fetch()

        // Assert
        // Check that userDataAPIService was called with the correct token
        XCTAssertTrue(userDataAPIMock.userRanksCalled, "userRanks API should be called")
        XCTAssertEqual(userDataAPIMock.userTokenArgument, mockToken, "Correct token should be passed to userRanks API")

        // Check that storage.saveUserRankData was called with the data returned by userDataAPIService
        XCTAssertTrue(persistentStorageMock.saveUserRankDataCalled, "saveUserRankData should be called on the storage")
        XCTAssertEqual(persistentStorageMock.userRankDataArgument?.checkSum, mockResponseData.checkSum, "The same data returned by the API should be passed to saveUserRankData")
        XCTAssertEqual(persistentStorageMock.userRankDataArgument?.data.count, mockResponseData.data.count, "The same data returned by the API should be passed to saveUserRankData")
    }

    // Test for missing token
    func testFetchWithToken_TokenIsMissing_ThrowsError() async throws {
        // Arrange
        userDefaultStorageMock.token = nil
        
        // Act & Assert
        do {
            try await userRankManager.fetch()
            XCTFail("fetch() should throw an error when token is missing")
        } catch let error as BaseError {
            XCTAssertEqual(error.code, ErrorCodes.general(.missingToken).code, "Expected missing token error")
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }

    // Test for API failure
    func testFetchWithToken_ApiFailure_ThrowsError() async throws {
        // Arrange
        let mockToken = "mockToken"
        userDefaultStorageMock.token = mockToken
        let mockApiError = BaseError(context: .api, message: "API Failure", logger: logger)
        userDataAPIMock.errorToThrow = mockApiError
        
        // Act & Assert
        do {
            try await userRankManager.fetch(withToken: mockToken)
            XCTFail("fetch() should throw an API error")
        } catch let error as BaseError {
            XCTAssertEqual(error.code, mockApiError.code, "Expected API error")
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }

    // Test getting a rank by ID
    func testGetById_ReturnsCorrectRank() async {
        // Arrange
        let mockRank = UserRank.mock(catId: "testRank")
        persistentStorageMock.mockUserRankData = UserRankData.mock(data: [mockRank])
        await userRankManager.loadFromRepository()
        
        // Act
        let retrievedRank = userRankManager.getById(id: "testRank")
        
        // Assert
        XCTAssertEqual(retrievedRank?.id, mockRank.id, "getById should return the correct rank by ID")
    }

    // Test getting a rank by invalid ID
    func testGetById_ReturnsNilForInvalidId() async {
        // Arrange
        let mockRank = UserRank.mock(catId: "validId")
        persistentStorageMock.mockUserRankData = UserRankData.mock(data: [mockRank])
        await userRankManager.loadFromRepository()

        // Act
        let retrievedRank = userRankManager.getById(id: "invalidId")

        // Assert
        XCTAssertNil(retrievedRank, "getById should return nil for an invalid ID")
    }

    // Test getting all ranks
    func testGetAll_ReturnsAllRanks() async {
        // Arrange
        let mockRanks = [UserRank.mock(), UserRank.mock()]
        persistentStorageMock.mockUserRankData = UserRankData.mock(data: mockRanks)
        await userRankManager.loadFromRepository()

        // Act
        let ranks = userRankManager.getAll()

        // Assert
        XCTAssertEqual(ranks.count, mockRanks.count, "getAll should return all ranks stored")
    }

    // Test onLogout clears data
    func testOnLogout_ClearsUserRankData() async {
        // Arrange
        persistentStorageMock.mockUserRankData = UserRankData.mock()
        await userRankManager.loadFromRepository()

        // Act
        userRankManager.onLogout()

        // Assert
        XCTAssertEqual(userRankManager.getAll().count, 0, "All ranks should be cleared on logout")
        XCTAssertNil(userRankManager.checkSum(), "CheckSum should be cleared on logout")
    }
    
    // Test checkSum returns correct value
    func testCheckSum_ReturnsCorrectCheckSum() async {
        // Arrange
        let expectedChecksum = "mockCheckSum"
        persistentStorageMock.mockUserRankData = UserRankData.mock(checkSum: expectedChecksum)
        await userRankManager.loadFromRepository()

        // Act
        let checkSum = userRankManager.checkSum()

        // Assert
        XCTAssertEqual(checkSum, expectedChecksum, "checkSum should return the correct checksum from storage")
    }
}
