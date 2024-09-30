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
        
        do {
            try keychainHelper.save(key: KeychainConstants.usernameKey, data: usernameData)
            do {
                try keychainHelper.save(key: KeychainConstants.passwordKey, data: passwordData)
            } catch {
                // Rollback in case saving the password fails
                try? keychainHelper.delete(key: KeychainConstants.usernameKey)
                throw BaseError(
                    context: .database,
                    message: "Failed to save password",
                    logger: logger
                )
            }
        } catch {
            throw BaseError(
                context: .database,
                message: "Failed to save username",
                logger: logger
            )
        }
    }
    
    func delete() throws {
        guard let username = self.username?.data(using: .utf8) else { return } // For rollback
        do {
            try keychainHelper.delete(key: KeychainConstants.usernameKey)
            do {
                try keychainHelper.delete(key: KeychainConstants.passwordKey)
            } catch {
                // Rollback in case deleting the password fails
                try? keychainHelper.save(key: KeychainConstants.usernameKey, data: username)
                throw BaseError(
                    context: .database,
                    message: "Failed to delete password",
                    logger: logger
                )
            }
        } catch {
            throw BaseError(
                context: .database,
                message: "Failed to delete username",
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
}
