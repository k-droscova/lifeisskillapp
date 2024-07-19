//
//  APIResponseError.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 04.07.2024.
//

import Foundation

public protocol APIResponseErroring: Codable, Error {
    var message: String { get }
}

public class APIResponseError: APIResponseErroring {
    public let message: String
    
    enum CodingKeys: String, CodingKey {
        case message = "err_msg"
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.message = try container.decode(String.self, forKey: .message)
    }
}
