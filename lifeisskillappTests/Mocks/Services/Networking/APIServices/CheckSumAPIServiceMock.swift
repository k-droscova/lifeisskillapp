//
//  CheckSumAPIServiceMock.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 02.10.2024.
//

import Foundation
@testable import lifeisskillapp

final class CheckSumAPIServiceMock: CheckSumAPIServicing {
    var errorToThrow: Error? = nil
    
    var userPointsResponseToReturn: APIResponse<CheckSumUserPointsData> = APIResponse(data: CheckSumUserPointsData.mock())
    var userRankResponseToReturn: APIResponse<CheckSumRankData> = APIResponse(data: CheckSumRankData.mock())
    var userEventsResponseToReturn: APIResponse<CheckSumEventsData> = APIResponse(data: CheckSumEventsData.mock())
    var userMessagesResponseToReturn: APIResponse<CheckSumMessagesData> = APIResponse(data: CheckSumMessagesData.mock())
    var genericPointsResponseToReturn: APIResponse<CheckSumPointsData> = APIResponse(data: CheckSumPointsData.mock())
    
    func userPoints() async throws -> APIResponse<CheckSumUserPointsData> {
        guard let error = errorToThrow else {
            return userPointsResponseToReturn
        }
        throw error
    }
    
    func userRank() async throws -> APIResponse<CheckSumRankData> {
        guard let error = errorToThrow else {
            return userRankResponseToReturn
        }
        throw error
    }
    
    func userEvents() async throws -> APIResponse<CheckSumEventsData> {
        guard let error = errorToThrow else {
            return userEventsResponseToReturn
        }
        throw error
    }
    
    func userMessages() async throws -> APIResponse<CheckSumMessagesData> {
        guard let error = errorToThrow else {
            return userMessagesResponseToReturn
        }
        throw error
    }
    
    func genericPoints() async throws -> APIResponse<CheckSumPointsData> {
        guard let error = errorToThrow else {
            return genericPointsResponseToReturn
        }
        throw error
    }
}
