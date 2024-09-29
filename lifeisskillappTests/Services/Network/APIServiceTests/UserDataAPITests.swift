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
    var service: UserDataAPIService!
    
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
