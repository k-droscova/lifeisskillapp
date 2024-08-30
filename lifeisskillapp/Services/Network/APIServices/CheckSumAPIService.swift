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
        let endpoint = Endpoint.userpoints
        return try await network.performAuthorizedRequestWithDataDecoding(
            endpoint: endpoint,
            method: .PATCH,
            errorObject: APIResponseError.self,
            userToken: token
        )
    }
    
    func userRank() async throws -> APIResponse<CheckSumRankData> {
        let endpoint = Endpoint.rank
        return try await network.performAuthorizedRequestWithDataDecoding(
            endpoint: endpoint,
            method: .PATCH,
            errorObject: APIResponseError.self,
            userToken: token
        )
    }
    
    func userEvents() async throws -> APIResponse<CheckSumEventsData> {
        let endpoint = Endpoint.events
        return try await network.performAuthorizedRequestWithDataDecoding(
            endpoint: endpoint,
            method: .PATCH,
            errorObject: APIResponseError.self,
            userToken: token
        )
    }
    
    func userMessages() async throws -> APIResponse<CheckSumMessagesData> {
        let endpoint = Endpoint.messages
        return try await network.performAuthorizedRequestWithDataDecoding(
            endpoint: endpoint,
            method: .PATCH,
            errorObject: APIResponseError.self,
            userToken: token
        )
    }
    
    func genericPoints() async throws -> APIResponse<CheckSumPointsData> {
        let endpoint = Endpoint.points
        return try await network.performAuthorizedRequestWithDataDecoding(
            endpoint: endpoint,
            method: .PATCH,
            errorObject: APIResponseError.self,
            userToken: token
        )
    }
}
