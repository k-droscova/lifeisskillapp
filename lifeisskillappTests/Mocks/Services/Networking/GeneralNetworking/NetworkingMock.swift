//
//  NetworkingMock.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 28.09.2024.
//

import Foundation
@testable import lifeisskillapp

final class NetworkingMock: Networking {
    var capturedURL: URL?
    var capturedMethod: Network.HTTPMethod?
    var capturedHeaders: [String: String]?
    var capturedBody: Data?
    
    var responseToReturn: Any?  // This property will hold the response to return for each test
    var errorToThrow: Error?    // This allows us to simulate errors
    
    // This will mock the response of the performRequest
    func performRequest<T: Decodable, E: APIResponseErroring>(
        url: URL,
        method: Network.HTTPMethod,
        headers: [String: String]?,
        body: Data?,
        sensitiveRequestBodyData: Bool,
        errorObject: E.Type
    ) async throws -> T {
        // Capture the parameters passed to this method
        capturedURL = url
        capturedMethod = method
        capturedHeaders = headers
        capturedBody = body

        // If error is set, throw it
        if let error = errorToThrow {
            throw error
        }
        
        // Return the specified response for the test, if available
        if let response = responseToReturn as? T {
            return response
        }
        
        // Otherwise, throw an error indicating a missing response
        throw NSError(domain: "NetworkingMock", code: -1, userInfo: [NSLocalizedDescriptionKey: "No mock response was set"])
    }
}
