//
//  JsonMapper.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 04.07.2024.
//

import Foundation

class JsonMapper {
    static func jsonString<T: Encodable>(from object: T) throws -> String {
        let encoded: Data
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .sortedKeys
            encoded = try encoder.encode(object)
        } catch {
            throw BaseError(
                context: LogContext.system,
                message: "Cannot encode object \(T.self) to JSON",
                code: .general(.jsonEncoding),
                logger: appDependencies.logger
            )
        }
        
        guard let jsonString = String(data: encoded, encoding: .utf8) else {
            throw BaseError(
                context: LogContext.system,
                message: "Cannot transform encoded \(T.self) to JSON String",
                code: .general(.jsonEncoding),
                logger: appDependencies.logger
            )
        }
        
        return jsonString
    }
}
