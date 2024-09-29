//
//  PersistentUserDataStorageMock.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 29.09.2024.
//

@testable import lifeisskillapp
import Foundation

final class PersistentUserDataStorageMock: PersistentUserDataStoraging {
    // Properties to mock values
    var mockToken: String? = nil
    var mockIsLoggedIn: Bool = false
    var imageData: Data? = nil
    var mockLoggedInUser: LoggedInUser? = nil
    
    // MARK: - Token and Login Status
    var token: String? {
        mockToken
    }
    
    var isLoggedIn: Bool {
        mockIsLoggedIn
    }

    // MARK: - UserDataStoraging Conformance
    func onLogin() async throws {
        print("onLogin() called")
    }

    func onLogout() async throws {
        print("onLogout() called")
    }

    func clearUserRelatedData() async throws {
        print("clearUserRelatedData() called")
    }

    func clearScannedPointData() async throws {
        print("clearScannedPointData() called")
    }

    // MARK: - Mock Storage Getters and Setters
    var mockUserCategoryData: UserCategoryData?
    var mockUserPointData: UserPointData?
    var mockUserRankData: UserRankData?
    var mockGenericPointData: GenericPointData?
    var mockCheckSumData: CheckSumData?
    var mockScannedPoints: [ScannedPoint] = []
    
    func userCategoryData() async throws -> UserCategoryData? {
        mockUserCategoryData
    }

    func saveUserCategoryData(_ data: UserCategoryData?) async throws {
        mockUserCategoryData = data
    }

    func userPointData() async throws -> UserPointData? {
        mockUserPointData
    }

    func saveUserPointData(_ data: UserPointData?) async throws {
        mockUserPointData = data
    }

    func userRankData() async throws -> UserRankData? {
        mockUserRankData
    }

    func saveUserRankData(_ data: UserRankData?) async throws {
        mockUserRankData = data
    }

    func genericPointData() async throws -> GenericPointData? {
        mockGenericPointData
    }

    func saveGenericPointData(_ data: GenericPointData?) async throws {
        mockGenericPointData = data
    }

    func checkSumData() async throws -> CheckSumData? {
        mockCheckSumData
    }

    func saveCheckSumData(_ data: CheckSumData?) async throws {
        mockCheckSumData = data
    }

    func scannedPoints() async throws -> [ScannedPoint] {
        mockScannedPoints
    }

    func saveScannedPoint(_ point: ScannedPoint) async throws {
        mockScannedPoints.append(point)
    }

    func saveSponsorImage(for sponsorId: String, imageData: Data) async throws {
        print("saveSponsorImage() called for sponsorId: \(sponsorId)")
    }

    func sponsorImage(for sponsorId: String) async throws -> Data? {
        print("sponsorImage() called for sponsorId: \(sponsorId)")
        return imageData
    }

    // MARK: - Login User Data Related Interface
    var mockLoginDetails: LoginUserData?
    var mockLoggedInUserDetails: LoginUserData?
    
    func savedLoginDetails() async throws -> LoginUserData? {
        mockLoginDetails
    }

    func loggedInUserDetails() async throws -> LoginUserData? {
        mockLoggedInUserDetails
    }

    func login(_ user: LoggedInUser) async throws {
        print("login() called with user: \(user)")
        mockLoggedInUser = user
    }

    func markUserAsLoggedOut() async throws {
        print("markUserAsLoggedOut() called")
        mockIsLoggedIn = false
        mockLoggedInUser = nil
    }

    func markUserAsLoggedIn() async throws {
        print("markUserAsLoggedIn() called")
        mockIsLoggedIn = true
    }

    // MARK: - PersistentUserDataStoraging Conformance
    func loadAllDataFromRepositories() async throws {
        print("loadAllDataFromRepositories() called")
    }

    func loadFromRepository(for data: PersistentDataType) async throws {
        print("loadFromRepository() called for data type: \(data)")
    }
}
