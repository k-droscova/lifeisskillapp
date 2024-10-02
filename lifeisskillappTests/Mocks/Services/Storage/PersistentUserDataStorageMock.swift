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
    
    var mockToken: String? = nil
    var mockIsLoggedIn: Bool = false
    var imageData: Data? = nil
    var mockLoggedInUser: LoggedInUser? = nil
    
    var token: String? {
        mockToken
    }
    
    var isLoggedIn: Bool {
        mockIsLoggedIn
    }

    // MARK: - UserDataStoraging Conformance
    func onLogin() async throws {
        guard let error = errorToThrow else {
            print("onLogin() called")
            return
        }
        throw error
    }

    func onLogout() async throws {
        guard let error = errorToThrow else {
            print("onLogout() called")
            return
        }
        throw error
    }

    func clearUserRelatedData() async throws {
        guard let error = errorToThrow else {
            print("clearUserRelatedData() called")
            return
        }
        throw error
    }

    func clearScannedPointData() async throws {
        guard let error = errorToThrow else {
            print("clearScannedPointData() called")
            return
        }
        throw error
    }

    // MARK: - Mock Storage Getters and Setters
    var mockUserCategoryData: UserCategoryData?
    var mockUserPointData: UserPointData?
    var mockUserRankData: UserRankData?
    var mockGenericPointData: GenericPointData?
    var mockCheckSumData: CheckSumData?
    var mockScannedPoints: [ScannedPoint] = []
    
    func userCategoryData() async throws -> UserCategoryData? {
        guard let error = errorToThrow else {
            return mockUserCategoryData
        }
        throw error
    }

    func saveUserCategoryData(_ data: UserCategoryData?) async throws {
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
        guard let error = errorToThrow else {
            mockScannedPoints.append(point)
            return
        }
        throw error
    }

    func saveSponsorImage(for sponsorId: String, imageData: Data) async throws {
        guard let error = errorToThrow else {
            print("saveSponsorImage() called for sponsorId: \(sponsorId)")
            return
        }
        throw error
    }

    func sponsorImage(for sponsorId: String) async throws -> Data? {
        guard let error = errorToThrow else {
            print("sponsorImage() called for sponsorId: \(sponsorId)")
            return imageData
        }
        throw error
    }

    // MARK: - Login User Data Related Interface
    var mockLoginDetails: LoginUserData?
    var mockLoggedInUserDetails: LoginUserData?
    
    func savedLoginDetails() async throws -> LoginUserData? {
        guard let error = errorToThrow else {
            return mockLoginDetails
        }
        throw error
    }

    func loggedInUserDetails() async throws -> LoginUserData? {
        guard let error = errorToThrow else {
            return mockLoggedInUserDetails
        }
        throw error
    }

    func login(_ user: LoggedInUser) async throws {
        guard let error = errorToThrow else {
            print("login() called with user: \(user)")
            mockLoggedInUser = user
            return
        }
        throw error
    }

    func markUserAsLoggedOut() async throws {
        guard let error = errorToThrow else {
            print("markUserAsLoggedOut() called")
            mockIsLoggedIn = false
            mockLoggedInUser = nil
            return
        }
        throw error
    }

    func markUserAsLoggedIn() async throws {
        guard let error = errorToThrow else {
            print("markUserAsLoggedIn() called")
            mockIsLoggedIn = true
            return
        }
        throw error
    }

    // MARK: - PersistentUserDataStoraging Conformance
    func loadAllDataFromRepositories() async throws {
        guard let error = errorToThrow else {
            print("loadAllDataFromRepositories() called")
            return
        }
        throw error
    }

    func loadFromRepository(for data: PersistentDataType) async throws {
        guard let error = errorToThrow else {
            print("loadFromRepository() called for data type: \(data)")
            return
        }
        throw error
    }
}
