//
//  UserDataAPIServiceMock.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 02.10.2024.
//

import Foundation
@testable import lifeisskillapp

final class UserDataAPIServiceMock: UserDataAPIServicing {
    
    // MARK: - Properties for Error Simulation
    var errorToThrow: Error? = nil

    // MARK: - Mocked API Responses
    var userCategoriesResponseToReturn: APIResponse<UserCategoryData> = APIResponse(data: UserCategoryData.mock())
    var userPointsResponseToReturn: APIResponse<UserPointData> = APIResponse(data: UserPointData.mock())
    var userRanksResponseToReturn: APIResponse<UserRankData> = APIResponse(data: UserRankData.mock())
    var genericPointsResponseToReturn: APIResponse<GenericPointData> = APIResponse(data: GenericPointData.mock())
    var updateUserPointsResponseToReturn: APIResponse<UserPointData> = APIResponse(data: UserPointData.mock())
    var sponsorImageResponseToReturn: Data = Data()

    // MARK: - Tracking Call Flags and Arguments
    var userCategoriesCalled = false
    var userPointsCalled = false
    var userRanksCalled = false
    var genericPointsCalled = false
    var updateUserPointsCalled = false
    var sponsorImageCalled = false

    // Arguments to track the tokens and other parameters passed to the methods
    var userTokenArgument: String? = nil
    var scannedPointArgument: ScannedPoint? = nil
    var sponsorImageUserTokenArgument: String? = nil
    var sponsorIdArgument: String? = nil
    var widthArgument: Int? = nil
    var heightArgument: Int? = nil
    
    // MARK: - Mock Methods for UserDataAPIServicing

    func userCategories(userToken: String) async throws -> APIResponse<UserCategoryData> {
        userCategoriesCalled = true
        userTokenArgument = userToken
        
        guard let error = errorToThrow else {
            return userCategoriesResponseToReturn
        }
        throw error
    }
    
    func userPoints(userToken: String) async throws -> APIResponse<UserPointData> {
        userPointsCalled = true
        userTokenArgument = userToken
        
        guard let error = errorToThrow else {
            return userPointsResponseToReturn
        }
        throw error
    }
    
    func userRanks(userToken: String) async throws -> APIResponse<UserRankData> {
        userRanksCalled = true
        userTokenArgument = userToken
        
        guard let error = errorToThrow else {
            return userRanksResponseToReturn
        }
        throw error
    }
    
    func genericPoints(userToken: String) async throws -> APIResponse<GenericPointData> {
        genericPointsCalled = true
        userTokenArgument = userToken
        
        guard let error = errorToThrow else {
            return genericPointsResponseToReturn
        }
        throw error
    }
    
    func updateUserPoints(userToken: String, point: ScannedPoint) async throws -> APIResponse<UserPointData> {
        updateUserPointsCalled = true
        userTokenArgument = userToken
        scannedPointArgument = point
        
        guard let error = errorToThrow else {
            return updateUserPointsResponseToReturn
        }
        throw error
    }
    
    func sponsorImage(userToken: String, sponsorId: String, width: Int, height: Int) async throws -> Data {
        sponsorImageCalled = true
        sponsorImageUserTokenArgument = userToken
        sponsorIdArgument = sponsorId
        widthArgument = width
        heightArgument = height
        
        guard let error = errorToThrow else {
            return sponsorImageResponseToReturn
        }
        throw error
    }
}
