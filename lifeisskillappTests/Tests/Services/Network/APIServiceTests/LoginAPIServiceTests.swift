//
//  LoginAPIServiceTests.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 28.09.2024.
//

import XCTest
@testable import lifeisskillapp

final class LoginAPIServiceTests: XCTestCase {
    
    // Define a struct for the test dependencies
    private struct Dependencies: LoginAPIService.Dependencies {
        let network: Networking
        let logger: LoggerServicing
    }
    
    var logger: LoggerServicing!
    var networkMock: NetworkingMock!
    var service: LoginAPIServicing!
    
    // Setup runs before each test
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        logger = LoggingServiceMock()  // Use your logger mock here
        networkMock = NetworkingMock() // Create an instance of the mock Networking object
        let dependencies = Dependencies(network: networkMock, logger: logger)
        service = LoginAPIService(dependencies: dependencies)
    }
    
    // Teardown runs after each test
    override func tearDownWithError() throws {
        logger = nil
        networkMock = nil
        service = nil
        try super.tearDownWithError()
    }
    
    // Test that login() throws an error when location is nil
    func testLoginThrowsWhenLocationIsNil() async throws {
        // Arrange
        let credentials = LoginCredentials.mock()
        
        // Act & Assert
        do {
            let _: APIResponse<LoginAPIResponse> = try await service.login(credentials: credentials, location: nil)
            XCTFail("Expected BaseError to be thrown when location is nil")
        } catch let error as BaseError {
            XCTAssertEqual(error.message, "User Location Required for login")
        } catch {
            XCTFail("Unexpected error thrown: \(error)")
        }
    }
    
    func testLoginRequestHasCorrectParameters() async throws {
        do {
            // Arrange
            let credentials = LoginCredentials.mock(username: "testUser", password: "testPass")
            let location = UserLocation.mock()
            let mockAPIResponse = LoginAPIResponse.mock()
            let mockResponse = APIResponse(data: mockAPIResponse)
            
            networkMock.responseToReturn = mockResponse
            
            // Expected body as dictionary without exact values for appId and appVer
            let expectedBody: [String: Any] = [
                "task": "login",
                "user": credentials.username,
                "pswd": credentials.password
            ]
            
            // Act
            _ = try await service.login(credentials: credentials, location: location)
            
            // Assert the network request method and URL
            XCTAssertEqual(networkMock.capturedMethod, .POST, "HTTP method should be POST")
            let expectedURL = URL(string: "https://api-test.lifeisskill.cz/v1.0/login")!
            XCTAssertEqual(networkMock.capturedURL, expectedURL, "The URL should match the login endpoint")
            
            // Assert the headers
            XCTAssertEqual(networkMock.capturedHeaders?["Authorization"], APIHeader.authorizationHeader["Authorization"])
            XCTAssertEqual(networkMock.capturedHeaders?["Api-Key"], APIHeader.apiKeyHeader["Api-Key"])
            XCTAssertNil(networkMock.capturedHeaders?["User-Token"], "There should be no User-Token header for login")
            
            // Parse captured body and expected body into dictionaries
            if let capturedBody = networkMock.capturedBody,
               let capturedBodyDict = try JSONSerialization.jsonObject(with: capturedBody, options: []) as? [String: Any] {
                
                // Verify the relevant fields in the captured body
                for (key, value) in expectedBody {
                    XCTAssertEqual(capturedBodyDict[key] as? String, value as? String, "The \(key) field should match")
                }
                
                // Verify that appId and appVer exist in the captured body (but don't compare their values)
                XCTAssertNotNil(capturedBodyDict["appId"], "The body should contain an appId field")
                XCTAssertNotNil(capturedBodyDict["appVer"], "The body should contain an appVer field")
            } else {
                XCTFail("The captured body is either nil or not valid JSON")
            }
            
        } catch {
            XCTFail("Unexpected error thrown: \(error)")
        }
    }
    
    func testLoginReturnsCorrectResponse() async throws {
        do {
            // Arrange
            let credentials = LoginCredentials.mock(username: "testUser", password: "testPass")
            let location = UserLocation.mock()
            let mockAPIResponse = LoginAPIResponse.mock()
            let mockResponse = APIResponse(data: mockAPIResponse)
            
            networkMock.responseToReturn = mockResponse
            
            // Act
            let response: APIResponse<LoginAPIResponse> = try await service.login(credentials: credentials, location: location)
            
            // Assert: Verify the response
            XCTAssertEqual(response.data.user.token, mockResponse.data.user.token, "The token should match the mock response")
            XCTAssertEqual(response.data.user.userId, mockResponse.data.user.userId, "The user id should match the mock response")
            
        } catch {
            XCTFail("Unexpected error thrown: \(error)")
        }
    }
    
    // Test that signature() calls performAuthorizedRequest with the correct parameters
    func testSignatureCallsPerformRequestWithCorrectParameters() async throws {
        do {
            // Arrange
            let userToken = "mockUserToken"
            let mockAPIResponse = SignatureAPIResponse.mock()
            let mockResponse = APIResponse(data: mockAPIResponse)
            
            networkMock.responseToReturn = mockResponse
            
            // Act
            let _: APIResponse<SignatureAPIResponse> = try await service.signature(userToken: userToken)
            
            // Assert: Verify the network request method and URL
            XCTAssertEqual(networkMock.capturedMethod, .GET, "HTTP method should be GET")
            let expectedURL = URL(string: "https://api-test.lifeisskill.cz/v1.0/signature")!
            XCTAssertEqual(networkMock.capturedURL, expectedURL, "The URL should match the signature endpoint")
            
            // Assert the headers
            XCTAssertEqual(networkMock.capturedHeaders?["Authorization"], APIHeader.authorizationHeader["Authorization"])
            XCTAssertEqual(networkMock.capturedHeaders?["Api-Key"], APIHeader.apiKeyHeader["Api-Key"])
            XCTAssertEqual(networkMock.capturedHeaders?["User-Token"], userToken, "The User-Token header should match the provided token")
            
            // Assert the body is nil
            XCTAssertNil(networkMock.capturedBody, "The body should be nil for a GET request")
            
        } catch {
            XCTFail("Unexpected error thrown: \(error)")
        }
    }
    
    // Test that signature() returns the correct response
    func testSignatureReturnsCorrectResponse() async throws {
        do {
            // Arrange
            let userToken = "mockUserToken"
            let mockAPIResponse = SignatureAPIResponse.mock(signature: "mockSignature")
            let mockResponse = APIResponse(data: mockAPIResponse)
            
            networkMock.responseToReturn = mockResponse
            
            // Act
            let response: APIResponse<SignatureAPIResponse> = try await service.signature(userToken: userToken)
            
            // Assert the response
            XCTAssertEqual(response.data.signature, "mockSignature", "The signature should match the mock response")
            
        } catch {
            XCTFail("Unexpected error thrown: \(error)")
        }
    }
}
