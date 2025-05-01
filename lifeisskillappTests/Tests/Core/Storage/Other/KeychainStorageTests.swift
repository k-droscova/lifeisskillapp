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

// MARK: - Testing consistency of username and password properties with save() func

extension KeychainStorageTests {
    
    func testUsernameAndPasswordAreNilWhenNoValuesSaved() throws {
        // Assert
        XCTAssertNil(keychainStorage.username, "Expected username to be nil when no value is saved")
        XCTAssertNil(keychainStorage.password, "Expected password to be nil when no value is saved")
    }
    
    func testUsernameAndPasswordReturnSavedValues() throws {
        // Arrange
        let savedUsername = "existingUser"
        let savedPassword = "existingPass"
        keychainHelper.savedData[KeychainConstants.usernameKey] = savedUsername.data(using: .utf8)
        keychainHelper.savedData[KeychainConstants.passwordKey] = savedPassword.data(using: .utf8)
        
        // Assert
        XCTAssertEqual(keychainStorage.username, savedUsername, "Expected username to match the saved value")
        XCTAssertEqual(keychainStorage.password, savedPassword, "Expected password to match the saved value")
    }
    
    func testUsernameAndPasswordReturnNewlySavedValues() throws {
        // Arrange
        let credentials = LoginCredentials(username: "newUser", password: "newPass")
        
        // Act
        try keychainStorage.save(credentials: credentials)
        
        // Assert
        XCTAssertEqual(keychainStorage.username, credentials.username, "Expected username to match newly saved value")
        XCTAssertEqual(keychainStorage.password, credentials.password, "Expected password to match newly saved value")
    }
    
    func testUsernameAndPasswordAreUnchangedWhenSavingUsernameFails() throws {
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
            XCTAssertEqual(baseError.message, "Failed to save username.")
        }
        
        keychainHelper.shouldThrowErrorOnUsername = false
        
        // Ensure properties remain unchanged
        XCTAssertEqual(keychainStorage.username, originalUsername, "Expected username to remain unchanged after failed save")
        XCTAssertEqual(keychainStorage.password, originalPassword, "Expected password to remain unchanged after failed save")
    }
    
    func testUsernameAndPasswordAreUnchangedWhenSavingPasswordFails() throws {
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
            XCTAssertEqual(baseError.message, "Failed to save password. Username has been rolled back.")
        }
        
        keychainHelper.shouldThrowErrorOnPassword = false
        
        // Ensure rollback occurs and properties remain unchanged
        XCTAssertEqual(keychainStorage.username, originalUsername, "Expected username to remain unchanged after failed password save")
        XCTAssertEqual(keychainStorage.password, originalPassword, "Expected password to remain unchanged after failed password save")
    }
}

// MARK: - Testing consistency of username and password properties with delete() func

extension KeychainStorageTests {
    
    func testUsernameAndPasswordAreNilAfterSuccessfulDelete() throws {
        // Arrange
        let savedUsername = "existingUser"
        let savedPassword = "existingPass"
        keychainHelper.savedData[KeychainConstants.usernameKey] = savedUsername.data(using: .utf8)
        keychainHelper.savedData[KeychainConstants.passwordKey] = savedPassword.data(using: .utf8)
        
        // Act
        try keychainStorage.delete()
        
        // Assert
        XCTAssertNil(keychainStorage.username, "Expected username to be nil after successful delete")
        XCTAssertNil(keychainStorage.password, "Expected password to be nil after successful delete")
    }
    
    func testUsernameAndPasswordAreUnchangedWhenDeletingUsernameFails() throws {
        // Arrange
        let originalUsername = "originalUser"
        let originalPassword = "originalPass"
        keychainHelper.savedData[KeychainConstants.usernameKey] = originalUsername.data(using: .utf8)
        keychainHelper.savedData[KeychainConstants.passwordKey] = originalPassword.data(using: .utf8)
        
        // Simulate failure during username deletion
        keychainHelper.shouldThrowErrorOnUsername = true
        keychainHelper.thrownError = BaseError(context: .database, message: "Failed to delete username", logger: logger)
        
        // Act & Assert
        XCTAssertThrowsError(try keychainStorage.delete()) { error in
            guard let baseError = error as? BaseError else {
                return XCTFail("Expected a BaseError to be thrown")
            }
            XCTAssertEqual(baseError.message, "Failed to delete username.")
        }
        
        keychainHelper.shouldThrowErrorOnUsername = false
        
        // Ensure properties remain unchanged
        XCTAssertEqual(keychainStorage.username, originalUsername, "Expected username to remain unchanged after failed delete")
        XCTAssertEqual(keychainStorage.password, originalPassword, "Expected password to remain unchanged after failed delete")
    }
    
    func testUsernameAndPasswordAreUnchangedWhenDeletingPasswordFails() throws {
        // Arrange
        let originalUsername = "originalUser"
        let originalPassword = "originalPass"
        keychainHelper.savedData[KeychainConstants.usernameKey] = originalUsername.data(using: .utf8)
        keychainHelper.savedData[KeychainConstants.passwordKey] = originalPassword.data(using: .utf8)
        
        // Simulate failure during password deletion
        keychainHelper.shouldThrowErrorOnPassword = true
        keychainHelper.thrownError = BaseError(context: .database, message: "Failed to delete password", logger: logger)
        
        // Act & Assert
        XCTAssertThrowsError(try keychainStorage.delete()) { error in
            guard let baseError = error as? BaseError else {
                return XCTFail("Expected a BaseError to be thrown")
            }
            XCTAssertEqual(baseError.message, "Failed to delete password. Username has been rolled back.")
        }
        
        keychainHelper.shouldThrowErrorOnPassword = false
        
        // Ensure rollback occurs and properties remain unchanged
        XCTAssertEqual(keychainStorage.username, originalUsername, "Expected username to remain unchanged after failed password delete")
        XCTAssertEqual(keychainStorage.password, originalPassword, "Expected password to remain unchanged after failed password delete")
    }
}
