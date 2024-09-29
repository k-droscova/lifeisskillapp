//
//  APIReponse.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 07.07.2024.
//

import Foundation

// Define a protocol for common data properties
public protocol DataProtocol: Codable {}

// Define the main response structure
struct APIResponse<T: DataProtocol>: Decodable {
    let data: T
    
    init(data: T) {
        self.data = data
    }
}
