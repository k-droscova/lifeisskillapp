//
//  RequestResponse.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 05.07.2024.
//

import Foundation

struct EmptyResponse: Decodable {}

struct RequestResponse<Value> {
    let statusCode: Int
    let request: URLRequest?
    let response: HTTPURLResponse?
    let data: Value?
    
    var headers: [String: String] { return response?.allHeaderFields as? [String: String] ?? [:] }
    
    init(
        statusCode: Int,
        request: URLRequest?,
        response: HTTPURLResponse?,
        data: Value? = nil
    ) {
        self.statusCode = statusCode
        self.request = request
        self.response = response
        self.data = data
    }
}


extension RequestResponse where Value == Data {
    func formatBody() -> String {
        if let body = data {
            if let json = try? JSONSerialization.jsonObject(with: body, options: .mutableContainers),
               let pretty = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted),
               let string = String(data: pretty, encoding: String.Encoding.utf8) {
                return string
            } else if let string = String(data: body, encoding: String.Encoding.utf8) {
                return string
            } else {
                return body.description
            }
        } else {
            return "nil"
        }
    }
    /// String description of Request Response
    func toString(sensitiveData: Bool) -> String {
        var dictionary = [
            "statusCode": statusCode.description,
            "request": (request?.toString(sensitiveData: sensitiveData)).emptyIfNil,
            "response": (response?.toString()).emptyIfNil
        ]
        
        var bodyDataString = ""
#if RELEASE
        bodyDataString = sensitiveData ? "Hidden-SensitiveData" : formatBody()
#else
        bodyDataString = formatBody()
#endif
        
        dictionary["Data"] = bodyDataString
        return dictionary.description
    }
    
    /// Dictionary description that is used for BaseError purposes
    func description(sensitiveData: Bool) -> [String: String] {
        ["DataResponse": toString(sensitiveData: sensitiveData)]
    }
}
