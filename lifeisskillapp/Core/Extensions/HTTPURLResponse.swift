//
//  HTTPUrlResponse.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 05.07.2024.
//

import Foundation

extension HTTPURLResponse {
    func toString(sensitiveData: Bool) -> String {
        var description = "Status Code: \(self.statusCode)\n"
        // Create a basic description of the request
        if !sensitiveData {
            description += "Headers: \(self.allHeaderFields)\n"
        } else {
            description += "Headers: Hidden-SensitiveData\n"
        }
        return description
    }
    func description(sensitiveData: Bool) -> [String: String] {
        ["HTTPUrlResponse": toString(sensitiveData: sensitiveData)]
    }
}

extension HTTPURLResponse {
    var status: HTTPStatusCode? {
        HTTPStatusCode(rawValue: statusCode)
    }
}
