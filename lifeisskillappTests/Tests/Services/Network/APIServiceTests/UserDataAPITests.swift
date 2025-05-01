//
//  UserDataAPITests.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 29.09.2024.
//

import XCTest
@testable import lifeisskillapp

final class UserDataAPIServiceTests: XCTestCase {
    
    private struct Dependencies: UserDataAPIService.Dependencies {
        let network: Networking
        let logger: LoggerServicing
    }
    
    var networkMock: NetworkingMock!
    var loggerMock: LoggerServicing!
    var service: UserDataAPIServicing!
    
    override func setUpWithError() throws {
        networkMock = NetworkingMock()
        loggerMock = LoggingServiceMock()
        let dependencies = Dependencies(network: networkMock, logger: loggerMock)
        service = UserDataAPIService(dependencies: dependencies)
    }
    
    override func tearDownWithError() throws {
        networkMock = nil
        loggerMock = nil
        service = nil
    }
}

// MARK: - Testing that each protocol func calls API with correct request

extension UserDataAPIServiceTests {
    
    func testUserPointsCallsAPIWithCorrectRequest() async throws {
        do {
            // Arrange
            let userToken = "mockToken"
            let expectedURL = URL(string: "https://api-test.lifeisskill.cz/v1.0/userpoints")!
            let mockResponse = APIResponse(data: UserPointData.mock())
            networkMock.responseToReturn = mockResponse
            
            // Act
            _ = try await service.userPoints(userToken: userToken)
            
            // Assert
            XCTAssertEqual(networkMock.capturedMethod, .GET, "HTTP method should be GET")
            XCTAssertEqual(networkMock.capturedURL, expectedURL, "The URL should match the user points endpoint")
            XCTAssertEqual(networkMock.capturedHeaders?["Authorization"], APIHeader.authorizationHeader["Authorization"])
            XCTAssertEqual(networkMock.capturedHeaders?["Api-Key"], APIHeader.apiKeyHeader["Api-Key"])
            XCTAssertEqual(networkMock.capturedHeaders?["User-Token"], userToken, "The User-Token header should match the provided token")
            XCTAssertNil(networkMock.capturedBody, "The request body should be nil")
        } catch {
            XCTFail("Unexpected error thrown: \(error)")
        }
    }
    
    func testUserCategoriesCallsAPIWithCorrectRequest() async throws {
        do {
            // Arrange
            let userToken = "mockToken"
            let expectedURL = URL(string: "https://api-test.lifeisskill.cz/v1.0/usercategory")!
            let mockResponse = APIResponse(data: UserCategoryData.mock())
            networkMock.responseToReturn = mockResponse
            
            // Act
            _ = try await service.userCategories(userToken: userToken)
            
            // Assert
            XCTAssertEqual(networkMock.capturedMethod, .GET, "HTTP method should be GET")
            XCTAssertEqual(networkMock.capturedURL, expectedURL, "The URL should match the user category endpoint")
            XCTAssertEqual(networkMock.capturedHeaders?["Authorization"], APIHeader.authorizationHeader["Authorization"])
            XCTAssertEqual(networkMock.capturedHeaders?["Api-Key"], APIHeader.apiKeyHeader["Api-Key"])
            XCTAssertEqual(networkMock.capturedHeaders?["User-Token"], userToken, "The User-Token header should match the provided token")
            XCTAssertNil(networkMock.capturedBody, "The request body should be nil")
        } catch {
            XCTFail("Unexpected error thrown: \(error)")
        }
    }
    
    func testUserRanksCallsAPIWithCorrectRequest() async throws {
        do {
            // Arrange
            let userToken = "mockToken"
            let expectedURL = URL(string: "https://api-test.lifeisskill.cz/v1.0/rank")!
            let mockResponse = APIResponse(data: UserRankData.mock())
            networkMock.responseToReturn = mockResponse
            
            // Act
            _ = try await service.userRanks(userToken: userToken)
            
            // Assert
            XCTAssertEqual(networkMock.capturedMethod, .GET, "HTTP method should be GET")
            XCTAssertEqual(networkMock.capturedURL, expectedURL, "The URL should match the user ranks endpoint")
            XCTAssertEqual(networkMock.capturedHeaders?["Authorization"], APIHeader.authorizationHeader["Authorization"])
            XCTAssertEqual(networkMock.capturedHeaders?["Api-Key"], APIHeader.apiKeyHeader["Api-Key"])
            XCTAssertEqual(networkMock.capturedHeaders?["User-Token"], userToken, "The User-Token header should match the provided token")
            XCTAssertNil(networkMock.capturedBody, "The request body should be nil")
        } catch {
            XCTFail("Unexpected error thrown: \(error)")
        }
    }
    
    func testGenericPointsCallsAPIWithCorrectRequest() async throws {
        do {
            // Arrange
            let userToken = "mockToken"
            let expectedURL = URL(string: "https://api-test.lifeisskill.cz/v1.0/points")!
            let mockResponse = APIResponse(data: GenericPointData.mock())
            networkMock.responseToReturn = mockResponse
            
            // Act
            _ = try await service.genericPoints(userToken: userToken)
            
            // Assert
            XCTAssertEqual(networkMock.capturedMethod, .GET, "HTTP method should be GET")
            XCTAssertEqual(networkMock.capturedURL, expectedURL, "The URL should match the generic points endpoint")
            XCTAssertEqual(networkMock.capturedHeaders?["Authorization"], APIHeader.authorizationHeader["Authorization"])
            XCTAssertEqual(networkMock.capturedHeaders?["Api-Key"], APIHeader.apiKeyHeader["Api-Key"])
            XCTAssertEqual(networkMock.capturedHeaders?["User-Token"], userToken, "The User-Token header should match the provided token")
            XCTAssertNil(networkMock.capturedBody, "The request body should be nil")
        } catch {
            XCTFail("Unexpected error thrown: \(error)")
        }
    }
    
    func testUpdateUserPointsCallsAPIWithCorrectRequestHeaders() async throws {
        do {
            // Arrange
            let userToken = "mockToken"
            let scannedPoint = ScannedPoint.mock()
            let expectedURL = URL(string: "https://api-test.lifeisskill.cz/v1.0/userpoints")!
            let mockResponse = APIResponse(data: UserPointData.mock())
            networkMock.responseToReturn = mockResponse
            
            // Act
            _ = try await service.updateUserPoints(userToken: userToken, point: scannedPoint)
            
            // Assert
            XCTAssertEqual(networkMock.capturedMethod, .POST, "HTTP method should be POST")
            XCTAssertEqual(networkMock.capturedURL, expectedURL, "The URL should match the update user points endpoint")
            XCTAssertEqual(networkMock.capturedHeaders?["Authorization"], APIHeader.authorizationHeader["Authorization"])
            XCTAssertEqual(networkMock.capturedHeaders?["Api-Key"], APIHeader.apiKeyHeader["Api-Key"])
            XCTAssertEqual(networkMock.capturedHeaders?["User-Token"], userToken, "The User-Token header should match the provided token")
        } catch {
            XCTFail("Unexpected error thrown: \(error)")
        }
    }
    
    func testUpdateUserPointsCallsAPIWithCorrectRequestBody() async throws {
        do {
            // Arrange
            let userToken = "mockToken"
            let scannedPoint = ScannedPoint.mock()  // Using the mock function for ScannedPoint
            let expectedTask = "userPoints"
            
            // Mock response
            let mockResponse = APIResponse(data: UserPointData.mock())
            networkMock.responseToReturn = mockResponse
            
            // Act
            _ = try await service.updateUserPoints(userToken: userToken, point: scannedPoint)
            
            // Assert: Parse the captured body as JSON and verify it contains the expected keys and values
            guard let capturedBody = networkMock.capturedBody,
                  let bodyDict = try JSONSerialization.jsonObject(with: capturedBody, options: []) as? [String: Any] else {
                XCTFail("Captured body is not valid JSON")
                return
            }
            
            // Check that required keys exist
            XCTAssertEqual(bodyDict["task"] as? String, expectedTask, "The task should be 'userPoints'")
            XCTAssertEqual(bodyDict["code"] as? String, scannedPoint.code, "The code should match the ScannedPoint's code")
            XCTAssertEqual(bodyDict["codeSource"] as? String, scannedPoint.codeSource.rawValue, "The codeSource should match the ScannedPoint's codeSource")
            
            // Location-related checks
            if let location = scannedPoint.location {
                XCTAssertEqual(bodyDict["lat"] as? String, "\(location.latitude)", "Latitude should match the location's latitude")
                XCTAssertEqual(bodyDict["lng"] as? String, "\(location.longitude)", "Longitude should match the location's longitude")
                XCTAssertEqual(bodyDict["acc"] as? String, "\(location.accuracy)", "Accuracy should match the location's accuracy")
                XCTAssertEqual(bodyDict["alt"] as? String, "\(location.altitude)", "Altitude should match the location's altitude")
                
                // Format the timestamp into the required format
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                let expectedTime = dateFormatter.string(from: location.timestamp)
                XCTAssertEqual(bodyDict["time"] as? String, expectedTime, "Time should match the location's timestamp in the correct format")
            } else {
                XCTFail("Location is nil, but it should not be")
            }
            
            // Check that appId and appVer keys exist
            XCTAssertNotNil(bodyDict["appId"], "The appId key should exist")
            XCTAssertNotNil(bodyDict["appVer"], "The appVer key should exist")
            
        } catch {
            XCTFail("Unexpected error thrown: \(error)")
        }
    }
    
    func testSponsorImageCallsAPIWithCorrectRequest() async throws {
        do {
            // Arrange
            let userToken = "mockToken"
            let sponsorId = "sponsor123"
            let width = 300
            let height = 200
            let expectedURL = URL(string: "https://api-test.lifeisskill.cz/v1.0/files?type=partners&partnerId=\(sponsorId)&width=\(width)&height=\(height)")!
            let mockResponse = Data() // Assuming it's an image data
            networkMock.responseToReturn = mockResponse
            
            // Act
            _ = try await service.sponsorImage(userToken: userToken, sponsorId: sponsorId, width: width, height: height)
            
            // Assert
            XCTAssertEqual(networkMock.capturedMethod, .GET, "HTTP method should be GET")
            XCTAssertEqual(networkMock.capturedURL, expectedURL, "The URL should match the sponsor image endpoint")
            XCTAssertEqual(networkMock.capturedHeaders?["Authorization"], APIHeader.authorizationHeader["Authorization"])
            XCTAssertEqual(networkMock.capturedHeaders?["Api-Key"], APIHeader.apiKeyHeader["Api-Key"])
            XCTAssertEqual(networkMock.capturedHeaders?["User-Token"], userToken, "The User-Token header should match the provided token")
            XCTAssertNil(networkMock.capturedBody, "The request body should be nil for a GET request")
        } catch {
            XCTFail("Unexpected error thrown: \(error)")
        }
    }
}

// MARK: - Testing that each protocol func returns expected data upon successful call

extension UserDataAPIServiceTests {
    
    func testUserPointsReturnsExpectedData() async throws {
        do {
            // Arrange
            let userToken = "mockToken"
            let mockAPIResponse = UserPointData.mock()
            let mockResponse = APIResponse(data: mockAPIResponse)
            networkMock.responseToReturn = mockResponse
            
            // Act
            let response: APIResponse<UserPointData> = try await service.userPoints(userToken: userToken)
            
            // Assert
            XCTAssertEqual(response.data.checkSum, mockAPIResponse.checkSum, "The checkSum should match the mock data")
            XCTAssertEqual(response.data.data.count, mockAPIResponse.data.count, "The data count should match the mock data")
        } catch {
            XCTFail("Unexpected error thrown: \(error)")
        }
    }
    
    func testUserCategoriesReturnsExpectedData() async throws {
        do {
            // Arrange
            let userToken = "mockToken"
            let mockAPIResponse = UserCategoryData.mock()
            let mockResponse = APIResponse(data: mockAPIResponse)
            networkMock.responseToReturn = mockResponse
            
            // Act
            let response: APIResponse<UserCategoryData> = try await service.userCategories(userToken: userToken)
            
            // Assert
            XCTAssertEqual(response.data.main.id, mockAPIResponse.main.id, "The main category ID should match the mock data")
            XCTAssertEqual(response.data.data.count, mockAPIResponse.data.count, "The data count should match the mock data")
        } catch {
            XCTFail("Unexpected error thrown: \(error)")
        }
    }
    
    func testUserRanksReturnsExpectedData() async throws {
        do {
            // Arrange
            let userToken = "mockToken"
            let mockAPIResponse = UserRankData.mock()
            let mockResponse = APIResponse(data: mockAPIResponse)
            networkMock.responseToReturn = mockResponse
            
            // Act
            let response: APIResponse<UserRankData> = try await service.userRanks(userToken: userToken)
            
            // Assert
            XCTAssertEqual(response.data.checkSum, mockAPIResponse.checkSum, "The checkSum should match the mock data")
            XCTAssertEqual(response.data.data.count, mockAPIResponse.data.count, "The data count should match the mock data")
        } catch {
            XCTFail("Unexpected error thrown: \(error)")
        }
    }
    
    func testGenericPointsReturnsExpectedData() async throws {
        do {
            // Arrange
            let userToken = "mockToken"
            let mockAPIResponse = GenericPointData.mock()
            let mockResponse = APIResponse(data: mockAPIResponse)
            networkMock.responseToReturn = mockResponse
            
            // Act
            let response: APIResponse<GenericPointData> = try await service.genericPoints(userToken: userToken)
            
            // Assert
            XCTAssertEqual(response.data.checkSum, mockAPIResponse.checkSum, "The checkSum should match the mock data")
            XCTAssertEqual(response.data.data.count, mockAPIResponse.data.count, "The data count should match the mock data")
        } catch {
            XCTFail("Unexpected error thrown: \(error)")
        }
    }
    
    func testUpdateUserPointsReturnsExpectedData() async throws {
        do {
            // Arrange
            let userToken = "mockToken"
            let scannedPoint = ScannedPoint.mock()
            let mockAPIResponse = UserPointData.mock()
            let mockResponse = APIResponse(data: mockAPIResponse)
            networkMock.responseToReturn = mockResponse
            
            // Act
            let response: APIResponse<UserPointData> = try await service.updateUserPoints(userToken: userToken, point: scannedPoint)
            
            // Assert
            XCTAssertEqual(response.data.checkSum, mockAPIResponse.checkSum, "The checkSum should match the mock data")
            XCTAssertEqual(response.data.data.count, mockAPIResponse.data.count, "The data count should match the mock data")
        } catch {
            XCTFail("Unexpected error thrown: \(error)")
        }
    }
    
    func testSponsorImageReturnsExpectedData() async throws {
        do {
            // Arrange
            let userToken = "mockToken"
            let sponsorId = "sponsor123"
            let width = 300
            let height = 200
            let mockResponse = Data(count: 100)  // Mocking image data
            networkMock.responseToReturn = mockResponse
            
            // Act
            let response: Data = try await service.sponsorImage(userToken: userToken, sponsorId: sponsorId, width: width, height: height)
            
            // Assert
            XCTAssertEqual(response.count, mockResponse.count, "The returned image data should match the mock data")
        } catch {
            XCTFail("Unexpected error thrown: \(error)")
        }
    }
}

// MARK: - Testing that each protocol func propagates errors

extension UserDataAPIServiceTests {
    
    func testUserPointsPropagatesNetworkError() async throws {
        // Arrange: Simulate a network error
        networkMock.errorToThrow = BaseError(
            context: .network,
            message: "Test network error",
            code: .networking(.unknown),
            logger: loggerMock
        )
        
        // Act & Assert
        do {
            let _: APIResponse<UserPointData> = try await service.userPoints(userToken: "mockToken")
            XCTFail("Expected an error to be thrown, but none was thrown")
        } catch let error as BaseError {
            XCTAssertEqual(error.message, "Test network error", "The error message should match")
            XCTAssertEqual(error.code, ErrorCodes.networking(.unknown).code, "The error code should match")
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }
    
    func testUserCategoriesPropagatesNetworkError() async throws {
        // Arrange: Simulate a network error
        networkMock.errorToThrow = BaseError(
            context: .network,
            message: "Test network error",
            code: .networking(.unknown),
            logger: loggerMock
        )
        
        // Act & Assert
        do {
            let _: APIResponse<UserCategoryData> = try await service.userCategories(userToken: "mockToken")
            XCTFail("Expected an error to be thrown, but none was thrown")
        } catch let error as BaseError {
            XCTAssertEqual(error.message, "Test network error", "The error message should match")
            XCTAssertEqual(error.code, ErrorCodes.networking(.unknown).code, "The error code should match")
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }
    
    func testUserRanksPropagatesNetworkError() async throws {
        // Arrange: Simulate a network error
        networkMock.errorToThrow = BaseError(
            context: .network,
            message: "Test network error",
            code: .networking(.unknown),
            logger: loggerMock
        )
        
        // Act & Assert
        do {
            let _: APIResponse<UserRankData> = try await service.userRanks(userToken: "mockToken")
            XCTFail("Expected an error to be thrown, but none was thrown")
        } catch let error as BaseError {
            XCTAssertEqual(error.message, "Test network error", "The error message should match")
            XCTAssertEqual(error.code, ErrorCodes.networking(.unknown).code, "The error code should match")
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }
    
    func testGenericPointsPropagatesNetworkError() async throws {
        // Arrange: Simulate a network error
        networkMock.errorToThrow = BaseError(
            context: .network,
            message: "Test network error",
            code: .networking(.unknown),
            logger: loggerMock
        )
        
        // Act & Assert
        do {
            let _: APIResponse<GenericPointData> = try await service.genericPoints(userToken: "mockToken")
            XCTFail("Expected an error to be thrown, but none was thrown")
        } catch let error as BaseError {
            XCTAssertEqual(error.message, "Test network error", "The error message should match")
            XCTAssertEqual(error.code, ErrorCodes.networking(.unknown).code, "The error code should match")
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }
    
    func testUpdateUserPointsPropagatesNetworkError() async throws {
        // Arrange: Simulate a network error
        networkMock.errorToThrow = BaseError(
            context: .network,
            message: "Test network error",
            code: .networking(.unknown),
            logger: loggerMock
        )
        
        // Act & Assert
        do {
            let scannedPoint = ScannedPoint.mock()
            let _: APIResponse<UserPointData> = try await service.updateUserPoints(userToken: "mockToken", point: scannedPoint)
            XCTFail("Expected an error to be thrown, but none was thrown")
        } catch let error as BaseError {
            XCTAssertEqual(error.message, "Test network error", "The error message should match")
            XCTAssertEqual(error.code, ErrorCodes.networking(.unknown).code, "The error code should match")
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }
    
    func testSponsorImagePropagatesNetworkError() async throws {
        // Arrange: Simulate a network error
        networkMock.errorToThrow = BaseError(
            context: .network,
            message: "Test network error",
            code: .networking(.unknown),
            logger: loggerMock
        )
        
        // Act & Assert
        do {
            let _: Data = try await service.sponsorImage(userToken: "mockToken", sponsorId: "sponsor123", width: 300, height: 200)
            XCTFail("Expected an error to be thrown, but none was thrown")
        } catch let error as BaseError {
            XCTAssertEqual(error.message, "Test network error", "The error message should match")
            XCTAssertEqual(error.code, ErrorCodes.networking(.unknown).code, "The error code should match")
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }
}
