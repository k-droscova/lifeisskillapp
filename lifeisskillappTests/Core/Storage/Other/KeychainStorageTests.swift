//
//  KeychainStorageTests.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 30.09.2024.
//

import XCTest
@testable import lifeisskillapp

final class KeychainStorageTests: XCTestCase {
    
    private struct Dependencies: KeychainStorage.Dependencies {
        let logger: LoggerServicing
        var keychainHelper: KeychainHelping
    }
    
    var keychainHelper: KeychainHelperMock!
    var logger: LoggerServicing!
    var keychainStorage: KeychainStoraging!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        logger = LoggingServiceMock()
        keychainHelper = KeychainHelperMock()
        keychainHelper.logger = logger
        
        let dependencies = Dependencies(
            logger: logger,
            keychainHelper: keychainHelper
        )
        
        keychainStorage = KeychainStorage(dependencies: dependencies)
    }
    
    override func tearDownWithError() throws {
        keychainHelper = nil
        logger = nil
        keychainStorage = nil
        try super.tearDownWithError()
    }
}

// MARK: - Testing save()

extension KeychainStorageTests {
    
    func testSaveCredentialsSuccessfully() throws {
        // Arrange
        let credentials = LoginCredentials(username: "newUser", password: "newPass")
        
        // Act
        do {
            try keychainStorage.save(credentials: credentials)
            
            // Assert
            XCTAssertEqual(keychainStorage.username, credentials.username)
            XCTAssertEqual(keychainStorage.password, credentials.password)
            XCTAssertEqual(keychainHelper.savedData[KeychainConstants.usernameKey], credentials.username.data(using: .utf8))
            XCTAssertEqual(keychainHelper.savedData[KeychainConstants.passwordKey], credentials.password.data(using: .utf8))
        } catch {
            XCTFail("Unexpected error thrown: \(error)")
        }
    }
    
    func testSaveCredentialsFailsWhenSavingUsername() throws {
        // Arrange
        let originalUsername = "originalUser"
        let originalPassword = "originalPass"
        keychainHelper.savedData[KeychainConstants.usernameKey] = originalUsername.data(using: .utf8)
        keychainHelper.savedData[KeychainConstants.passwordKey] = originalPassword.data(using: .utf8)
        
        let credentials = LoginCredentials(username: "newUser", password: "newPass")
        
        // Simulate failure during username saving
        keychainHelper.shouldThrowErrorOnUsername = true
        keychainHelper.thrownError = BaseError(context: .database, message: "Failed to save username", logger: logger)
        
        // Act & Assert
        XCTAssertThrowsError(try keychainStorage.save(credentials: credentials)) { error in
            guard let baseError = error as? BaseError else {
                return XCTFail("Expected a BaseError to be thrown")
            }
            XCTAssertEqual(baseError.message, "Failed to save username")
        }
        
        keychainHelper.shouldThrowErrorOnUsername = false
        
        // Assert that username and password remain unchanged
        XCTAssertEqual(keychainStorage.username, originalUsername)
        XCTAssertEqual(keychainStorage.password, originalPassword)
        XCTAssertEqual(keychainHelper.savedData[KeychainConstants.usernameKey], originalUsername.data(using: .utf8))
        XCTAssertEqual(keychainHelper.savedData[KeychainConstants.passwordKey], originalPassword.data(using: .utf8))
    }
    
    func testSaveCredentialsFailsWhenSavingPassword() throws {
        // Arrange
        let originalUsername = "originalUser"
        let originalPassword = "originalPass"
        keychainHelper.savedData[KeychainConstants.usernameKey] = originalUsername.data(using: .utf8)
        keychainHelper.savedData[KeychainConstants.passwordKey] = originalPassword.data(using: .utf8)
        
        let credentials = LoginCredentials(username: "newUser", password: "newPass")
        
        // Simulate failure during password saving
        keychainHelper.shouldThrowErrorOnPassword = true
        keychainHelper.thrownError = BaseError(context: .database, message: "Failed to save password", logger: logger)
        
        // Act & Assert
        XCTAssertThrowsError(try keychainStorage.save(credentials: credentials)) { error in
            guard let baseError = error as? BaseError else {
                return XCTFail("Expected a BaseError to be thrown")
            }
            XCTAssertEqual(baseError.message, "Failed to save password")
        }
        
        keychainHelper.shouldThrowErrorOnPassword = false
        
        // Assert that username and password remain unchanged (rollback should happen)
        XCTAssertNil(keychainHelper.savedData[KeychainConstants.usernameKey])  // Rollback should remove username
        XCTAssertEqual(keychainStorage.username, originalUsername)  // Still holds the original username
        XCTAssertEqual(keychainStorage.password, originalPassword)
        XCTAssertEqual(keychainHelper.savedData[KeychainConstants.passwordKey], originalPassword.data(using: .utf8))
    }
}

// MARK: - Testing delete()

extension KeychainStorageTests {
    
}
