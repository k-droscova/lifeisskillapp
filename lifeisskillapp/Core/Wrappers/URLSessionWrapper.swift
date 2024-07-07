//
//  URLSessionWrapper.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 05.07.2024.
//

import Foundation

public protocol HasUrlSessionWrapper {
    var urlSession: URLSessionWrapping { get }
}

public protocol URLSessionWrapping {
    func data(
        for request: URLRequest
    ) async throws -> (Data, URLResponse)
}

public final class URLSessionWrapper: URLSessionWrapping {
    public func data(
        for request: URLRequest
    ) async throws -> (Data, URLResponse) {
        try await URLSession.shared.data(for: request)
    }
}
