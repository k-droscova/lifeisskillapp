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
    
    func testLogin_Success() async throws {
        // Arrange
        let user = LoggedInUser.mock(userId: "mockUser")
        
        // Act
        try await userDataStorage.login(user)
        
        // Assert
        XCTAssertEqual(mockLoginRepo.savedLoginDetails?.userID, user.userId, "Expected user to be saved.")
    }
    
    func testMarkUserAsLoggedOut_Success() async throws {
        // Arrange
        let user = LoggedInUser.mock(userId: "mockUser")
        mockLoginRepo.savedLoginDetails = RealmLoginDetails(from: user)
        mockLoginRepo.savedLoginDetails?.isLoggedIn = true
        
        // Act
        try await userDataStorage.markUserAsLoggedOut()
        
        // Assert
        XCTAssertFalse(mockLoginRepo.savedLoginDetails?.isLoggedIn ?? true, "Expected user to be marked as logged out.")
    }
    
    func testMarkUserAsLoggedIn_Success() async throws {
        // Arrange
        let user = LoggedInUser.mock(userId: "mockUser")
        mockLoginRepo.savedLoginDetails = RealmLoginDetails(from: user)
        mockLoginRepo.savedLoginDetails?.isLoggedIn = false
        
        // Act
        try await userDataStorage.markUserAsLoggedIn()
        
        // Assert
        XCTAssertTrue(mockLoginRepo.savedLoginDetails?.isLoggedIn ?? false, "Expected user to be marked as logged in.")
    }
    
    func testMarkUserAsLoggedIn_NoData_DoesNothing() async throws {
        // Arrange
        mockLoginRepo.savedLoginDetails = nil
        
        // Act
        try await userDataStorage.markUserAsLoggedIn()
        
        // Assert
        XCTAssertNil(mockLoginRepo.savedLoginDetails, "Expected logged in data to still be nil.")
    }
}

// MARK: - Testing Public Interface Getting Methods

extension RealmUserDataStorageTests {
    func testUserCategoryData_Success() async throws {
        // Arrange
        let expectedCategoryData = UserCategoryData.mock()
        mockCategoryRepo.savedCategoryData = RealmUserCategoryData(from: expectedCategoryData)
        
        // Act
        let categoryData = try await userDataStorage.userCategoryData()
        
        // Assert
        XCTAssertNotNil(categoryData)
        XCTAssertEqual(categoryData?.data.count, expectedCategoryData.data.count)
    }
    
    func testUserPointData_Success() async throws {
        // Arrange
        let expectedPointData = UserPointData.mock()
        mockUserPointRepo.savedUserPointData = RealmUserPointData(from: expectedPointData)
        
        // Act
        let pointData = try await userDataStorage.userPointData()
        
        // Assert
        XCTAssertNotNil(pointData)
        XCTAssertEqual(pointData?.data.count, expectedPointData.data.count)
    }
    
    func testUserRankData_Success() async throws {
        // Arrange
        let expectedRankData = UserRankData.mock()
        mockRankingRepo.savedRankData = RealmUserRankData(from: expectedRankData)
        
        // Act
        let rankData = try await userDataStorage.userRankData()
        
        // Assert
        XCTAssertNotNil(rankData)
        XCTAssertEqual(rankData?.data.count, expectedRankData.data.count)
    }
    
    func testGenericPointData_Success() async throws {
        // Arrange
        let expectedPointData = GenericPointData.mock()
        mockGenericPointRepo.savedGenericPointData = RealmGenericPointData(from: expectedPointData)
        
        // Act
        let pointData = try await userDataStorage.genericPointData()
        
        // Assert
        XCTAssertNotNil(pointData)
        XCTAssertEqual(pointData?.data.count, expectedPointData.data.count)
    }
    
    
    func testCheckSumData_Success() async throws {
        // Arrange
        let expectedCheckSumData = CheckSumData.mock()
        mockCheckSumRepo.savedCheckSumData = RealmCheckSumData(from: expectedCheckSumData)
        
        // Act
        let checkSumData = try await userDataStorage.checkSumData()
        
        // Assert
        XCTAssertNotNil(checkSumData)
        XCTAssertEqual(checkSumData?.userPoints, expectedCheckSumData.userPoints)
    }
    
    func testScannedPoints_Success() async throws {
        // Arrange
        let expectedPoints = [RealmScannedPoint(from: ScannedPoint.mock()), RealmScannedPoint(from: ScannedPoint.mock())]
        mockScannedPointRepo.savedScannedPoints = expectedPoints
        
        // Act
        let scannedPoints = try await userDataStorage.scannedPoints()
        
        // Assert
        XCTAssertEqual(scannedPoints.count, expectedPoints.count)
    }
    
    func testSponsorImage_Success() async throws {
        // Arrange
        let sponsorId = "mockSponsorID"
        let expectedImageData = Data([0x00, 0x01, 0x02])
        mockSponsorRepo.savedSponsorData = [RealmSponsorData(sponsorID: sponsorId, imageData: expectedImageData)]
        
        // Act
        let imageData = try await userDataStorage.sponsorImage(for: sponsorId)
        
        // Assert
        XCTAssertEqual(imageData, expectedImageData)
    }
    
    func testSponsorImage_NoData_ReturnsNil() async throws {
        // Arrange
        let sponsorId = "nonExistingID"
        
        // Act
        let imageData = try await userDataStorage.sponsorImage(for: sponsorId)
        
        // Assert
        XCTAssertNil(imageData, "Expected nil for a non-existing sponsor ID.")
    }
    
    // MARK: error cases
    
    func testUserCategoryData_Error() async throws {
        // Arrange
        mockCategoryRepo.shouldThrowError = true
        
        // Act & Assert
        do {
            _ = try await userDataStorage.userCategoryData()
            XCTFail("Expected an error to be thrown.")
        } catch let error as MockRepositoryError {
            XCTAssertEqual(error, .forcedError, "Expected forcedError from mock repository.")
        } catch {
            XCTFail("Expected a MockRepositoryError to be thrown.")
        }
    }
    
    func testUserPointData_Error() async throws {
        // Arrange
        mockUserPointRepo.shouldThrowError = true
        
        // Act & Assert
        do {
            _ = try await userDataStorage.userPointData()
            XCTFail("Expected an error to be thrown.")
        } catch let error as MockRepositoryError {
            XCTAssertEqual(error, .forcedError, "Expected forcedError from mock repository.")
        } catch {
            XCTFail("Expected a MockRepositoryError to be thrown.")
        }
    }
    
    func testUserRankData_Error() async throws {
        // Arrange
        mockRankingRepo.shouldThrowError = true
        
        // Act & Assert
        do {
            _ = try await userDataStorage.userRankData()
            XCTFail("Expected an error to be thrown.")
        } catch let error as MockRepositoryError {
            XCTAssertEqual(error, .forcedError, "Expected forcedError from mock repository.")
        } catch {
            XCTFail("Expected a MockRepositoryError to be thrown.")
        }
    }
    
    func testGenericPointData_Error() async throws {
        // Arrange
        mockGenericPointRepo.shouldThrowError = true
        
        // Act & Assert
        do {
            _ = try await userDataStorage.genericPointData()
            XCTFail("Expected an error to be thrown.")
        } catch let error as MockRepositoryError {
            XCTAssertEqual(error, .forcedError, "Expected forcedError from mock repository.")
        } catch {
            XCTFail("Expected a MockRepositoryError to be thrown.")
        }
    }
    
    func testCheckSumData_Error() async throws {
        // Arrange
        mockCheckSumRepo.shouldThrowError = true
        
        // Act & Assert
        do {
            _ = try await userDataStorage.checkSumData()
            XCTFail("Expected an error to be thrown.")
        } catch let error as MockRepositoryError {
            XCTAssertEqual(error, .forcedError, "Expected forcedError from mock repository.")
        } catch {
            XCTFail("Expected a MockRepositoryError to be thrown.")
        }
    }
    
    func testScannedPoints_Error() async throws {
        // Arrange
        mockScannedPointRepo.shouldThrowError = true
        
        // Act & Assert
        do {
            _ = try await userDataStorage.scannedPoints()
            XCTFail("Expected an error to be thrown.")
        } catch let error as MockRepositoryError {
            XCTAssertEqual(error, .forcedError, "Expected forcedError from mock repository.")
        } catch {
            XCTFail("Expected a MockRepositoryError to be thrown.")
        }
    }
    
    func testSponsorImage_Error() async throws {
        // Arrange
        mockSponsorRepo.shouldThrowError = true
        let sponsorId = "mockSponsorID"
        
        // Act & Assert
        do {
            _ = try await userDataStorage.sponsorImage(for: sponsorId)
            XCTFail("Expected an error to be thrown.")
        } catch let error as MockRepositoryError {
            XCTAssertEqual(error, .forcedError, "Expected forcedError from mock repository.")
        } catch {
            XCTFail("Expected a MockRepositoryError to be thrown.")
        }
    }
}

// MARK: - Testing Public Interface Saving Methods

extension RealmUserDataStorageTests {
    
    func testSaveUserCategoryData_Success() async throws {
        // Arrange
        let expectedCategoryData = UserCategoryData.mock()
        
        // Act
        try await userDataStorage.saveUserCategoryData(expectedCategoryData)
        
        // Assert
        XCTAssertEqual(mockCategoryRepo.savedCategoryData?.allCategories.count, expectedCategoryData.data.count)
        XCTAssertEqual(mockCategoryRepo.savedCategoryData?.mainCategory?.categoryID, expectedCategoryData.main.id)
    }
    
    func testSaveUserCategoryData_NilData_DeletesAll() async throws {
        // Arrange
        mockCategoryRepo.savedCategoryData = RealmUserCategoryData(from: UserCategoryData.mock())
        
        // Act
        try await userDataStorage.saveUserCategoryData(nil)
        
        // Assert
        XCTAssertNil(mockCategoryRepo.savedCategoryData, "Category Data should be deleted when saving nil")
    }
    
    func testSaveUserPointData_Success() async throws {
        // Arrange
        let expectedPointData = UserPointData.mock()
        
        // Act
        try await userDataStorage.saveUserPointData(expectedPointData)
        
        // Assert
        XCTAssertEqual(mockUserPointRepo.savedUserPointData?.data.count, expectedPointData.data.count)
        XCTAssertEqual(mockUserPointRepo.savedUserPointData?.checkSum, expectedPointData.checkSum)
    }
    
    func testSaveUserPointData_NilData_DeletesAll() async throws {
        // Arrange
        mockUserPointRepo.savedUserPointData = RealmUserPointData(from: UserPointData.mock())
        
        // Act
        try await userDataStorage.saveUserPointData(nil)
        
        // Assert
        XCTAssertNil(mockUserPointRepo.savedUserPointData, "User Point Data should be deleted when saving nil")
    }
    
    func testSaveGenericPointData_Success() async throws {
        // Arrange
        let expectedPointData = GenericPointData.mock()
        
        // Act
        try await userDataStorage.saveGenericPointData(expectedPointData)
        
        // Assert
        XCTAssertEqual(mockGenericPointRepo.savedGenericPointData?.data.count, expectedPointData.data.count)
        XCTAssertEqual(mockGenericPointRepo.savedGenericPointData?.checkSum, expectedPointData.checkSum)
    }
    
    func testSaveGenericPointData_NilData_DeletesAll() async throws {
        // Arrange
        mockGenericPointRepo.savedGenericPointData = RealmGenericPointData(from: GenericPointData.mock())
        
        // Act
        try await userDataStorage.saveGenericPointData(nil)
        
        // Assert
        XCTAssertNil(mockGenericPointRepo.savedGenericPointData, "Generic Point Data should be deleted when saving nil")
    }
    
    func testSaveUserRankData_Success() async throws {
        // Arrange
        let expectedRankData = UserRankData.mock()
        
        // Act
        try await userDataStorage.saveUserRankData(expectedRankData)
        
        // Assert
        XCTAssertEqual(mockRankingRepo.savedRankData?.data.count, expectedRankData.data.count)
        XCTAssertEqual(mockRankingRepo.savedRankData?.checkSum, expectedRankData.checkSum)
    }
    
    func testSaveUserRankData_NilData_DeletesAll() async throws {
        // Arrange
        mockRankingRepo.savedRankData = RealmUserRankData(from: UserRankData.mock())
        
        // Act
        try await userDataStorage.saveUserRankData(nil)
        
        // Assert
        XCTAssertNil(mockRankingRepo.savedRankData, "User Rank Data should be deleted when saving nil")
    }
    
    func testSaveCheckSumData_Success() async throws {
        // Arrange
        let expectedCheckSumData = CheckSumData.mock()
        
        // Act
        try await userDataStorage.saveCheckSumData(expectedCheckSumData)
        
        // Assert
        XCTAssertEqual(mockCheckSumRepo.savedCheckSumData?.userPoints, expectedCheckSumData.userPoints)
        XCTAssertEqual(mockCheckSumRepo.savedCheckSumData?.rank, expectedCheckSumData.rank)
    }
    
    func testSaveCheckSumData_NilData_DeletesAll() async throws {
        // Arrange
        mockCheckSumRepo.savedCheckSumData = RealmCheckSumData(from: CheckSumData.mock())
        
        // Act
        try await userDataStorage.saveCheckSumData(nil)
        
        // Assert
        XCTAssertNil(mockCheckSumRepo.savedCheckSumData, "CheckSum Data should be deleted when saving nil")
    }
    
    func testSaveScannedPoint_Success() async throws {
        // Arrange
        let scannedPoint = ScannedPoint.mock()
        
        // Act
        try await userDataStorage.saveScannedPoint(scannedPoint)
        
        // Assert
        XCTAssertEqual(mockScannedPointRepo.savedScannedPoints.first?.code, scannedPoint.code, "Expected saved scanned point code to match.")
    }
    
    func testSaveSponsorImage_Success() async throws {
        // Arrange
        let sponsorId = "mockSponsorID"
        let imageData = Data([0x00, 0x01, 0x02])
        
        // Act
        try await userDataStorage.saveSponsorImage(for: sponsorId, imageData: imageData)
        
        // Assert
        XCTAssertEqual(mockSponsorRepo.savedSponsorData.first?.sponsorID, sponsorId, "Expected saved sponsor ID to match.")
        XCTAssertEqual(mockSponsorRepo.savedSponsorData.first?.imageData, imageData, "Expected saved image data to match.")
    }
}

// MARK: - Testing onLogout Method

extension RealmUserDataStorageTests {
    
    func testOnLogout_Success() async throws {
        // Arrange
        let user = LoggedInUser.mock(userId: "mockUser")
        mockLoginRepo.savedLoginDetails = RealmLoginDetails(from: user)
        mockLoginRepo.savedLoginDetails?.isLoggedIn = true
        
        // Act
        try await userDataStorage.onLogout()
        
        // Assert
        XCTAssertFalse(mockLoginRepo.savedLoginDetails?.isLoggedIn ?? true, "Expected user to be marked as logged out.")
    }
}

// MARK: - Testing onLogout Method Error Handling

extension RealmUserDataStorageTests {
    
    func testOnLogout_Error() async throws {
        // Arrange
        let user = LoggedInUser.mock(userId: "mockUser")
        mockLoginRepo.savedLoginDetails = RealmLoginDetails(from: user)
        mockLoginRepo.savedLoginDetails?.isLoggedIn = true
        mockLoginRepo.shouldThrowError = true
        
        // Act & Assert
        do {
            try await userDataStorage.onLogout()
            XCTFail("Expected an error to be thrown.")
        } catch {
            // Assert that the user is still logged in after the error
            XCTAssertTrue(mockLoginRepo.savedLoginDetails?.isLoggedIn ?? false, "Expected user to still be logged in after an error.")
        }
    }
    
    func testOnLogout_UserAlreadyLoggedOut_ThrowsError() async throws {
        // Arrange
        let user = LoggedInUser.mock(userId: "mockUser")
        mockLoginRepo.savedLoginDetails = RealmLoginDetails(from: user)
        mockLoginRepo.savedLoginDetails?.isLoggedIn = false // Simulate the user being logged out
        
        // Act & Assert
        do {
            try await userDataStorage.onLogout()
            XCTFail("Expected an error to be thrown when trying to log out an already logged out user.")
        } catch let error as BaseError {
            XCTAssertEqual(error.message, "No user is currently logged in.", "Expected specific error message.")
        } catch {
            XCTFail("Expected a BaseError to be thrown.")
        }
    }
}

// MARK: - Testing Public Interface Clear Methods

extension RealmUserDataStorageTests {
    
    func testClearUserRelatedData_Success() async throws {
        // Arrange
        let user = LoggedInUser.mock(userId: "mockUser")
        mockLoginRepo.savedLoginDetails = RealmLoginDetails(from: user)
        mockLoginRepo.savedLoginDetails?.isLoggedIn = true
        
        mockCategoryRepo.savedCategoryData = RealmUserCategoryData(from: UserCategoryData.mock())
        mockRankingRepo.savedRankData = RealmUserRankData(from: UserRankData.mock())
        mockUserPointRepo.savedUserPointData = RealmUserPointData(from: UserPointData.mock())
        mockCheckSumRepo.savedCheckSumData = RealmCheckSumData(from: CheckSumData.mock())

        // Act
        try await userDataStorage.clearUserRelatedData()

        // Assert
        XCTAssertNil(mockLoginRepo.savedLoginDetails, "Login details should be cleared.")
        XCTAssertNil(mockCategoryRepo.savedCategoryData, "User category data should be cleared.")
        XCTAssertNil(mockRankingRepo.savedRankData, "User rank data should be cleared.")
        XCTAssertNil(mockUserPointRepo.savedUserPointData, "User point data should be cleared.")
        
        // Checksum data should be preserved, but user-related values should be cleared
        XCTAssertEqual(mockCheckSumRepo.savedCheckSumData?.userPoints, "", "User points in checksum data should be cleared.")
        XCTAssertEqual(mockCheckSumRepo.savedCheckSumData?.rank, "", "Rank in checksum data should be cleared.")
        XCTAssertEqual(mockCheckSumRepo.savedCheckSumData?.messages, "", "Messages in checksum data should be cleared.")
        XCTAssertEqual(mockCheckSumRepo.savedCheckSumData?.events, "", "Events in checksum data should be cleared.")
        XCTAssertEqual(mockCheckSumRepo.savedCheckSumData?.points, mockCheckSumRepo.savedCheckSumData?.points, "Points in checksum data should remain unchanged.")
    }
    
    func testClearScannedPointData_Success() async throws {
        // Arrange
        let expectedPoints = [RealmScannedPoint(from: ScannedPoint.mock()), RealmScannedPoint(from: ScannedPoint.mock())]
        mockScannedPointRepo.savedScannedPoints = expectedPoints
        
        // Act
        try await userDataStorage.clearScannedPointData()

        // Assert
        XCTAssertTrue(mockScannedPointRepo.savedScannedPoints.isEmpty, "Scanned points should be cleared.")
    }
    
    func testClearScannedPointData_Error() async throws {
        // Arrange
        mockScannedPointRepo.shouldThrowError = true
        
        // Act & Assert
        do {
            try await userDataStorage.clearScannedPointData()
            XCTFail("Expected an error to be thrown.")
        } catch let error as MockRepositoryError {
            XCTAssertEqual(error, .forcedError, "Expected forcedError from mock repository.")
        } catch {
            XCTFail("Expected a MockRepositoryError to be thrown.")
        }
    }
}
