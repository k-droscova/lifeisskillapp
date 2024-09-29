//
//  URLSessionWrapperMock.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 28.09.2024.
//

import Foundation
@testable import lifeisskillapp

final class URLSessionMock: URLSessionWrapping {
    var dataToReturn: Data?
    var responseToReturn: URLResponse?
    var errorToThrow: Error?
    var capturedRequest: URLRequest?  // Capture the request passed to `data(for:)`

    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        capturedRequest = request

        if let error = errorToThrow {
            throw error
        }

        let data = dataToReturn ?? Data()
        let response = responseToReturn ?? HTTPURLResponse(
            url: request.url!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )!

        return (data, response)
    }
}
