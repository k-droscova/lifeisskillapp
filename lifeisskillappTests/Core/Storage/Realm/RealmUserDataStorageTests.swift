//
//  RealmUserDataStorageTests.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 01.10.2024.
//

import XCTest
import Combine
@testable import lifeisskillapp

final class RealmUserDataStorageTests: XCTestCase {
    
    private struct Dependencies: HasLoggers & HasRealmRepositories {
        var logger: LoggerServicing
        var realmLoginRepository: any RealmLoginRepositoring
        var realmCheckSumRepository: any RealmCheckSumRepositoring
        var realmCategoryRepository: any RealmUserCategoryRepositoring
        var realmUserRankRepository: any RealmUserRankRepositoring
        var realmPointRepository: any RealmGenericPointRepositoring
        var realmUserPointRepository: any RealmUserPointRepositoring
        var realmScannedPointRepository: any RealmScannedPointRepositoring
        var realmSponsorRepository: any RealmSponsorRepositoring
    }
    
    var userDataStorage: RealmUserDataStorage!
    var mockLoginRepo: MockRealmLoginRepository!
    var mockCheckSumRepo: MockRealmCheckSumRepository!
    var mockCategoryRepo: MockRealmUserCategoryRepository!
    var mockRankingRepo: MockRealmUserRankRepository!
    var mockGenericPointRepo: MockRealmGenericPointRepository!
    var mockUserPointRepo: MockRealmUserPointRepository!
    var mockScannedPointRepo: MockRealmScannedPointRepository!
    var mockSponsorRepo: MockRealmSponsorRepository!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        mockLoginRepo = MockRealmLoginRepository()
        mockCheckSumRepo = MockRealmCheckSumRepository()
        mockCategoryRepo = MockRealmUserCategoryRepository()
        mockRankingRepo = MockRealmUserRankRepository()
        mockGenericPointRepo = MockRealmGenericPointRepository()
        mockUserPointRepo = MockRealmUserPointRepository()
        mockScannedPointRepo = MockRealmScannedPointRepository()
        mockSponsorRepo = MockRealmSponsorRepository()
        
        let mockLogger = LoggingServiceMock()
        
        let dependencies = Dependencies(
            logger: mockLogger,
            realmLoginRepository: mockLoginRepo,
            realmCheckSumRepository: mockCheckSumRepo,
            realmCategoryRepository: mockCategoryRepo,
            realmUserRankRepository: mockRankingRepo,
            realmPointRepository: mockGenericPointRepo,
            realmUserPointRepository: mockUserPointRepo,
            realmScannedPointRepository: mockScannedPointRepo,
            realmSponsorRepository: mockSponsorRepo
        )
        
        userDataStorage = RealmUserDataStorage(dependencies: dependencies)
    }
    
    override func tearDownWithError() throws {
        userDataStorage = nil
        try super.tearDownWithError()
    }
}

// MARK: - Testing Public Interface For Logged In User

extension RealmUserDataStorageTests {
    func testSavedLoginDetails_WithData_ReturnsUserData() async throws {
        // Arrange
        let user = LoggedInUser.mock(userId: "mockUser")
        mockLoginRepo.savedLoginDetails = RealmLoginDetails(from: user)
        mockLoginRepo.savedLoginDetails?.isLoggedIn = true
        
        // Act
        let savedData = try await userDataStorage.savedLoginDetails()
        
        // Assert
        XCTAssertNotNil(savedData, "Expected saved login details to be returned.")
        XCTAssertEqual(savedData?.user.userId, user.userId, "Expected userID to match.")
    }
    
    func testSavedLoginDetails_NoData_ReturnsNil() async throws {
        // Arrange
        mockLoginRepo.savedLoginDetails = nil
        
        // Act
        let savedData = try await userDataStorage.savedLoginDetails()
        
        // Assert
        XCTAssertNil(savedData, "Expected nil when there are no saved login details.")
    }
    
    // Test loggedInUserDetails functionality
    func testLoggedInUserDetails_UserIsLoggedIn_ReturnsUserData() async throws {
        // Arrange
        let user = LoggedInUser.mock(userId: "mockUser")
        mockLoginRepo.savedLoginDetails = RealmLoginDetails(from: user)
        mockLoginRepo.savedLoginDetails?.isLoggedIn = true
        
        // Act
        let loggedInData = try await userDataStorage.loggedInUserDetails()
        
        // Assert
        XCTAssertNotNil(loggedInData, "Expected logged in user details to be returned.")
        XCTAssertEqual(loggedInData?.user.userId, user.userId, "Expected userID to match.")
    }
    
    func testLoggedInUserDetails_UserIsNotLoggedIn_ReturnsNil() async throws {
        // Arrange
        let user = LoggedInUser.mock(userId: "mockUser")
        mockLoginRepo.savedLoginDetails = RealmLoginDetails(from: user)
        mockLoginRepo.savedLoginDetails?.isLoggedIn = false
        
        // Act
        let loggedInData = try await userDataStorage.loggedInUserDetails()
        
        // Assert
        XCTAssertNil(loggedInData, "Expected nil when user is not logged in.")
    }
    
    func testLoggedInUserDetails_NoData_ReturnsNil() async throws {
        // Arrange
        mockLoginRepo.savedLoginDetails = nil
        
        // Act
        let loggedInData = try await userDataStorage.loggedInUserDetails()
        
        // Assert
        XCTAssertNil(loggedInData, "Expected nil when there are no saved login details.")
    }
    
    // Test login functionality
    func testLogin_Success() async throws {
        // Arrange
        let user = LoggedInUser.mock(userId: "mockUser")
        
        // Act
        try await userDataStorage.login(user)
        
        // Assert
        XCTAssertEqual(mockLoginRepo.savedLoginDetails?.userID, user.userId, "Expected user to be saved.")
        XCTAssertEqual(userDataStorage.token, user.token, "Expected token to be set.")
    }
    
    // Test markUserAsLoggedOut functionality
    func testMarkUserAsLoggedOut_Success() async throws {
        // Arrange
        let user = LoggedInUser.mock(userId: "mockUser")
        mockLoginRepo.savedLoginDetails = RealmLoginDetails(from: user)
        mockLoginRepo.savedLoginDetails?.isLoggedIn = true
        
        // Act
        try await userDataStorage.markUserAsLoggedOut()
        
        // Assert
        XCTAssertFalse(mockLoginRepo.savedLoginDetails?.isLoggedIn ?? true, "Expected user to be marked as logged out.")
        XCTAssertNil(userDataStorage.token, "Expected token to be nil after logout.")
    }
    
    // Test markUserAsLoggedIn functionality
    func testMarkUserAsLoggedIn_Success() async throws {
        // Arrange
        let user = LoggedInUser.mock(userId: "mockUser")
        mockLoginRepo.savedLoginDetails = RealmLoginDetails(from: user)
        mockLoginRepo.savedLoginDetails?.isLoggedIn = false
        
        // Act
        try await userDataStorage.markUserAsLoggedIn()
        
        // Assert
        XCTAssertTrue(mockLoginRepo.savedLoginDetails?.isLoggedIn ?? false, "Expected user to be marked as logged in.")
        XCTAssertEqual(userDataStorage.token, user.token, "Expected token to be set after login.")
    }
    
    func testMarkUserAsLoggedIn_NoData_DoesNothing() async throws {
        // Arrange
        mockLoginRepo.savedLoginDetails = nil
        
        // Act
        try await userDataStorage.markUserAsLoggedIn()
        
        // Assert
        XCTAssertNil(userDataStorage.token, "Expected token to still be nil.")
    }
}
