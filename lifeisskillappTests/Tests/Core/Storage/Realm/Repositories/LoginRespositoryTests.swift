//
//  LoginRespositoryTests.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 30.09.2024.
//

import XCTest
import RealmSwift
@testable import lifeisskillapp

final class RealmLoginRepositoryTests: XCTestCase {

    private struct Dependencies: RealmLoginRepository.Dependencies {
        var realmStorage: RealmStoraging
        let logger: LoggerServicing
    }
    
    var realm: Realm!
    var realmStorage: RealmStorageMock!
    var loginRepository: RealmLoginRepository!
    var logger: LoggerServicing!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        realmStorage = RealmStorageMock()
        realm = realmStorage.getRealm()
        logger = LoggingServiceMock()

        let dependencies = Dependencies(realmStorage: realmStorage, logger: logger)
        loginRepository = RealmLoginRepository(dependencies: dependencies)
    }

    override func tearDownWithError() throws {
        try realmStorage.clearRealm()
        realm = nil
        realmStorage = nil
        loginRepository = nil
        try super.tearDownWithError()
    }
    
    // MARK: - Tests for RealmLoginRepository Methods
    
    func testSaveLoginUser_Success() throws {
        // Arrange
        let user = LoggedInUser.mock(userId: "mockUser")

        // Act
        try loginRepository.saveLoginUser(user)

        // Assert
        let savedUser = realm.objects(RealmLoginDetails.self).first
        XCTAssertNotNil(savedUser, "Expected to retrieve saved login details from Realm.")
        XCTAssertEqual(savedUser?.userID, user.userId)
    }
    
    func testSaveLoginUser_RealmNotInitialized_ShouldThrowError() throws {
        // Arrange
        realmStorage.shouldThrowError = true
        let user = LoggedInUser.mock(userId: "123")
        
        // Act & Assert
        XCTAssertThrowsError(try loginRepository.saveLoginUser(user)) { error in
            XCTAssertEqual((error as? BaseError)?.message, "Realm is not initialized")
        }
    }
    
    func testGetSavedLoginDetails_Success() throws {
        // Arrange
        let user = LoggedInUser.mock(userId: "123")
        let loginDetails = RealmLoginDetails(from: user)
        
        try realm.write {
            realm.add(loginDetails)
        }

        // Act
        let savedDetails = try loginRepository.getSavedLoginDetails()

        // Assert
        XCTAssertNotNil(savedDetails)
        XCTAssertEqual(savedDetails?.userID, user.id)
        XCTAssertEqual(savedDetails?.email, user.email)
    }
    
    func testGetSavedLoginDetails_NoSavedUser_ShouldReturnNil() throws {
        // Act
        let savedDetails = try loginRepository.getSavedLoginDetails()

        // Assert
        XCTAssertNil(savedDetails)
    }
    
    func testGetLoggedInUser_Success() throws {
        // Arrange
        let user = LoggedInUser.mock(userId: "123")
        let loginDetails = RealmLoginDetails(from: user)
        loginDetails.isLoggedIn = true
        
        try realm.write {
            realm.add(loginDetails)
        }

        // Act
        let loggedInUser = try loginRepository.getLoggedInUser()

        // Assert
        XCTAssertNotNil(loggedInUser)
        XCTAssertEqual(loggedInUser?.userID, "123")
        XCTAssertTrue(loggedInUser?.isLoggedIn ?? false)
    }
    
    func testGetLoggedInUser_NoLoggedInUser_ShouldReturnNil() throws {
        // Act
        let loggedInUser = try loginRepository.getLoggedInUser()

        // Assert
        XCTAssertNil(loggedInUser)
    }
    
    func testMarkUserAsLoggedOut_Success() throws {
        // Arrange
        let user = LoggedInUser.mock(userId: "123")
        let loginDetails = RealmLoginDetails(from: user)
        loginDetails.isLoggedIn = true
        
        try realm.write {
            realm.add(loginDetails)
        }

        // Act
        try loginRepository.markUserAsLoggedOut()

        // Assert
        let savedUser = realm.objects(RealmLoginDetails.self).first
        XCTAssertNotNil(savedUser)
        XCTAssertFalse(savedUser?.isLoggedIn ?? true)
    }
    
    func testMarkUserAsLoggedOut_NoUserSaved_ShouldThrowError() throws {
        // Act & Assert
        XCTAssertThrowsError(try loginRepository.markUserAsLoggedOut()) { error in
            XCTAssertEqual((error as? BaseError)?.message, "No user is currently logged in.")
        }
    }
    
    func testMarkUserAsLoggedIn_Success() throws {
        // Arrange
        let user = LoggedInUser.mock(userId: "123")
        let loginDetails = RealmLoginDetails(from: user)
        loginDetails.isLoggedIn = false
        
        try realm.write {
            realm.add(loginDetails)
        }

        // Act
        try loginRepository.markUserAsLoggedIn()

        // Assert
        let savedUser = realm.objects(RealmLoginDetails.self).first
        XCTAssertNotNil(savedUser)
        XCTAssertTrue(savedUser?.isLoggedIn ?? false)
    }
    
    func testMarkUserAsLoggedIn_NoUserSaved_ShouldThrowError() throws {
        // Act & Assert
        XCTAssertThrowsError(try loginRepository.markUserAsLoggedIn()) { error in
            XCTAssertEqual((error as? BaseError)?.message, "No user is currently logged in.")
        }
    }
    
    // MARK: - Tests for Protocol Extension Methods
    
    func testSaveSingleEntity_Success() throws {
        // Arrange
        let user = LoggedInUser.mock(userId: "123")
        let loginDetails = RealmLoginDetails(from: user)
        
        // Act
        try loginRepository.save(loginDetails)
        
        // Assert
        let savedUser = realm.objects(RealmLoginDetails.self).first
        XCTAssertNotNil(savedUser)
        XCTAssertEqual(savedUser?.userID, "123")
    }

    func testSaveSingleEntity_RealmNotInitialized_ShouldThrowError() throws {
        // Arrange
        realmStorage.shouldThrowError = true
        let user = LoggedInUser.mock(userId: "123")
        let loginDetails = RealmLoginDetails(from: user)
        
        // Act & Assert
        XCTAssertThrowsError(try loginRepository.save(loginDetails)) { error in
            XCTAssertEqual((error as? BaseError)?.message, "Realm is not initialized")
        }
    }
    
    func testDeleteSingleEntity_Success() throws {
        // Arrange
        let user = LoggedInUser.mock(userId: "123")
        let loginDetails = RealmLoginDetails(from: user)
        
        try realm.write {
            realm.add(loginDetails)
        }
        
        // Act
        try loginRepository.delete(loginDetails)

        // Assert
        let deletedUser = realm.objects(RealmLoginDetails.self).first
        XCTAssertNil(deletedUser, "Expected the user to be deleted from Realm.")
    }

    func testDeleteSingleEntity_RealmNotInitialized_ShouldThrowError() throws {
        // Arrange
        realmStorage.shouldThrowError = true
        let user = LoggedInUser.mock(userId: "123")
        let loginDetails = RealmLoginDetails(from: user)

        // Act & Assert
        XCTAssertThrowsError(try loginRepository.delete(loginDetails)) { error in
            XCTAssertEqual((error as? BaseError)?.message, "Realm is not initialized")
        }
    }
    
    func testDeleteAllEntities_Success() throws {
        // Arrange
        let user1 = LoggedInUser.mock(userId: "123")
        let user2 = LoggedInUser.mock(userId: "124")
        let loginDetails1 = RealmLoginDetails(from: user1)
        let loginDetails2 = RealmLoginDetails(from: user2)

        try realm.write {
            realm.add([loginDetails1, loginDetails2], update: .modified)
        }

        // Act
        try loginRepository.deleteAll()

        // Assert
        let users = realm.objects(RealmLoginDetails.self)
        XCTAssertEqual(users.count, 0, "Expected all users to be deleted from Realm.")
    }

    func testDeleteAllEntities_RealmNotInitialized_ShouldThrowError() throws {
        // Arrange
        realmStorage.shouldThrowError = true

        // Act & Assert
        XCTAssertThrowsError(try loginRepository.deleteAll()) { error in
            XCTAssertEqual((error as? BaseError)?.message, "Realm is not initialized")
        }
    }
    
    func testGetAllEntities_Success() throws {
        // Arrange
        let user1 = LoggedInUser.mock(userId: "123")
        let user2 = LoggedInUser.mock(userId: "124")
        let loginDetails1 = RealmLoginDetails(from: user1)
        let loginDetails2 = RealmLoginDetails(from: user2)

        try realm.write {
            realm.add([loginDetails1, loginDetails2], update: .modified)
        }

        // Act
        let users = try loginRepository.getAll()

        // Assert
        XCTAssertEqual(users.count, 1, "Expected to retrieve only one logged in user")
        XCTAssertEqual(users.first?.userID, user2.userId, "Expected to get details of user saved as second")
    }

    func testGetAllEntities_RealmNotInitialized_ShouldThrowError() throws {
        // Arrange
        realmStorage.shouldThrowError = true

        // Act & Assert
        XCTAssertThrowsError(try loginRepository.getAll()) { error in
            XCTAssertEqual((error as? BaseError)?.message, "Realm is not initialized")
        }
    }
    
    func testGetEntityById_Success() throws {
        // Arrange
        let user = LoggedInUser.mock(userId: "123")
        let loginDetails = RealmLoginDetails(from: user)

        try realm.write {
            realm.add(loginDetails)
        }

        // Act
        let savedUser = try loginRepository.getById(loginDetails.loginID)

        // Assert
        XCTAssertNotNil(savedUser, "Expected to retrieve the user by ID from Realm.")
        XCTAssertEqual(savedUser?.userID, "123", "Expected the user ID to match.")
    }

    func testGetEntityById_UserNotFound_ShouldReturnNil() throws {
        // Act
        let savedUser = try loginRepository.getById("non-existing-id")

        // Assert
        XCTAssertNil(savedUser, "Expected to return nil for a non-existing user ID.")
    }

    func testGetEntityById_RealmNotInitialized_ShouldThrowError() throws {
        // Arrange
        realmStorage.shouldThrowError = true

        // Act & Assert
        XCTAssertThrowsError(try loginRepository.getById("123")) { error in
            XCTAssertEqual((error as? BaseError)?.message, "Realm is not initialized")
        }
    }
}
