//
//  Network.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 01.07.2024.
//

import Foundation

protocol HasNetwork {
    var network: Networking { get }
}

protocol Networking {
    func performRequest(
        url: URL,
        httpMethod: Network.HTTPMethod,
        headers: [String: String]
    ) async throws -> Data
}

final class Network: Networking {
    static let acceptJSONHeader = ["accept": "application/json"]
        
    func performRequest(
        url: URL,
        httpMethod: HTTPMethod,
        headers: [String: String]
    ) async throws -> Data {
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = httpMethod.rawValue
        urlRequest.allHTTPHeaderFields = headers.merging(
            Network.acceptJSONHeader,
            uniquingKeysWith: { current, _ in current }
        )
        
        print(
            "⬆️ "
            + url.absoluteString
        )
        
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        let httpResponse = response as? HTTPURLResponse
        
        print(
            "⬇️ "
            + "[\(httpResponse?.statusCode ?? -1)]: " + url.absoluteString
        )
        
        return data
    }
    
}

extension Network {
    enum HTTPMethod: String {
        case GET, POST, PUT, DELETE, PATCH
    }
}
