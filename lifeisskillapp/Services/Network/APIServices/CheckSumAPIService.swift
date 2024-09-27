//
//  CheckSumAPIService.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 15.07.2024.
//

import Foundation

protocol HasCheckSumAPIService {
    var checkSumAPI: CheckSumAPIServicing { get }
}

protocol CheckSumAPIServicing {
    func userPoints() async throws -> APIResponse<CheckSumUserPointsData>
    func userRank() async throws -> APIResponse<CheckSumRankData>
    func userEvents() async throws -> APIResponse<CheckSumEventsData>
    func userMessages() async throws -> APIResponse<CheckSumMessagesData>
    func genericPoints() async throws -> APIResponse<CheckSumPointsData>
}

public final class CheckSumAPIService: BaseClass, CheckSumAPIServicing {
    typealias Dependencies = HasNetwork & HasLoggerServicing & HasPersistentUserDataStoraging
    
    private let network: Networking
    private let logger: LoggerServicing
    private let storage: PersistentUserDataStoraging
    
    private var token: String? { storage.token }
    
    init(dependencies: Dependencies) {
        self.network = dependencies.network
        self.logger = dependencies.logger
        self.storage = dependencies.storage
    }
    
    func userPoints() async throws -> APIResponse<CheckSumUserPointsData> {
        return try await network.performAuthorizedRequest(
            endpoint: Endpoint.userpoints,
            method: .PATCH,
            errorObject: APIResponseError.self,
            userToken: token
        )
    }
    
    func userRank() async throws -> APIResponse<CheckSumRankData> {
        return try await network.performAuthorizedRequest(
            endpoint: Endpoint.rank,
            method: .PATCH,
            errorObject: APIResponseError.self,
            userToken: token
        )
    }
    
    func userEvents() async throws -> APIResponse<CheckSumEventsData> {
        return try await network.performAuthorizedRequest(
            endpoint: Endpoint.events,
            method: .PATCH,
            errorObject: APIResponseError.self,
            userToken: token
        )
    }
    
    func userMessages() async throws -> APIResponse<CheckSumMessagesData> {
        return try await network.performAuthorizedRequest(
            endpoint: Endpoint.messages,
            method: .PATCH,
            errorObject: APIResponseError.self,
            userToken: token
        )
    }
    
    func genericPoints() async throws -> APIResponse<CheckSumPointsData> {
        return try await network.performAuthorizedRequest(
            endpoint: Endpoint.points,
            method: .PATCH,
            errorObject: APIResponseError.self,
            userToken: token
        )
    }
}
