//
//  EndpointMock.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 28.09.2024.
//

import Foundation
@testable import lifeisskillapp

final class MockEndpoint: Endpointing {
    var path: String = "/test"
    var isUserTokenRequired: Bool = false
    var headersToReturn: [String: String] = [:]
    var urlToReturn: URL = URL(string: "https://example.com/test")!
    
    func headers(userToken: String?) -> [String: String] {
        var finalHeaders = headersToReturn
        if let token = userToken {
            finalHeaders.merge(APIHeader.apiTokenHeader(token: token)) { (_, new) in new }
        }
        return finalHeaders
    }
    
    func urlWithPath() throws -> URL {
        urlToReturn
    }
}
