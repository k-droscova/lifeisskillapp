//
//  NetworkTests.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 28.09.2024.
//

import XCTest
@testable import lifeisskillapp
import Network

final class NetworkTests: XCTestCase {
    
    // Dependencies struct for the Network class
    private struct Dependencies: Network.Dependencies {
        let logger: LoggerServicing
        let urlSession: URLSessionWrapping
    }
    
    private struct MockDecodableResponse: Decodable {
        let id: Int
        let name: String
    }
    
    private struct APIErrorMock: APIResponseErroring {
        let message: String
    }
    
    var logger: LoggerServicing!
    var urlSessionMock: URLSessionMock!
    var network: Networking!
    
    // Setup runs before each test
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        logger = LoggingServiceMock()
        urlSessionMock = URLSessionMock()
        
        let dependencies = Dependencies(
            logger: logger,
            urlSession: urlSessionMock
        )
        network = Network(dependencies: dependencies)
    }
    
    // Cleanup runs after each test
    override func tearDownWithError() throws {
        logger = nil
        urlSessionMock = nil
        network = nil
        try super.tearDownWithError()
    }
    
    // Test when the network request succeeds with valid data
    func testPerformRequestReturnsValidResponse() async {
        // Arrange
        let validData = """
        { "id": 1, "name": "Test" }
        """.data(using: .utf8)!
        let testURL = URL(string: "https://example.com")!
        let httpResponse = HTTPURLResponse(url: testURL, statusCode: 200, httpVersion: nil, headerFields: nil)!
        
        urlSessionMock.dataToReturn = validData
        urlSessionMock.responseToReturn = httpResponse
        
        // Act & Assert
        do {
            let response: MockDecodableResponse = try await network.performRequest(
                url: testURL,
                method: .GET,
                headers: nil,
                body: nil,
                sensitiveRequestBodyData: false,
                errorObject: APIErrorMock.self
            )
            XCTAssertEqual(response.id, 1)
            XCTAssertEqual(response.name, "Test")
        } catch {
            XCTFail("Unexpected error thrown: \(error)")
        }
    }
    
    // Test when the request succeeds but decoding fails due to invalid data
    func testPerformRequestThrowsDecodingErrorOnInvalidData() async {
        // Arrange
        let invalidData = "invalid json".data(using: .utf8)!
        let testURL = URL(string: "https://example.com")!
        let httpResponse = HTTPURLResponse(url: testURL, statusCode: 200, httpVersion: nil, headerFields: nil)!
        
        urlSessionMock.dataToReturn = invalidData
        urlSessionMock.responseToReturn = httpResponse
        
        // Act & Assert
        do {
            let _: MockDecodableResponse = try await network.performRequest(
                url: testURL,
                method: .GET,
                headers: nil,
                body: nil,
                sensitiveRequestBodyData: false,
                errorObject: APIErrorMock.self
            )
            XCTFail("Expected BaseError for decoding to be thrown")
        } catch let error as BaseError {
            XCTAssertEqual(error.context, .network)
            XCTAssertEqual(error.code, ErrorCodes.general(.jsonDecoding).code)
            XCTAssertEqual(error.message, "Cannot decode response for URL \(testURL.absoluteString)")
        } catch {
            XCTFail("Unexpected error thrown: \(error)")
        }
    }
    
    // Test when the request returns a network-specific error (URLError)
    func testPerformRequestThrowsBaseErrorForURLError() async {
        // Arrange
        urlSessionMock.errorToThrow = URLError(.timedOut)
        let testURL = URL(string: "https://example.com")!
        
        // Act & Assert
        do {
            let _: MockDecodableResponse = try await network.performRequest(
                url: testURL,
                method: .GET,
                headers: nil,
                body: nil,
                sensitiveRequestBodyData: false,
                errorObject: APIErrorMock.self
            )
            XCTFail("Expected BaseError to be thrown")
        } catch let error as BaseError {
            XCTAssertEqual(error.message, URLError(.timedOut).errorMessage)
            XCTAssertEqual(error.code, ErrorCodes.networking(.timeout).code)
        } catch {
            XCTFail("Unexpected error thrown: \(error)")
        }
    }
    
    // Test when the response has no data but should return Void
    func testPerformRequestHandlesVoidResponse() async {
        // Arrange
        let testURL = URL(string: "https://example.com")!
        let httpResponse = HTTPURLResponse(url: testURL, statusCode: 200, httpVersion: nil, headerFields: nil)!
        
        urlSessionMock.dataToReturn = Data()  // Empty body
        urlSessionMock.responseToReturn = httpResponse
        
        // Act & Assert
        do {
            let _: EmptyResponse = try await network.performRequest(
                url: testURL,
                method: .GET,
                headers: nil,
                body: nil,
                sensitiveRequestBodyData: false,
                errorObject: APIErrorMock.self
            )
            // No asserts necessary, success is enough
        } catch {
            XCTFail("Unexpected error thrown: \(error)")
        }
    }
    
    // Test when the response status code is 404
    func testPerformRequestHandles404Error() async {
        // Arrange
        let testURL = URL(string: "https://example.com")!
        let httpResponse = HTTPURLResponse(url: testURL, statusCode: 404, httpVersion: nil, headerFields: nil)!

        urlSessionMock.dataToReturn = Data()  // Empty body
        urlSessionMock.responseToReturn = httpResponse

        // Act & Assert
        do {
            let _: MockDecodableResponse = try await network.performRequest(
                url: testURL,
                method: .GET,
                headers: nil,
                body: nil,
                sensitiveRequestBodyData: false,
                errorObject: APIErrorMock.self
            )
            XCTFail("Expected BaseError to be thrown")
        } catch let error as BaseError {
            XCTAssertEqual(error.context, .api)
            XCTAssertEqual(error.code, ErrorCodes.networking(.apiDecoding).code)
            XCTAssertEqual(error.message, "Unable to decode message from API: 404")
        } catch {
            XCTFail("Unexpected error thrown: \(error)")
        }
    }
    
    // Test when the response returns a valid Data response but no decoding is required (i.e., T == Data)
    func testPerformRequestReturnsDataResponse() async {
        // Arrange
        let testData = Data([0x01, 0x02, 0x03])
        let testURL = URL(string: "https://example.com")!
        let httpResponse = HTTPURLResponse(url: testURL, statusCode: 200, httpVersion: nil, headerFields: nil)!

        urlSessionMock.dataToReturn = testData
        urlSessionMock.responseToReturn = httpResponse

        // Act & Assert
        do {
            let response: Data = try await network.performRequest(
                url: testURL,
                method: .GET,
                headers: nil,
                body: nil,
                sensitiveRequestBodyData: false,
                errorObject: APIErrorMock.self
            )
            XCTAssertEqual(response, testData)
        } catch {
            XCTFail("Unexpected error thrown: \(error)")
        }
    }

    // Test when an invalid HTTP response is returned (i.e., URLResponse instead of HTTPURLResponse)
    func testPerformRequestThrowsErrorForInvalidHttpResponse() async {
        // Arrange
        let testURL = URL(string: "https://example.com")!
        let invalidResponse = URLResponse(url: testURL, mimeType: nil, expectedContentLength: 0, textEncodingName: nil)

        urlSessionMock.dataToReturn = Data()
        urlSessionMock.responseToReturn = invalidResponse

        // Act & Assert
        do {
            let _: MockDecodableResponse = try await network.performRequest(
                url: testURL,
                method: .GET,
                headers: nil,
                body: nil,
                sensitiveRequestBodyData: false,
                errorObject: APIErrorMock.self
            )
            XCTFail("Expected BaseError to be thrown")
        } catch let error as BaseError {
            XCTAssertEqual(error.message, "Invalid HTTPResponse - \(invalidResponse.debugDescription)")
            XCTAssertEqual(error.code, ErrorCodes.networking(.apiDecoding).code)
        } catch {
            XCTFail("Unexpected error thrown: \(error)")
        }
    }
    
    func testPerformRequestCreatesCorrectURLRequest() async {
        // Arrange
        let testURL = URL(string: "https://example.com/test")!
        let testMethod = Network.HTTPMethod.POST
        let testHeaders = ["Content-Type": "application/json", "Authorization": "Bearer token"]
        let testBody = """
        {
            "name": "Test"
        }
        """.data(using: .utf8)!
        
        urlSessionMock.dataToReturn = Data()
        urlSessionMock.responseToReturn = HTTPURLResponse(url: testURL, statusCode: 200, httpVersion: nil, headerFields: nil)

        // Act
        do {
            let _: EmptyResponse = try await network.performRequest(
                url: testURL,
                method: testMethod,
                headers: testHeaders,
                body: testBody,
                sensitiveRequestBodyData: false,
                errorObject: APIErrorMock.self
            )
            
            // Assert: Verify that the URLRequest passed to URLSession has the correct values
            guard let capturedRequest = urlSessionMock.capturedRequest else {
                XCTFail("No URLRequest was captured by URLSessionMock")
                return
            }

            // Verify the URL
            XCTAssertEqual(capturedRequest.url, testURL)

            // Verify the HTTP Method
            XCTAssertEqual(capturedRequest.httpMethod, testMethod.rawValue)

            // Verify the Headers
            XCTAssertEqual(capturedRequest.allHTTPHeaderFields?["Content-Type"], "application/json")
            XCTAssertEqual(capturedRequest.allHTTPHeaderFields?["Authorization"], "Bearer token")

            // Verify the Body
            XCTAssertEqual(capturedRequest.httpBody, testBody)
            
        } catch {
            XCTFail("Unexpected error thrown: \(error)")
        }
    }
    
    func testPerformAuthorizedRequestWithoutUserToken() async throws {
        // Arrange
        let mockEndpoint = MockEndpoint()
        mockEndpoint.isUserTokenRequired = false  // No user token required
        mockEndpoint.headersToReturn = [:]
        mockEndpoint.urlToReturn = URL(string: "https://example.com/test")!
        
        urlSessionMock.dataToReturn = Data()  // Simulate empty response body
        urlSessionMock.responseToReturn = HTTPURLResponse(url: mockEndpoint.urlToReturn, statusCode: 200, httpVersion: nil, headerFields: nil)

        // Act
        do {
            let _: EmptyResponse = try await network.performAuthorizedRequest(
                endpoint: mockEndpoint,
                method: .GET,
                body: nil,
                sensitiveRequestBodyData: false,
                errorObject: APIErrorMock.self,
                userToken: nil
            )
            
            // Assert: Verify that performRequest was called with the correct headers
            guard let capturedRequest = urlSessionMock.capturedRequest else {
                XCTFail("No URLRequest was captured by URLSessionMock")
                return
            }

            // Verify the Authorization header exists
            XCTAssertTrue(capturedRequest.allHTTPHeaderFields?.keys.contains("Authorization") ?? false)
            XCTAssertTrue(capturedRequest.allHTTPHeaderFields?.keys.contains("Api-Key") ?? false)
            
            // Verify there is no User-Token header
            XCTAssertFalse(capturedRequest.allHTTPHeaderFields?.keys.contains("User-Token") ?? false)
            
            // Verify the URL
            XCTAssertEqual(capturedRequest.url, mockEndpoint.urlToReturn)
            
        } catch {
            XCTFail("Unexpected error thrown: \(error)")
        }
    }
    
    func testPerformAuthorizedRequestWithUserToken() async throws {
        // Arrange
        let mockEndpoint = MockEndpoint()
        mockEndpoint.isUserTokenRequired = true  // User token required
        mockEndpoint.headersToReturn = [:]
        mockEndpoint.urlToReturn = URL(string: "https://example.com/secure")!
        
        let userToken = "user123"
        
        urlSessionMock.dataToReturn = Data()  // Simulate empty response body
        urlSessionMock.responseToReturn = HTTPURLResponse(url: mockEndpoint.urlToReturn, statusCode: 200, httpVersion: nil, headerFields: nil)

        // Act
        do {
            let _: EmptyResponse = try await network.performAuthorizedRequest(
                endpoint: mockEndpoint,
                method: .GET,
                body: nil,
                sensitiveRequestBodyData: false,
                errorObject: APIErrorMock.self,
                userToken: userToken
            )
            
            // Assert: Verify that performRequest was called with the correct headers
            guard let capturedRequest = urlSessionMock.capturedRequest else {
                XCTFail("No URLRequest was captured by URLSessionMock")
                return
            }

            // Verify the Authorization, Api-Key, and User-Token headers exist
            XCTAssertTrue(capturedRequest.allHTTPHeaderFields?.keys.contains("Authorization") ?? false)
            XCTAssertTrue(capturedRequest.allHTTPHeaderFields?.keys.contains("Api-Key") ?? false)
            XCTAssertTrue(capturedRequest.allHTTPHeaderFields?.keys.contains("User-Token") ?? false)
            
            // Verify the User-Token header value matches the provided user token
            XCTAssertEqual(capturedRequest.allHTTPHeaderFields?["User-Token"], userToken)
            
            // Verify the URL
            XCTAssertEqual(capturedRequest.url, mockEndpoint.urlToReturn)
            
        } catch {
            XCTFail("Unexpected error thrown: \(error)")
        }
    }
}
