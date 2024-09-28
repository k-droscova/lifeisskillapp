//
//  RegisterAppServiceTests.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 28.09.2024.
//

import XCTest
@testable import lifeisskillapp

final class RegisterAppAPIServiceTests: XCTestCase {

    // Mock dependencies struct for RegisterAppAPIService
    private struct Dependencies: RegisterAppAPIService.Dependencies {
        let network: Networking
        let logger: LoggerServicing
    }

    var logger: LoggerServicing!
    var networkMock: NetworkingMock!
    var service: RegisterAppAPIService!

    // Setup runs before each test
    override func setUpWithError() throws {
        try super.setUpWithError()

        logger = LoggingServiceMock()  // Use your logger mock here
        networkMock = NetworkingMock() // Create an instance of the mock Networking object
        let dependencies = Dependencies(network: networkMock, logger: logger)
        service = RegisterAppAPIService(dependencies: dependencies)
    }

    // Teardown runs after each test
    override func tearDownWithError() throws {
        logger = nil
        networkMock = nil
        service = nil
        try super.tearDownWithError()
    }

    // Test to verify that registerApp() calls performRequest with correct URLRequest properties
    func testRegisterAppCallsPerformRequestWithCorrectProperties() async throws {
        // Arrange
        let mockResponse = APIResponse(data: RegisterAppAPIResponse(appId: "mockAppId", versionCode: 1))
        networkMock.responseToReturn = mockResponse  // Set the mock response to be returned by the mock
        
        // Act: Call registerApp on the service
        let response: APIResponse<RegisterAppAPIResponse> = try await service.registerApp()

        // Assert: Verify that performRequest was called with the correct parameters
        XCTAssertEqual(networkMock.capturedMethod, .GET, "HTTP method should be GET")
        let expectedURL = URL(string: "https://api-test.lifeisskill.cz/v1.0/appid")!
        XCTAssertEqual(networkMock.capturedURL, expectedURL, "The URL should match the app ID endpoint")
        XCTAssertEqual(networkMock.capturedHeaders?["Authorization"], APIHeader.authorizationHeader["Authorization"])
        XCTAssertEqual(networkMock.capturedHeaders?["Api-Key"], APIHeader.apiKeyHeader["Api-Key"])
        XCTAssertNil(networkMock.capturedHeaders?["User-Token"], "There should be no User-Token header")
        XCTAssertNil(networkMock.capturedBody, "The body should be nil for a GET request")

        // Verify the returned response data
        XCTAssertEqual(response.data.appId, "mockAppId", "The appId should be 'mockAppId'")
        XCTAssertEqual(response.data.versionCode, 1, "The versionCode should be 1")
    }

    // Test that ensures error handling when an error is thrown by the network layer
    func testRegisterAppHandlesNetworkError() async throws {
        // Arrange: Simulate an error
        networkMock.errorToThrow = BaseError(
            context: .network,
            message: "Test network error",
            code: .networking(.unknown),
            logger: logger
        )
        
        // Act & Assert
        do {
            let _: APIResponse<RegisterAppAPIResponse> = try await service.registerApp()
            XCTFail("Expected an error to be thrown, but none was thrown")
        } catch let error as BaseError {
            XCTAssertEqual(error.message, "Test network error", "The error message should match")
            XCTAssertEqual(error.code, ErrorCodes.networking(.unknown).code, "The error code should match")
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }
}
