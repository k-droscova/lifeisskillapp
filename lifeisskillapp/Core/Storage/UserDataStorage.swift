//
//  UserDataStorage.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 23.08.2024.
//

import Foundation

protocol HasUserDataStorage {
    var userDataStorage: UserDataStoraging { get set }
}

protocol UserDataStoraging {
    // Storage Interface Based On Different Scenarios
    func onLogout() async throws
    func clearUserRelatedData() async throws
    func clearScannedPointData() async throws
    
    // Storage Savers and Getters
    func userCategoryData() async throws -> UserCategoryData?
    func saveUserCategoryData(_ data: UserCategoryData?) async throws
    func userPointData() async throws -> UserPointData?
    func saveUserPointData(_ data: UserPointData?) async throws
    func userRankData() async throws -> UserRankData?
    func saveUserRankData(_ data: UserRankData?) async throws
    func genericPointData() async throws -> GenericPointData?
    func saveGenericPointData(_ data: GenericPointData?) async throws
    func checkSumData() async throws -> CheckSumData?
    func saveCheckSumData(_ data: CheckSumData?) async throws
    func scannedPoints() async throws -> [ScannedPoint]
    func saveScannedPoint(_ point: ScannedPoint) async throws
    func saveSponsorImage(for sponsorId: String, imageData: Data) async throws
    func sponsorImage(for sponsorId: String) async throws -> Data?
    
    // LOGIN USER DATA RELATED INTERFACE
    func savedLoginDetails() async throws -> LoginUserData?
    func loggedInUserDetails() async throws -> LoginUserData?
    func login(_ user: LoggedInUser) async throws
    func markUserAsLoggedOut() async throws
    func markUserAsLoggedIn() async throws
}
