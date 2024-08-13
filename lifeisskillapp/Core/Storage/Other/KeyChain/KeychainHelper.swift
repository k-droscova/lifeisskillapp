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
    func save(key: String, data: Data) -> OSStatus
    func load(key: String) -> Data?
    func delete(key: String) -> OSStatus
}

public final class KeychainHelper: BaseClass, KeychainHelping {
    typealias Dependencies = HasLoggers
    
    private let logger: LoggerServicing
    
    init(dependencies: Dependencies) {
        self.logger = dependencies.logger
    }
    
    func save(key: String, data: Data) -> OSStatus {
        let query = [
            kSecClass as String: kSecClassGenericPassword as String,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ] as [String : Any]
        
        SecItemDelete(query as CFDictionary)
        let status = SecItemAdd(query as CFDictionary, nil)
        if status != errSecSuccess {
            logger.log(message: "Failed to save data for key \(key) with status \(status)")
        }
        return status
    }
    
    func load(key: String) -> Data? {
        let query = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: kCFBooleanTrue!,
            kSecMatchLimit as String: kSecMatchLimitOne
        ] as [String : Any]
        
        var dataTypeRef: AnyObject? = nil
        let status: OSStatus = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
        
        if status == errSecSuccess, let data = dataTypeRef as? Data {
            return data
        } else {
            logger.log(message: "Failed to load data for key \(key) with status \(status)")
            return nil
        }
    }
    
    func delete(key: String) -> OSStatus {
        let query = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ] as [String : Any]
        
        let status = SecItemDelete(query as CFDictionary)
        if status != errSecSuccess {
            logger.log(message:"Failed to delete data for key \(key) with status \(status)")
        }
        return status
    }
}
