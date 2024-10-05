//
//  ForgotPasswordAPITests.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 29.09.2024.
//

import XCTest
@testable import lifeisskillapp

final class ForgotPasswordAPIServiceTests: XCTestCase {

    private struct Dependencies: ForgotPasswordAPIService.Dependencies {
        let network: Networking
        let logger: LoggerServicing
    }

    var networkMock: NetworkingMock!
    var loggerMock: LoggerServicing!
    var service: ForgotPasswordAPIServicing!

    override func setUpWithError() throws {
        networkMock = NetworkingMock()
        loggerMock = LoggingServiceMock()  // Assuming you have this mock set up
        let dependencies = Dependencies(network: networkMock, logger: loggerMock)
        service = ForgotPasswordAPIService(dependencies: dependencies)
    }

    override func tearDownWithError() throws {
        networkMock = nil
        loggerMock = nil
        service = nil
    }
}

// MARK: - Testing that each protocol func calls API with correct request

extension ForgotPasswordAPIServiceTests {
    
    func testFetchPinCallsAPIWithCorrectRequest() async throws {
        do {
            // Arrange
            let username = "mockUsername"
            let expectedURL = URL(string: "https://api-test.lifeisskill.cz/v1.0/pswd/?user=\(username)")!
            let mockResponse = APIResponse(data: ForgotPasswordData.mock())
            networkMock.responseToReturn = mockResponse
            
            // Act
            _ = try await service.fetchPin(username: username)
            
            // Assert
            XCTAssertEqual(networkMock.capturedMethod, .GET, "HTTP method should be GET")
            XCTAssertEqual(networkMock.capturedURL, expectedURL, "The URL should match the reset password endpoint with the username")
            
            // Assert headers: Authorization and Api-Key must be present, User-Token must be absent
            XCTAssertEqual(networkMock.capturedHeaders?["Authorization"], APIHeader.authorizationHeader["Authorization"], "Authorization header should be present")
            XCTAssertEqual(networkMock.capturedHeaders?["Api-Key"], APIHeader.apiKeyHeader["Api-Key"], "API-Key header should be present")
            XCTAssertNil(networkMock.capturedHeaders?["User-Token"], "User-Token header should not be present")
            
            // Assert body is nil
            XCTAssertNil(networkMock.capturedBody, "The request body should be nil for a GET request")
        } catch {
            XCTFail("Unexpected error thrown: \(error)")
        }
    }
    
    func testSetNewPasswordCallsAPIWithCorrectRequestHeaders() async throws {
        do {
            // Arrange
            let credentials = ForgotPasswordCredentials.mock() // Mock credentials
            let expectedURL = URL(string: "https://api-test.lifeisskill.cz/v1.0/pswd")! // Correct URL
            let mockResponse = APIResponse(data: ForgotPasswordConfirmation.mock()) // Mock response
            networkMock.responseToReturn = mockResponse
            
            // Act
            _ = try await service.setNewPassword(credentials: credentials)
            
            // Assert
            XCTAssertEqual(networkMock.capturedMethod, .PUT, "HTTP method should be PUT")
            XCTAssertEqual(networkMock.capturedURL, expectedURL, "The URL should match the reset password confirmation endpoint")
            
            // Assert headers: Authorization and Api-Key must be present, no User-Token
            XCTAssertEqual(networkMock.capturedHeaders?["Authorization"], APIHeader.authorizationHeader["Authorization"], "Authorization header should be present")
            XCTAssertEqual(networkMock.capturedHeaders?["Api-Key"], APIHeader.apiKeyHeader["Api-Key"], "API-Key header should be present")
            XCTAssertNil(networkMock.capturedHeaders?["User-Token"], "User-Token header should not be present")
            
        } catch {
            XCTFail("Unexpected error thrown: \(error)")
        }
    }
    
    func testSetNewPasswordCallsAPIWithCorrectRequestBody() async throws {
        do {
            // Arrange
            let credentials = ForgotPasswordCredentials.mock(
                email: "uzivatelPepa%40itonline.biz",
                newPassword: "HESLO555",
                pin: "919880"
            )
            let mockResponse = APIResponse(data: ForgotPasswordConfirmation.mock()) // Mock response
            networkMock.responseToReturn = mockResponse

            // Act
            _ = try await service.setNewPassword(credentials: credentials)
            
            // Assert
            guard let capturedBody = networkMock.capturedBody,
                  let bodyDict = try JSONSerialization.jsonObject(with: capturedBody, options: []) as? [String: Any] else {
                XCTFail("Captured body is not valid JSON")
                return
            }

            // Check the keys and values in the body
            XCTAssertEqual(bodyDict["task"] as? String, "renewPswd", "The task should be 'renewPswd'")
            XCTAssertEqual(bodyDict["pin"] as? String, credentials.pin, "The pin should match the provided credentials")
            XCTAssertEqual(bodyDict["newPswd"] as? String, credentials.newPassword, "The new password should match the provided credentials")
            XCTAssertEqual(bodyDict["email"] as? String, credentials.email, "The email should match the provided credentials")
            
        } catch {
            XCTFail("Unexpected error thrown: \(error)")
        }
    }
}

// MARK: - Testing that each protocol func returns expected data upon successful call

extension ForgotPasswordAPIServiceTests {
    
    func testFetchPinReturnsExpectedData() async throws {
        do {
            // Arrange
            let username = "mockUsername"
            let mockAPIResponse = ForgotPasswordData.mock(pin: "123456", message: "PIN sent", userEmail: "test@example.com")
            let mockResponse = APIResponse(data: mockAPIResponse)
            networkMock.responseToReturn = mockResponse
            
            // Act
            let response: APIResponse<ForgotPasswordData> = try await service.fetchPin(username: username)
            
            // Assert
            XCTAssertEqual(response.data.pin, mockAPIResponse.pin, "The PIN should match the mock data")
            XCTAssertEqual(response.data.message, mockAPIResponse.message, "The message should match the mock data")
            XCTAssertEqual(response.data.userEmail, mockAPIResponse.userEmail, "The user email should match the mock data")
        } catch {
            XCTFail("Unexpected error thrown: \(error)")
        }
    }
    
    func testSetNewPasswordReturnsExpectedData() async throws {
        do {
            // Arrange
            let credentials = ForgotPasswordCredentials.mock(email: "uzivatelPepa%40itonline.biz", newPassword: "HESLO555", pin: "919880")
            let mockAPIResponse = ForgotPasswordConfirmation.mock(message: true) // Mock success response
            let mockResponse = APIResponse(data: mockAPIResponse)
            networkMock.responseToReturn = mockResponse
            
            // Act
            let response: APIResponse<ForgotPasswordConfirmation> = try await service.setNewPassword(credentials: credentials)
            
            // Assert
            XCTAssertEqual(response.data.message, mockAPIResponse.message, "The confirmation message should match the mock data")
        } catch {
            XCTFail("Unexpected error thrown: \(error)")
        }
    }
}

// MARK: - Testing that each protocol func propagates errors

extension ForgotPasswordAPIServiceTests {

    func testFetchPinPropagatesNetworkError() async throws {
        // Arrange: Simulate a network error
        networkMock.errorToThrow = BaseError(
            context: .network,
            message: "Test network error",
            code: .networking(.unknown),
            logger: loggerMock
        )
        
        // Act & Assert
        do {
            let _: APIResponse<ForgotPasswordData> = try await service.fetchPin(username: "mockUsername")
            XCTFail("Expected an error to be thrown, but none was thrown")
        } catch let error as BaseError {
            XCTAssertEqual(error.message, "Test network error", "The error message should match")
            XCTAssertEqual(error.code, ErrorCodes.networking(.unknown).code, "The error code should match")
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }

    func testSetNewPasswordPropagatesNetworkError() async throws {
        // Arrange: Simulate a network error
        networkMock.errorToThrow = BaseError(
            context: .network,
            message: "Test network error",
            code: .networking(.unknown),
            logger: loggerMock
        )
        
        // Act & Assert
        do {
            let credentials = ForgotPasswordCredentials.mock()
            let _: APIResponse<ForgotPasswordConfirmation> = try await service.setNewPassword(credentials: credentials)
            XCTFail("Expected an error to be thrown, but none was thrown")
        } catch let error as BaseError {
            XCTAssertEqual(error.message, "Test network error", "The error message should match")
            XCTAssertEqual(error.code, ErrorCodes.networking(.unknown).code, "The error code should match")
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }
}
