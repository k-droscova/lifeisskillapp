//
//  UserDataAPIServiceMock.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 02.10.2024.
//

import Foundation
@testable import lifeisskillapp

final class UserDataAPIServiceMock: UserDataAPIServicing {
    var errorToThrow: Error? = nil
    
    var userCategoriesResponseToReturn: APIResponse<UserCategoryData> = APIResponse(data: UserCategoryData.mock())
    var userPointsResponseToReturn: APIResponse<UserPointData> = APIResponse(data: UserPointData.mock())
    var userRanksResponseToReturn: APIResponse<UserRankData> = APIResponse(data: UserRankData.mock())
    var genericPointsResponseToReturn: APIResponse<GenericPointData> = APIResponse(data: GenericPointData.mock())
    var updateUserPointsResponseToReturn: APIResponse<UserPointData> = APIResponse(data: UserPointData.mock())
    var sponsorImageResponseToReturn: Data = Data()

    // Properties to track method calls and arguments
    var updateUserPointsCalled = false
    var userTokenArgument: String? = nil
    var scannedPointArgument: ScannedPoint? = nil
    
    // Properties to track sponsorImage method calls and arguments
    var sponsorImageCalled = false
    var sponsorImageUserTokenArgument: String? = nil
    var sponsorIdArgument: String? = nil
    var widthArgument: Int? = nil
    var heightArgument: Int? = nil
    
    func userCategories(userToken: String) async throws -> APIResponse<UserCategoryData> {
        guard let error = errorToThrow else {
            return userCategoriesResponseToReturn
        }
        throw error
    }
    
    func userPoints(userToken: String) async throws -> APIResponse<UserPointData> {
        guard let error = errorToThrow else {
            return userPointsResponseToReturn
        }
        throw error
    }
    
    func userRanks(userToken: String) async throws -> APIResponse<UserRankData> {
        guard let error = errorToThrow else {
            return userRanksResponseToReturn
        }
        throw error
    }
    
    func genericPoints(userToken: String) async throws -> APIResponse<GenericPointData> {
        guard let error = errorToThrow else {
            return genericPointsResponseToReturn
        }
        throw error
    }
    
    func updateUserPoints(userToken: String, point: ScannedPoint) async throws -> APIResponse<UserPointData> {
        // Track method call and arguments
        updateUserPointsCalled = true
        userTokenArgument = userToken
        scannedPointArgument = point
        
        guard let error = errorToThrow else {
            return updateUserPointsResponseToReturn
        }
        throw error
    }
    
    func sponsorImage(userToken: String, sponsorId: String, width: Int, height: Int) async throws -> Data {
        // Track method call and arguments
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
