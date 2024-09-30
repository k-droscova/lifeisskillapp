//
//  KeychainHelperMock.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 30.09.2024.
//

import Foundation
@testable import lifeisskillapp

final class KeychainHelperMock: KeychainHelping {
    var savedData: [String: Data] = [:]
    
    // Control error throwing behavior
    var shouldThrowError: Bool = false
    var shouldThrowErrorOnUsername: Bool = false
    var shouldThrowErrorOnPassword: Bool = false
    var thrownError: Error?
    
    var logger: LoggerServicing = LoggingServiceMock()
    
    func save(key: String, data: Data) throws {
        if shouldThrowErrorForKey(key) {
            if let error = thrownError {
                throw error
            } else {
                throw BaseError(context: .database, message: "Failed to save data for key \(key)", logger: logger)
            }
        }
        savedData[key] = data
    }
    
    func load(key: String) throws -> Data {
        if shouldThrowErrorForKey(key) {
            if let error = thrownError {
                throw error
            } else {
                throw BaseError(context: .database, message: "Failed to load data for key \(key)", logger: logger)
            }
        }
        guard let data = savedData[key] else {
            throw BaseError(context: .database, message: "Data not found for key \(key)", logger: logger)
        }
        return data
    }
    
    func delete(key: String) throws {
        if shouldThrowErrorForKey(key) {
            if let error = thrownError {
                throw error
            } else {
                throw BaseError(context: .database, message: "Failed to delete data for key \(key)", logger: logger)
            }
        }
        savedData.removeValue(forKey: key)
    }
    
    // Helper function to determine if an error should be thrown based on the key
    private func shouldThrowErrorForKey(_ key: String) -> Bool {
        if shouldThrowError {
            return true
        }
        
        // Check for specific conditions for username and password keys
        if key == KeychainConstants.usernameKey && shouldThrowErrorOnUsername {
            return true
        }
        
        if key == KeychainConstants.passwordKey && shouldThrowErrorOnPassword {
            return true
        }
        
        return false
    }
}
