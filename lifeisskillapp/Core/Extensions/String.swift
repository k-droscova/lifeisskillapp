//
//  String.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 24.07.2024.
//

import Foundation

extension String {
    // For parsing LiS QR codes for points
    var parsedMessage: String {
        let withoutFront = self.split(separator: "{")
        let withoutBack = withoutFront[1].split(separator: "}")
        return String(withoutBack.first ?? "")
    }
    
    // Computed property for parsing reference information from LiS QR codes
    var reference: ReferenceInfo? {
        // Extract the query part from the URL (everything after "?")
        guard let queryPart = self.split(separator: "?").last else {
            print("No query part found in the QR string")
            return nil
        }
        
        // Split the query part by "&" to get individual key-value pairs
        let pairs = queryPart.split(separator: "&")
        
        var username: String?
        var base64UserId: String?
        
        // Iterate through each pair and split by "=" to get key-value pairs
        for pair in pairs {
            let keyValue = pair.split(separator: "=")
            guard keyValue.count == 2 else { continue } // If it's not a valid key-value pair, skip
            
            let key = String(keyValue[0])
            let value = String(keyValue[1])
            
            switch key {
            case ReferenceQRKeys.username:
                username = value.trimmingCharacters(in: CharacterSet(charactersIn: "{}")) // Remove curly braces
            case ReferenceQRKeys.userId:
                base64UserId = value.trimmingCharacters(in: CharacterSet(charactersIn: "{}")) // Remove curly braces
            default:
                continue
            }
        }
        
        // Ensure we have both username and Base64-encoded user ID
        guard
            let validUsername = username,
            let validBase64UserId = base64UserId,
            let userIdData = Data(base64Encoded: validBase64UserId),
            let userId = String(data: userIdData, encoding: .utf8)
        else {
            return nil
        }
        
        return ReferenceInfo(username: validUsername, userId: userId)
    }
}

extension String {
    var nilIfEmpty: String? {
        isEmpty ? nil : self
    }
}

extension String {
    // for registration forms
    var basicValidationState: BasicValidationState {
        self.isEmpty ? .empty : .valid
    }
}
