//
//  JsonMapper.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 04.07.2024.
//

import Foundation

public class JsonMapper {
    public static func jsonString<T: Encodable>(from object: T) throws -> String {
        let encoded: Data
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .sortedKeys
            encoded = try encoder.encode(object)
        } catch {
            /*throw BaseError(
                message: "Cannot encode object \(T.self) to JSON",
                code: .general(.jsonEncoding),
                error: error,
                meta: [
                    "rawObject": "\(object)"
                ]
            )
             */
            return ""
        }
        
        guard let jsonString = String(data: encoded, encoding: .utf8) else {
            /*throw BaseError(
                message: "Cannot transform encoded \(T.self) to JSON String",
                code: .general(.jsonEncoding),
                meta: [
                    "rawObject": "\(object)"
                ]
            )*/
            return ""
        }
        
        return jsonString
    }
    
    public static func decodeJsonString<T: Decodable>(jsonString: String) throws -> T {
        do {
            let responseData = Data(jsonString.utf8)
            return try JSONDecoder().decode(T.self, from: responseData)
        } catch {
            /*throw BaseError(
                message: "Cannot decode JSON to object \(T.self)",
                code: .general(.jsonDecoding),
                error: error,
                meta: [
                    "rawJSON": jsonString
                ]
            )
             */
            return NSObject() as! T
        }
    }
    
    public static func serializeJSONToDict(
        jsonString: String
    ) throws -> [String: Any]? {
        try serializeDataToDict(jsonData: jsonString.data(using: .utf8)!)
    }
    
    public static func serialize(
        jsonData: Data
    ) throws -> Data? {
        guard
            let dictionary = try serializeDataToDict(jsonData: jsonData)
        else { return nil }
        return try JSONSerialization.data(
            withJSONObject: dictionary,
            options: .prettyPrinted
        )
    }
    
    public static func serializeDataToDict(
        jsonData: Data
    ) throws -> [String: Any]? {
        guard
            let json = try JSONSerialization.jsonObject(
                with: jsonData,
                options: []
            ) as? [String: Any]
        else { return nil }
        return json
    }
}
