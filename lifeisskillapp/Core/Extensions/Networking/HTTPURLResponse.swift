//
//  HTTPUrlResponse.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 05.07.2024.
//

import Foundation

extension HTTPURLResponse {
    func toString() -> String {
        var description = "Status Code: \(self.statusCode)\n"
        // Create a basic description of the request
        description += "Headers: \(self.allHeaderFields)\n"
        return description
    }
    func description() -> [String: String] {
        ["HTTPUrlResponse": toString()]
    }
}

extension HTTPURLResponse {
    var responseType: ResponseType {
        ResponseType(from: statusCode)
    }
    var isErrorResponse: Bool {
        responseType == .clientError || responseType == .serverError
    }
}
