//
//  CheckSumAPITests.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 29.09.2024.
//

import XCTest
@testable import lifeisskillapp

final class CheckSumAPIServiceTests: XCTestCase {
    
    private struct Dependencies: CheckSumAPIService.Dependencies {
        let network: Networking
        let logger: LoggerServicing
        let storage: PersistentUserDataStoraging
    }
    
    var networkMock: NetworkingMock!
    var loggerMock: LoggerServicing!
    var storageMock: PersistentUserDataStorageMock!
    var service: CheckSumAPIServicing!
    
    override func setUpWithError() throws {
        networkMock = NetworkingMock()
        loggerMock = LoggingServiceMock()
        storageMock = PersistentUserDataStorageMock()
        
        let dependencies = Dependencies(network: networkMock, logger: loggerMock, storage: storageMock)
        service = CheckSumAPIService(dependencies: dependencies)
    }
    
    override func tearDownWithError() throws {
        networkMock = nil
        loggerMock = nil
        storageMock = nil
        service = nil
    }
}

// MARK: - Testing that each protocol func calls API with correct request

extension CheckSumAPIServiceTests {
    
    func testUserPointsCallsAPIWithCorrectRequest() async throws {
        do {
            // Arrange
            storageMock.mockToken = "mockToken"
            let expectedURL = URL(string: "https://api-test.lifeisskill.cz/v1.0/userpoints")!
            let mockAPIResponse = CheckSumUserPointsData.mock()
            let mockResponse = APIResponse(data: mockAPIResponse)
            networkMock.responseToReturn = mockResponse
            
            // Act
            _ = try await service.userPoints()
            
            // Assert
            XCTAssertEqual(networkMock.capturedMethod, .PATCH, "HTTP method should be PATCH")
            XCTAssertEqual(networkMock.capturedURL, expectedURL, "The URL should match the user points endpoint")
            XCTAssertEqual(networkMock.capturedHeaders?["Authorization"], APIHeader.authorizationHeader["Authorization"])
            XCTAssertEqual(networkMock.capturedHeaders?["Api-Key"], APIHeader.apiKeyHeader["Api-Key"])
            XCTAssertEqual(networkMock.capturedHeaders?["User-Token"], "mockToken", "The User-Token header should match the provided token")
            XCTAssertNil(networkMock.capturedBody, "The request body should be nil")
        } catch {
            XCTFail("Unexpected error thrown: \(error)")
        }
    }
    
    func testUserRankCallsAPIWithCorrectRequest() async throws {
        do {
            // Arrange
            storageMock.mockToken = "mockToken"
            let expectedURL = URL(string: "https://api-test.lifeisskill.cz/v1.0/rank")!
            let mockAPIResponse = CheckSumRankData.mock()
            let mockResponse = APIResponse(data: mockAPIResponse)
            networkMock.responseToReturn = mockResponse
            
            // Act
            _ = try await service.userRank()
            
            // Assert
            XCTAssertEqual(networkMock.capturedMethod, .PATCH, "HTTP method should be PATCH")
            XCTAssertEqual(networkMock.capturedURL, expectedURL, "The URL should match the rank endpoint")
            XCTAssertEqual(networkMock.capturedHeaders?["Authorization"], APIHeader.authorizationHeader["Authorization"])
            XCTAssertEqual(networkMock.capturedHeaders?["Api-Key"], APIHeader.apiKeyHeader["Api-Key"])
            XCTAssertEqual(networkMock.capturedHeaders?["User-Token"], "mockToken", "The User-Token header should match the provided token")
            XCTAssertNil(networkMock.capturedBody, "The request body should be nil")
        } catch {
            XCTFail("Unexpected error thrown: \(error)")
        }
    }
    
    func testUserMessagesCallsAPIWithCorrectRequest() async throws {
        do {
            // Arrange
            storageMock.mockToken = "mockToken"
            let expectedURL = URL(string: "https://api-test.lifeisskill.cz/v1.0/messages")!
            let mockAPIResponse = CheckSumMessagesData.mock()
            let mockResponse = APIResponse(data: mockAPIResponse)
            networkMock.responseToReturn = mockResponse
            
            // Act
            _ = try await service.userMessages()
            
            // Assert
            XCTAssertEqual(networkMock.capturedMethod, .PATCH, "HTTP method should be PATCH")
            XCTAssertEqual(networkMock.capturedURL, expectedURL, "The URL should match the messages endpoint")
            XCTAssertEqual(networkMock.capturedHeaders?["Authorization"], APIHeader.authorizationHeader["Authorization"])
            XCTAssertEqual(networkMock.capturedHeaders?["Api-Key"], APIHeader.apiKeyHeader["Api-Key"])
            XCTAssertEqual(networkMock.capturedHeaders?["User-Token"], "mockToken", "The User-Token header should match the provided token")
            XCTAssertNil(networkMock.capturedBody, "The request body should be nil")
        } catch {
            XCTFail("Unexpected error thrown: \(error)")
        }
    }
    
    func testUserEventsCallsAPIWithCorrectRequest() async throws {
        do {
            // Arrange
            storageMock.mockToken = "mockToken"
            let expectedURL = URL(string: "https://api-test.lifeisskill.cz/v1.0/events")!
            let mockAPIResponse = CheckSumEventsData.mock()
            let mockResponse = APIResponse(data: mockAPIResponse)
            networkMock.responseToReturn = mockResponse
            
            // Act
            _ = try await service.userEvents()
            
            // Assert
            XCTAssertEqual(networkMock.capturedMethod, .PATCH, "HTTP method should be PATCH")
            XCTAssertEqual(networkMock.capturedURL, expectedURL, "The URL should match the events endpoint")
            XCTAssertEqual(networkMock.capturedHeaders?["Authorization"], APIHeader.authorizationHeader["Authorization"])
            XCTAssertEqual(networkMock.capturedHeaders?["Api-Key"], APIHeader.apiKeyHeader["Api-Key"])
            XCTAssertEqual(networkMock.capturedHeaders?["User-Token"], "mockToken", "The User-Token header should match the provided token")
            XCTAssertNil(networkMock.capturedBody, "The request body should be nil")
        } catch {
            XCTFail("Unexpected error thrown: \(error)")
        }
    }
    
    func testGenericPointsCallsAPIWithCorrectRequest() async throws {
        do {
            // Arrange
            storageMock.mockToken = "mockToken"
            let expectedURL = URL(string: "https://api-test.lifeisskill.cz/v1.0/points")!
            let mockAPIResponse = CheckSumPointsData.mock()
            let mockResponse = APIResponse(data: mockAPIResponse)
            networkMock.responseToReturn = mockResponse
            
            // Act
            _ = try await service.genericPoints()
            
            // Assert
            XCTAssertEqual(networkMock.capturedMethod, .PATCH, "HTTP method should be PATCH")
            XCTAssertEqual(networkMock.capturedURL, expectedURL, "The URL should match the points endpoint")
            XCTAssertEqual(networkMock.capturedHeaders?["Authorization"], APIHeader.authorizationHeader["Authorization"])
            XCTAssertEqual(networkMock.capturedHeaders?["Api-Key"], APIHeader.apiKeyHeader["Api-Key"])
            XCTAssertEqual(networkMock.capturedHeaders?["User-Token"], "mockToken", "The User-Token header should match the provided token")
            XCTAssertNil(networkMock.capturedBody, "The request body should be nil")
        } catch {
            XCTFail("Unexpected error thrown: \(error)")
        }
    }
}

// MARK: - Testing that each protocol func returns expected data upon successful call

extension CheckSumAPIServiceTests {
    
    func testUserPointsReturnsExpectedData() async throws {
        do {
            // Arrange
            storageMock.mockToken = "mockToken"
            let mockAPIResponse = CheckSumUserPointsData.mock()
            let mockResponse = APIResponse(data: mockAPIResponse)
            networkMock.responseToReturn = mockResponse
            
            // Act
            let response: APIResponse<CheckSumUserPointsData> = try await service.userPoints()
            
            // Assert
            XCTAssertEqual(response.data.pointsProtect, mockAPIResponse.pointsProtect, "The checkSum should match the mock data")
        } catch {
            XCTFail("Unexpected error thrown: \(error)")
        }
    }
    
    func testUserRankReturnsExpectedData() async throws {
        do {
            // Arrange
            storageMock.mockToken = "mockToken"
            let mockAPIResponse = CheckSumRankData.mock()
            let mockResponse = APIResponse(data: mockAPIResponse)
            networkMock.responseToReturn = mockResponse
            
            // Act
            let response: APIResponse<CheckSumRankData> = try await service.userRank()
            
            // Assert
            XCTAssertEqual(response.data.rankProtect, mockAPIResponse.rankProtect, "The checkSum should match the mock data")
            
        } catch {
            XCTFail("Unexpected error thrown: \(error)")
        }
    }
    
    func testUserMessagesReturnsExpectedData() async throws {
        do {
            // Arrange
            storageMock.mockToken = "mockToken"
            let mockAPIResponse = CheckSumMessagesData.mock()
            let mockResponse = APIResponse(data: mockAPIResponse)
            networkMock.responseToReturn = mockResponse
            
            // Act
            let response: APIResponse<CheckSumMessagesData> = try await service.userMessages()
            
            // Assert
            XCTAssertEqual(response.data.msgProtect, mockAPIResponse.msgProtect, "The msgProtect should match the mock data")
        } catch {
            XCTFail("Unexpected error thrown: \(error)")
        }
    }
    
    func testUserEventsReturnsExpectedData() async throws {
        do {
            // Arrange
            storageMock.mockToken = "mockToken"
            let mockAPIResponse = CheckSumEventsData.mock()
            let mockResponse = APIResponse(data: mockAPIResponse)
            networkMock.responseToReturn = mockResponse
            
            // Act
            let response: APIResponse<CheckSumEventsData> = try await service.userEvents()
            
            // Assert
            XCTAssertEqual(response.data.eventsProtect, mockAPIResponse.eventsProtect, "The eventsProtect should match the mock data")
        } catch {
            XCTFail("Unexpected error thrown: \(error)")
        }
    }
    
    func testGenericPointsReturnsExpectedData() async throws {
        do {
            // Arrange
            storageMock.mockToken = "mockToken"
            let mockAPIResponse = CheckSumPointsData.mock()
            let mockResponse = APIResponse(data: mockAPIResponse)
            networkMock.responseToReturn = mockResponse
            
            // Act
            let response: APIResponse<CheckSumPointsData> = try await service.genericPoints()
            
            // Assert
            XCTAssertEqual(response.data.pointsProtect, mockAPIResponse.pointsProtect, "The pointsProtect should match the mock data")
            XCTAssertEqual(response.data.clusterProtect, mockAPIResponse.clusterProtect, "The clusterProtect should match the mock data")
        } catch {
            XCTFail("Unexpected error thrown: \(error)")
        }
    }
}

// MARK: - Testing that each protocol func propagates errors

extension CheckSumAPIServiceTests {
    
    func testUserPointsHandlesNetworkError() async throws {
        // Arrange: Simulate a network error
        networkMock.errorToThrow = BaseError(
            context: .network,
            message: "Test network error",
            code: .networking(.unknown),
            logger: loggerMock
        )
        
        // Act & Assert
        do {
            let _: APIResponse<CheckSumUserPointsData> = try await service.userPoints()
            XCTFail("Expected an error to be thrown, but none was thrown")
        } catch let error as BaseError {
            XCTAssertEqual(error.message, "Test network error", "The error message should match")
            XCTAssertEqual(error.code, ErrorCodes.networking(.unknown).code, "The error code should match")
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }
    
    func testUserRankHandlesNetworkError() async throws {
        // Arrange: Simulate a network error
        networkMock.errorToThrow = BaseError(
            context: .network,
            message: "Test network error",
            code: .networking(.unknown),
            logger: loggerMock
        )
        
        // Act & Assert
        do {
            let _: APIResponse<CheckSumRankData> = try await service.userRank()
            XCTFail("Expected an error to be thrown, but none was thrown")
        } catch let error as BaseError {
            XCTAssertEqual(error.message, "Test network error", "The error message should match")
            XCTAssertEqual(error.code, ErrorCodes.networking(.unknown).code, "The error code should match")
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }
    
    func testUserMessagesHandlesNetworkError() async throws {
        // Arrange: Simulate a network error
        networkMock.errorToThrow = BaseError(
            context: .network,
            message: "Test network error",
            code: .networking(.unknown),
            logger: loggerMock
        )
        
        // Act & Assert
        do {
            let _: APIResponse<CheckSumMessagesData> = try await service.userMessages()
            XCTFail("Expected an error to be thrown, but none was thrown")
        } catch let error as BaseError {
            XCTAssertEqual(error.message, "Test network error", "The error message should match")
            XCTAssertEqual(error.code, ErrorCodes.networking(.unknown).code, "The error code should match")
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }
    
    func testUserEventsHandlesNetworkError() async throws {
        // Arrange: Simulate a network error
        networkMock.errorToThrow = BaseError(
            context: .network,
            message: "Test network error",
            code: .networking(.unknown),
            logger: loggerMock
        )
        
        // Act & Assert
        do {
            let _: APIResponse<CheckSumEventsData> = try await service.userEvents()
            XCTFail("Expected an error to be thrown, but none was thrown")
        } catch let error as BaseError {
            XCTAssertEqual(error.message, "Test network error", "The error message should match")
            XCTAssertEqual(error.code, ErrorCodes.networking(.unknown).code, "The error code should match")
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }
    
    func testGenericPointsHandlesNetworkError() async throws {
        // Arrange: Simulate a network error
        networkMock.errorToThrow = BaseError(
            context: .network,
            message: "Test network error",
            code: .networking(.unknown),
            logger: loggerMock
        )
        
        // Act & Assert
        do {
            let _: APIResponse<CheckSumPointsData> = try await service.genericPoints()
            XCTFail("Expected an error to be thrown, but none was thrown")
        } catch let error as BaseError {
            XCTAssertEqual(error.message, "Test network error", "The error message should match")
            XCTAssertEqual(error.code, ErrorCodes.networking(.unknown).code, "The error code should match")
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }
}
