//
//  GenericPointManagerTests.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 18.10.2024.
//

import XCTest
import Combine
@testable import lifeisskillapp

final class GenericPointManagerTests: XCTestCase {

    // MARK: - Mocks and Dependencies

    private struct Dependencies: GenericPointManager.Dependencies {
        var userDefaultsStorage: UserDefaultsStoraging
        var logger: LoggerServicing
        var userDataAPI: UserDataAPIServicing
        var storage: PersistentUserDataStoraging
        var networkMonitor: NetworkMonitoring
        var locationManager: LocationManaging
    }
    
    var logger: LoggerServicing!
    var userDefaultStorageMock: UserDefaultsStorageMock!
    var userDataAPIMock: UserDataAPIServiceMock!
    var persistentStorageMock: PersistentUserDataStorageMock!
    var networkMonitorMock: NetworkMonitorMock!
    var locationManagerMock: LocationManagerMock!
    var genericPointManager: GenericPointManager!
    var cancellables: Set<AnyCancellable>!

    // MARK: - Setup and Teardown

    override func setUpWithError() throws {
        try super.setUpWithError()

        logger = LoggingServiceMock()
        userDefaultStorageMock = UserDefaultsStorageMock()
        userDataAPIMock = UserDataAPIServiceMock()
        persistentStorageMock = PersistentUserDataStorageMock()
        networkMonitorMock = NetworkMonitorMock()
        locationManagerMock = LocationManagerMock()

        let dependencies = Dependencies(
            userDefaultsStorage: userDefaultStorageMock,
            logger: logger,
            userDataAPI: userDataAPIMock,
            storage: persistentStorageMock,
            networkMonitor: networkMonitorMock,
            locationManager: locationManagerMock
        )

        genericPointManager = GenericPointManager(dependencies: dependencies)
        cancellables = []
    }

    override func tearDownWithError() throws {
        logger = nil
        userDefaultStorageMock = nil
        userDataAPIMock = nil
        persistentStorageMock = nil
        networkMonitorMock = nil
        locationManagerMock = nil
        genericPointManager = nil
        cancellables = nil

        try super.tearDownWithError()
    }

    // MARK: - Test Cases

    func testFetchWithToken_SuccessfulFetch() async throws {
        // Arrange
        userDefaultStorageMock.mockToken = "mockToken"
        
        // Act
        try await genericPointManager.fetch()
        
        // Assert
        XCTAssertTrue(userDataAPIMock.genericPointsCalled, "genericPoints API should be called")
        XCTAssertEqual(userDataAPIMock.userTokenArgument, userDefaultStorageMock.token, "Correct token should be passed to genericPoints API")
    }

    func testFetchWithToken_TokenIsMissing_ThrowsError() async throws {
        // Arrange
        userDefaultStorageMock.token = nil
        
        // Act & Assert
        do {
            try await genericPointManager.fetch()
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
            try await genericPointManager.fetch(withToken: mockToken)
            XCTFail("fetch() should throw an API error")
        } catch let error as BaseError {
            XCTAssertEqual(error.code, mockApiError.code, "Expected API error")
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }
    
    func testFetch_CallsAPIAndSavesToStorage() async throws {
        // Arrange
        let mockToken = "mockToken"
        userDefaultStorageMock.mockToken = mockToken
        let mockResponseData = GenericPointData.mock()
        
        // Set up mock API response
        userDataAPIMock.genericPointsResponseToReturn = APIResponse(data: mockResponseData)

        // Act
        try await genericPointManager.fetch()

        // Assert
        // Check that userDataAPIService was called with the correct token
        XCTAssertTrue(userDataAPIMock.genericPointsCalled, "genericPoints API should be called")
        XCTAssertEqual(userDataAPIMock.userTokenArgument, mockToken, "Correct token should be passed to genericPoints API")

        // Check that storage.saveGenericPointData was called with the data returned by userDataAPIService
        XCTAssertTrue(persistentStorageMock.saveGenericPointDataCalled, "saveGenericPointData should be called on the storage")
        XCTAssertEqual(persistentStorageMock.genericPointDataArgument?.checkSum, mockResponseData.checkSum, "The same data returned by the API should be passed to saveGenericPointData")
        XCTAssertEqual(persistentStorageMock.genericPointDataArgument?.data.count, mockResponseData.data.count, "The same data returned by the API should be passed to saveGenericPointData")
    }

    func testGetById_ReturnsCorrectPoint() async {
        // Arrange
        let mockPoint = GenericPoint.mock(id: "testPoint")
        persistentStorageMock.mockGenericPointData = GenericPointData.mock(data: [mockPoint])
        await genericPointManager.loadFromRepository()
        
        // Act
        let retrievedPoint = genericPointManager.getById(id: "testPoint")
        
        // Assert
        XCTAssertEqual(retrievedPoint?.id, mockPoint.id, "getById should return the correct point by ID")
        XCTAssertEqual(retrievedPoint?.pointType, mockPoint.pointType, "getById should return the correct pointType")
    }

    func testGetById_ReturnsNilForInvalidId() async {
        // Arrange
        let mockPoint = GenericPoint.mock(id: "testPoint")
        persistentStorageMock.mockGenericPointData = GenericPointData.mock(data: [mockPoint])
        await genericPointManager.loadFromRepository()

        // Act
        let retrievedPoint = genericPointManager.getById(id: "invalidId")

        // Assert
        XCTAssertNil(retrievedPoint, "getById should return nil for an invalid ID")
    }

    func testGetAll_ReturnsAllPoints() async {
        // Arrange
        let mockPoints = [GenericPoint.mock(id: "point1"), GenericPoint.mock(id: "point2")]
        persistentStorageMock.mockGenericPointData = GenericPointData.mock(data: mockPoints)
        await genericPointManager.loadFromRepository()

        // Act
        let points = genericPointManager.getAll()

        // Assert
        XCTAssertEqual(points.count, mockPoints.count, "getAll should return all points stored")
    }

    func testSponsorImageFetch_ReturnsCorrectImage() async throws {
        // Arrange
        userDefaultStorageMock.mockToken = "token"
        let mockSponsorId = "sponsor1"
        let mockImageData = Data([0x01, 0x02])
        userDataAPIMock.sponsorImageResponseToReturn = mockImageData

        // Act
        let imageData = try await genericPointManager.sponsorImage(for: mockSponsorId, width: 100, height: 100)

        // Assert
        XCTAssertEqual(imageData, mockImageData, "sponsorImage should return the correct image data")
        XCTAssertTrue(userDataAPIMock.sponsorImageCalled, "sponsorImage API should be called")
        XCTAssertEqual(userDataAPIMock.sponsorIdArgument, mockSponsorId, "The correct sponsorId should be passed to the API")
    }

    func testSponsorImageFetch_MissingToken_ThrowsError() async throws {
        // Arrange
        userDefaultStorageMock.token = nil
        let mockSponsorId = "sponsor1"

        // Act & Assert
        do {
            _ = try await genericPointManager.sponsorImage(for: mockSponsorId, width: 100, height: 100)
            XCTFail("sponsorImage() should throw an error when token is missing")
        } catch let error as BaseError {
            XCTAssertEqual(error.code, ErrorCodes.general(.missingConfigItem).code, "Expected missing token error")
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }

    func testGetClosestVirtualPoint_ReturnsCorrectPoint() async {
        // Arrange
        let mockPoints = [
            GenericPoint.mock(id: "virtualPoint1", pointLat: 1, pointLng: 1, pointType: .virtual),
            GenericPoint.mock(id: "virtualPoint2", pointLat: 2, pointLng: 2, pointType: .virtual)
        ]
        persistentStorageMock.mockGenericPointData = GenericPointData.mock(data: mockPoints)
        await genericPointManager.loadFromRepository()

        // Simulate location update
        locationManagerMock.simulateLocationUpdate(UserLocation.mock(latitude: 1.0000001, longitude: 1.000001))

        // Assert
        let closestPoint = genericPointManager.closestVirtualPoint
        XCTAssertEqual(closestPoint?.id, "virtualPoint1", "The closest virtual point should be virtualPoint1")
    }
    
    func testOnLogout_ClearsGenericPointData() async {
        // Arrange
        persistentStorageMock.mockGenericPointData = GenericPointData.mock()
        await genericPointManager.loadFromRepository()

        // Act
        genericPointManager.onLogout()

        // Assert
        XCTAssertEqual(genericPointManager.getAll().count, 0, "All generic points should be cleared on logout")
        XCTAssertNil(genericPointManager.checkSum(), "CheckSum should be cleared on logout")
    }
    
    func testCheckSum_ReturnsCorrectCheckSum() async {
        // Arrange
        let expectedChecksum = "mockCheckSum"
        persistentStorageMock.mockGenericPointData = GenericPointData.mock(checkSum: expectedChecksum)
        await genericPointManager.loadFromRepository()

        // Act
        let checkSum = genericPointManager.checkSum()

        // Assert
        XCTAssertEqual(checkSum, expectedChecksum, "checkSum should return the correct checksum from storage")
    }
}
