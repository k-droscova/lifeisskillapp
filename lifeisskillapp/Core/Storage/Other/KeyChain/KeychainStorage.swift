//
//  KeychainStorage.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 13.08.2024.
//

import Foundation

protocol HasKeychainStorage {
    var keychainStorage: KeychainStoraging { get set }
}

protocol KeychainStoraging {
    var username: String? { get }
    var password: String? { get }
    func save(credentials: LoginCredentials) throws
    func delete() throws
}

public final class KeychainStorage: BaseClass, KeychainStoraging {
    typealias Dependencies = HasLoggers & HasKeychainHelper
    
    private let logger: LoggerServicing
    private let keychainHelper: KeychainHelping
    
    var username: String? { loadUsername() }
    var password: String? { loadPassword() }
    
    init(dependencies: Dependencies) {
        self.logger = dependencies.logger
        self.keychainHelper = dependencies.keychainHelper
    }
    
    func save(credentials: LoginCredentials) throws {
        guard let usernameData = credentials.username.data(using: .utf8),
              let passwordData = credentials.password.data(using: .utf8) else {
            throw BaseError(
                context: .database,
                message: "Failed to convert credentials to Data",
                logger: self.logger
            )
        }
        
        let usernameSaveStatus = keychainHelper.save(key: KeychainConstants.usernameKey, data: usernameData)
        guard usernameSaveStatus == errSecSuccess else {
            throw BaseError(
                context: .database,
                message: "Failed to save username with status \(usernameSaveStatus)",
                logger: self.logger
            )
        }
        
        let passwordSaveStatus = keychainHelper.save(key: KeychainConstants.passwordKey, data: passwordData)
        guard passwordSaveStatus == errSecSuccess else {
            // rollback
            _ = keychainHelper.delete(key: KeychainConstants.usernameKey)
            throw BaseError(
                context: .database,
                message: "Failed to save password with status \(passwordSaveStatus)",
                logger: self.logger
            )
        }
    }
    
    func delete() throws {
        guard let username = self.username?.data(using: .utf8) else { return } // for rollback
        let usernameDeleteStatus = keychainHelper.delete(key: KeychainConstants.usernameKey)
        guard usernameDeleteStatus == errSecSuccess else {
            throw BaseError(
                context: .database,
                message: "Failed to delete username with status \(usernameDeleteStatus)",
                logger: self.logger
            )
        }
        
        let passwordDeleteStatus = keychainHelper.delete(key: KeychainConstants.passwordKey)
        guard passwordDeleteStatus == errSecSuccess else {
            // rollback
            _ = keychainHelper.save(key: KeychainConstants.usernameKey, data: username)
            throw BaseError(
                context: .database,
                message: "Failed to delete password with status \(passwordDeleteStatus)",
                logger: self.logger
            )
        }
    }
    
    // MARK: - Private Helpers
    
    private func loadUsername() -> String? {
        guard let usernameData = keychainHelper.load(key: KeychainConstants.usernameKey) else {
            logger.log(message: "Failed to load username from Keychain")
            return nil
        }
        return String(data: usernameData, encoding: .utf8)
    }
    
    private func loadPassword() -> String? {
        guard let passwordData = keychainHelper.load(key: KeychainConstants.passwordKey) else {
            logger.log(message: "Failed to load password from Keychain")
            return nil
        }
        return String(data: passwordData, encoding: .utf8)
    }
}
