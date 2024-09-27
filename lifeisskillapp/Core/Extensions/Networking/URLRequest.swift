//
//  URLRequest.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 05.07.2024.
//

import Foundation

extension URLRequest {
    func toString(sensitiveData: Bool) -> String {
        // Create a basic description of the request
        var description = "URL: \(self.url?.absoluteString ?? "Unknown URL")\n"
        description += "HTTP Method: \(self.httpMethod ?? "Unknown HTTP Method")\n"
        
        if !sensitiveData {
            if let headers = self.allHTTPHeaderFields {
                description += "Headers: \(headers)\n"
            }
            
            if let body = self.httpBody, let bodyString = String(data: body, encoding: .utf8) {
                description += "Body: \(bodyString)\n"
            }
        } else {
            description += "Headers: Hidden-SensitiveData\n"
            description += "Body: Hidden-SensitiveData\n"
        }
        
        return description
    }
    
    func description(sensitiveData: Bool) -> [String: String] {
        ["URLRequest": toString(sensitiveData: sensitiveData)]
    }
}
