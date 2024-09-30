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

final class KeychainStorage: BaseClass, KeychainStoraging {
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
              let passwordData = credentials.password.data(using: .utf8)
        else {
            throw BaseError(
                context: .database,
                message: "Failed to convert credentials to Data",
                logger: logger
            )
        }
        
        // Load the original values (if any) for rollback purposes
        let usernameOriginal = loadUsername()?.data(using: .utf8)
        
        do {
            // Try saving the username first
            try keychainHelper.save(key: KeychainConstants.usernameKey, data: usernameData)
            
            // Try saving the password second
            do {
                try keychainHelper.save(key: KeychainConstants.passwordKey, data: passwordData)
            } catch {
                // Rollback in case saving the password fails
                rollbackUsername(originalData: usernameOriginal)
                throw BaseError(
                    context: .database,
                    message: "Failed to save password. Username has been rolled back.",
                    logger: logger
                )
            }
        } catch {
            // If saving the username fails, no rollback is necessary, just throw an error
            throw BaseError(
                context: .database,
                message: "Failed to save username.",
                logger: logger
            )
        }
    }
    
    func delete() throws {
        let usernameOriginal = loadUsername()?.data(using: .utf8)
        
        do {
            try keychainHelper.delete(key: KeychainConstants.usernameKey)
            
            do {
                try keychainHelper.delete(key: KeychainConstants.passwordKey)
            } catch {
                // Rollback in case deleting the password fails
                rollbackUsername(originalData: usernameOriginal)
                throw BaseError(
                    context: .database,
                    message: "Failed to delete password. Username has been rolled back.",
                    logger: logger
                )
            }
        } catch {
            throw BaseError(
                context: .database,
                message: "Failed to delete username.",
                logger: logger
            )
        }
    }
    
    // MARK: - Private Helpers
    
    private func loadUsername() -> String? {
        do {
            let usernameData = try keychainHelper.load(key: KeychainConstants.usernameKey)
            return String(data: usernameData, encoding: .utf8)
        } catch {
            logger.log(message: "Failed to load username from Keychain: \(error)")
            return nil
        }
    }
    
    private func loadPassword() -> String? {
        do {
            let passwordData = try keychainHelper.load(key: KeychainConstants.passwordKey)
            return String(data: passwordData, encoding: .utf8)
        } catch {
            logger.log(message: "Failed to load password from Keychain: \(error)")
            return nil
        }
    }
    
    private func rollbackUsername(originalData: Data?) {
        if let originalData = originalData {
            // If there was an original username, restore it
            if let _ = try? keychainHelper.save(key: KeychainConstants.usernameKey, data: originalData) {
                logger.log(message: "Rollback successful: original username restored.")
            } else {
                logger.log(message: "Rollback failed: could not restore original username.")
            }
        } else {
            // If no original username, delete the newly saved username
            if let _ = try? keychainHelper.delete(key: KeychainConstants.usernameKey) {
                logger.log(message: "Rollback successful: new username deleted.")
            } else {
                logger.log(message: "Rollback failed: could not delete new username.")
            }
        }
    }
}
