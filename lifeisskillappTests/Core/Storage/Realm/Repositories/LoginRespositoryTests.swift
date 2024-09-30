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
        
        // Set up an in-memory Realm instance for testing
        realmStorage = RealmStorageMock()
        realm = realmStorage.getRealm() // Get the in-memory Realm instance
        logger = LoggingServiceMock()
        
        // Initialize the repository with the mocked storage
        let dependencies = Dependencies(
            realmStorage: realmStorage,
            logger: logger
        )
        loginRepository = RealmLoginRepository(dependencies: dependencies)
    }
    
    override func tearDownWithError() throws {
        // Clear Realm data after each test
        realmStorage.clearRealm()
        realm = nil
        loginRepository = nil
        try super.tearDownWithError()
    }
    
    // MARK: - Test Methods
    
    func testSaveLoginUser() throws {
        // Arrange: Set up a LoggedInUser with sample data
        let user = LoggedInUser(
            userId: "123",
            email: "test@example.com",
            nick: "testNick",
            sex: .male,
            rights: 1,
            rightsCoded: "001",
            token: "sampleToken",
            userRank: 5,
            userPoints: 1000,
            distance: 50,
            mainCategory: "categoryA",
            fullActivation: false,
            activationStatus: .incomplete,
            name: "John",
            surname: "Doe",
            birthday: Date(timeIntervalSince1970: 315532800), // Jan 1, 1980
            nameParent: "Jane",
            surnameParent: "Doe",
            emailParent: "parent@example.com",
            mobilParent: "1234567890"
        )
        
        // Act: Save the user in the repository
        try loginRepository.saveLoginUser(user)
        
        // Assert: Fetch the user directly from Realm
        let savedUser = realm.objects(RealmLoginDetails.self).first
        
        XCTAssertNotNil(savedUser, "Expected to retrieve saved login details from Realm.")
        XCTAssertEqual(savedUser?.userID, user.userId, "Expected saved user ID to match.")
        XCTAssertEqual(savedUser?.email, user.email, "Expected saved user email to match.")
        XCTAssertEqual(savedUser?.nick, user.nick, "Expected saved user nickname to match.")
        XCTAssertEqual(savedUser?.sexRaw, user.sex.rawValue, "Expected saved user sex to match.")
        XCTAssertEqual(savedUser?.rights, user.rights, "Expected saved user rights to match.")
        XCTAssertEqual(savedUser?.rightsCoded, user.rightsCoded, "Expected saved user rightsCoded to match.")
        XCTAssertEqual(savedUser?.token, user.token, "Expected saved user token to match.")
        XCTAssertEqual(savedUser?.userRank, user.userRank, "Expected saved user rank to match.")
        XCTAssertEqual(savedUser?.userPoints, user.userPoints, "Expected saved user points to match.")
        XCTAssertEqual(savedUser?.distance, user.distance, "Expected saved user distance to match.")
        XCTAssertEqual(savedUser?.mainCategory, user.mainCategory, "Expected saved user mainCategory to match.")
        XCTAssertEqual(savedUser?.fullActivation, user.fullActivation, "Expected saved user fullActivation to match.")
        XCTAssertEqual(savedUser?.activationStatus, user.activationStatus.rawValue, "Expected saved user activationStatus to match.")
        XCTAssertEqual(savedUser?.name, user.name, "Expected saved user name to match.")
        XCTAssertEqual(savedUser?.surname, user.surname, "Expected saved user surname to match.")
        XCTAssertEqual(savedUser?.birthday, user.birthday, "Expected saved user birthday to match.")
        XCTAssertEqual(savedUser?.nameParent, user.nameParent, "Expected saved user parent name to match.")
        XCTAssertEqual(savedUser?.surnameParent, user.surnameParent, "Expected saved user parent surname to match.")
        XCTAssertEqual(savedUser?.emailParent, user.emailParent, "Expected saved user parent email to match.")
        XCTAssertEqual(savedUser?.mobilParent, user.mobilParent, "Expected saved user parent mobil to match.")
    }
    
    func testMarkUserAsLoggedOut() throws {
        // Arrange: Set up and save a logged-in user
        let user = LoggedInUser(
            userId: "123",
            email: "test@example.com",
            nick: "testNick",
            sex: .male,
            rights: 1,
            rightsCoded: "001",
            token: "sampleToken",
            userRank: 5,
            userPoints: 1000,
            distance: 50,
            mainCategory: "categoryA",
            fullActivation: true
        )
        
        // Act: Save the user and mark them as logged out
        try loginRepository.saveLoginUser(user)
        try loginRepository.markUserAsLoggedOut()
        
        // Assert: Fetch the user directly from Realm and ensure they are logged out
        let savedUser = realm.objects(RealmLoginDetails.self).first
        XCTAssertNotNil(savedUser, "Expected to retrieve saved login details from Realm.")
        XCTAssertFalse(savedUser?.isLoggedIn ?? true, "Expected the user to be marked as logged out.")
    }
    
    func testGetLoggedInUser() throws {
        // Arrange: Set up and save a logged-in user
        let user = LoggedInUser(
            userId: "123",
            email: "test@example.com",
            nick: "testNick",
            sex: .male,
            rights: 1,
            rightsCoded: "001",
            token: "sampleToken",
            userRank: 5,
            userPoints: 1000,
            distance: 50,
            mainCategory: "categoryA",
            fullActivation: true
        )
        
        // Act: Save the user, mark them as logged out, then back in
        try loginRepository.saveLoginUser(user)
        try loginRepository.markUserAsLoggedOut()
        try loginRepository.markUserAsLoggedIn()
        
        // Assert: Fetch the user directly from Realm and ensure they are logged in
        let loggedInUser = realm.objects(RealmLoginDetails.self).first(where: { $0.isLoggedIn })
        
        XCTAssertNotNil(loggedInUser, "Expected to retrieve the logged-in user from Realm.")
        XCTAssertTrue(loggedInUser?.isLoggedIn ?? false, "Expected the user to be marked as logged in.")
    }
    
    func testDeleteLoginUser() throws {
        // Arrange: Set up and save a logged-in user
        let user = LoggedInUser(
            userId: "123",
            email: "test@example.com",
            nick: "testNick",
            sex: .male,
            rights: 1,
            rightsCoded: "001",
            token: "sampleToken",
            userRank: 5,
            userPoints: 1000,
            distance: 50,
            mainCategory: "categoryA",
            fullActivation: true
        )
        
        // Act: Save the user and then delete them
        try loginRepository.saveLoginUser(user)
        if let savedUser = realm.objects(RealmLoginDetails.self).first {
            try loginRepository.delete(savedUser)
        }
        
        // Assert: Ensure the user is deleted from Realm
        let deletedUser = realm.objects(RealmLoginDetails.self).first
        XCTAssertNil(deletedUser, "Expected the user to be deleted from Realm.")
    }
}
