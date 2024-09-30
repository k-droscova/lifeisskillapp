//
//  KeychainHelper.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 13.08.2024.
//

import Foundation
import Security

protocol HasKeychainHelper {
    var keychainHelper: KeychainHelping { get set }
}

protocol KeychainHelping {
    func save(key: String, data: Data) throws
    func load(key: String) throws -> Data
    func delete(key: String) throws
}

final class KeychainHelper: BaseClass, KeychainHelping {
    typealias Dependencies = HasLoggers
    
    private let logger: LoggerServicing
    
    init(dependencies: Dependencies) {
        self.logger = dependencies.logger
    }
    
    func save(key: String, data: Data) throws {
        // Create a query to look up an existing item with the given key.
        let query = [
            kSecClass as String: kSecClassGenericPassword as String,
            kSecAttrAccount as String: key
        ] as [String : Any]
        
        // Prepare the attributes that we would like to update or add.
        let attributesToUpdate = [
            kSecValueData as String: data
        ] as [String : Any]
        
        // Check if an item with the given key already exists in the keychain.
        if SecItemCopyMatching(query as CFDictionary, nil) == errSecSuccess {
            // If the item exists, update its data using SecItemUpdate.
            let status = SecItemUpdate(query as CFDictionary, attributesToUpdate as CFDictionary)
            guard status == errSecSuccess else {
                throw BaseError(
                    context: .database,
                    message: "Failed to update data for key \(key) with status \(status)",
                    logger: logger
                )
            }
        } else {
            // If the item does not exist, add it using SecItemAdd.
            var newItem = query
            newItem[kSecValueData as String] = data
            let status = SecItemAdd(newItem as CFDictionary, nil)
            guard status == errSecSuccess else {
                throw BaseError(
                    context: .database,
                    message: "Failed to save data for key \(key) with status \(status)",
                    logger: logger
                )
            }
        }
    }
    
    func load(key: String) throws -> Data {
        // Create a query to retrieve the item with the given key.
        let query = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: kCFBooleanTrue!,
            kSecMatchLimit as String: kSecMatchLimitOne
        ] as [String : Any]
        
        var dataTypeRef: AnyObject? = nil
        let status: OSStatus = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
        
        // Check if the data was successfully retrieved.
        guard status == errSecSuccess, 
                let data = dataTypeRef as? Data
        else {
            if status == errSecItemNotFound {
                throw BaseError(
                    context: .database,
                    message: "No data found for key \(key).",
                    logger: logger
                )
            } else {
                throw BaseError(
                    context: .database,
                    message: "Failed to load data for key \(key) with status \(status)",
                    logger: logger
                )
            }
        }
        return data
    }
    
    func delete(key: String) throws {
        // Create a query to delete the item with the given key.
        let query = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ] as [String : Any]
        
        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess else {
            throw BaseError(
                context: .database,
                message: "Failed to delete data for key \(key) with status \(status)",
                logger: logger
            )
        }
    }
}
