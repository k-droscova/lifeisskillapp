//
//  CodingContainer.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 09.09.2024.
//

import Foundation

extension KeyedDecodingContainer {
    /// Decodes a string value and returns nil if the string is empty or absent.
    func decodeNonEmptyString(forKey key: K) throws -> String? {
        let value = try decodeIfPresent(String.self, forKey: key)
        return value?.isEmpty == true ? nil : value
    }
}

extension KeyedEncodingContainer {
    /// Encodes a value only if it is present (not nil).
    mutating func encodeIfPresent<T: Encodable>(_ value: T?, forKey key: K) throws {
        if let value = value {
            try encode(value, forKey: key)
        }
    }
}
