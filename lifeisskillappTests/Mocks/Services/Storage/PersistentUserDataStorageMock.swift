//
//  PersistentUserDataStorageMock.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 29.09.2024.
//

@testable import lifeisskillapp
import Foundation

final class PersistentUserDataStorageMock: PersistentUserDataStoraging {
    var errorToThrow: Error? = nil

    // MARK: - Call Tracking Variables
    var onLogoutCalled = false
    var clearUserRelatedDataCalled = false
    var clearScannedPointDataCalled = false
    var saveUserCategoryDataCalled = false
    var saveUserPointDataCalled = false
    var saveUserRankDataCalled = false
    var saveGenericPointDataCalled = false
    var saveCheckSumDataCalled = false
    var saveScannedPointCalled = false
    var saveSponsorImageCalled = false
    var sponsorImageCalled = false
    var savedLoginDetailsCalled = false
    var loggedInUserDetailsCalled = false
    var loginCalled = false
    var markUserAsLoggedOutCalled = false
    var markUserAsLoggedInCalled = false
    var loadAllDataFromRepositoriesCalled = false
    var loadFromRepositoryCalled = false

    // MARK: - Argument Tracking Variables
    var userCategoryDataArgument: UserCategoryData? = nil
    var userPointDataArgument: UserPointData? = nil
    var userRankDataArgument: UserRankData? = nil
    var genericPointDataArgument: GenericPointData? = nil
    var checkSumDataArgument: CheckSumData? = nil
    var scannedPointArgument: ScannedPoint? = nil
    var sponsorIdArgument: String? = nil
    var sponsorImageDataArgument: Data? = nil
    var loginUserArgument: LoggedInUser? = nil
    var persistentDataTypeArgument: PersistentDataType? = nil

    // MARK: - Mock Data
    var mockIsLoggedIn: Bool = false
    var mockUserCategoryData: UserCategoryData?
    var mockUserPointData: UserPointData?
    var mockUserRankData: UserRankData?
    var mockGenericPointData: GenericPointData?
    var mockCheckSumData: CheckSumData?
    var mockScannedPoints: [ScannedPoint] = []
    var imageData: Data? = nil
    var mockLoginDetails: LoginUserData?
    var mockLoggedInUserDetails: LoginUserData?
    var mockLoggedInUser: LoggedInUser? = nil

    var isLoggedIn: Bool {
        mockIsLoggedIn
    }

    // MARK: - UserDataStoraging Conformance

    func onLogout() async throws {
        onLogoutCalled = true
        guard let error = errorToThrow else { return }
        throw error
    }

    func clearUserRelatedData() async throws {
        clearUserRelatedDataCalled = true
        guard let error = errorToThrow else { return }
        throw error
    }

    func clearScannedPointData() async throws {
        clearScannedPointDataCalled = true
        guard let error = errorToThrow else { return }
        throw error
    }

    // MARK: - Mock Storage Getters and Setters

    func userCategoryData() async throws -> UserCategoryData? {
        guard let error = errorToThrow else {
            return mockUserCategoryData
        }
        throw error
    }

    func saveUserCategoryData(_ data: UserCategoryData?) async throws {
        saveUserCategoryDataCalled = true
        userCategoryDataArgument = data
        guard let error = errorToThrow else {
            mockUserCategoryData = data
            return
        }
        throw error
    }

    func userPointData() async throws -> UserPointData? {
        guard let error = errorToThrow else {
            return mockUserPointData
        }
        throw error
    }

    func saveUserPointData(_ data: UserPointData?) async throws {
        saveUserPointDataCalled = true
        userPointDataArgument = data
        guard let error = errorToThrow else {
            mockUserPointData = data
            return
        }
        throw error
    }

    func userRankData() async throws -> UserRankData? {
        guard let error = errorToThrow else {
            return mockUserRankData
        }
        throw error
    }

    func saveUserRankData(_ data: UserRankData?) async throws {
        saveUserRankDataCalled = true
        userRankDataArgument = data
        guard let error = errorToThrow else {
            mockUserRankData = data
            return
        }
        throw error
    }

    func genericPointData() async throws -> GenericPointData? {
        guard let error = errorToThrow else {
            return mockGenericPointData
        }
        throw error
    }

    func saveGenericPointData(_ data: GenericPointData?) async throws {
        saveGenericPointDataCalled = true
        genericPointDataArgument = data
        guard let error = errorToThrow else {
            mockGenericPointData = data
            return
        }
        throw error
    }

    func checkSumData() async throws -> CheckSumData? {
        guard let error = errorToThrow else {
            return mockCheckSumData
        }
        throw error
    }

    func saveCheckSumData(_ data: CheckSumData?) async throws {
        saveCheckSumDataCalled = true
        checkSumDataArgument = data
        guard let error = errorToThrow else {
            mockCheckSumData = data
            return
        }
        throw error
    }

    func scannedPoints() async throws -> [ScannedPoint] {
        guard let error = errorToThrow else {
            return mockScannedPoints
        }
        throw error
    }

    func saveScannedPoint(_ point: ScannedPoint) async throws {
        saveScannedPointCalled = true
        scannedPointArgument = point
        guard let error = errorToThrow else {
            mockScannedPoints.append(point)
            return
        }
        throw error
    }

    // MARK: - Sponsor Image Methods

    func saveSponsorImage(for sponsorId: String, imageData: Data) async throws {
        saveSponsorImageCalled = true
        sponsorIdArgument = sponsorId
        sponsorImageDataArgument = imageData
        guard let error = errorToThrow else {
            self.imageData = imageData
            return
        }
        throw error
    }

    func sponsorImage(for sponsorId: String) async throws -> Data? {
        sponsorImageCalled = true
        sponsorIdArgument = sponsorId
        guard let error = errorToThrow else {
            return imageData
        }
        throw error
    }

    // MARK: - Login User Data Related Interface

    func savedLoginDetails() async throws -> LoginUserData? {
        savedLoginDetailsCalled = true
        guard let error = errorToThrow else {
            return mockLoginDetails
        }
        throw error
    }

    func loggedInUserDetails() async throws -> LoginUserData? {
        loggedInUserDetailsCalled = true
        guard let error = errorToThrow else {
            return mockLoggedInUserDetails
        }
        throw error
    }

    func login(_ user: LoggedInUser) async throws {
        loginCalled = true
        loginUserArgument = user
        guard let error = errorToThrow else {
            mockLoggedInUser = user
            return
        }
        throw error
    }

    func markUserAsLoggedOut() async throws {
        markUserAsLoggedOutCalled = true
        guard let error = errorToThrow else {
            mockIsLoggedIn = false
            mockLoggedInUser = nil
            return
        }
        throw error
    }

    func markUserAsLoggedIn() async throws {
        markUserAsLoggedInCalled = true
        guard let error = errorToThrow else {
            mockIsLoggedIn = true
            return
        }
        throw error
    }

    // MARK: - PersistentUserDataStoraging Conformance

    func loadAllDataFromRepositories() async throws {
        loadAllDataFromRepositoriesCalled = true
        guard let error = errorToThrow else {
            return
        }
        throw error
    }

    func loadFromRepository(for data: PersistentDataType) async throws {
        loadFromRepositoryCalled = true
        persistentDataTypeArgument = data
        guard let error = errorToThrow else {
            return
        }
        throw error
    }
}
