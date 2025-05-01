//
//  UserDataAPIService.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 16.07.2024.
//

import Foundation

protocol HasUserDataAPIService {
    var userDataAPI: UserDataAPIServicing { get }
}

protocol UserDataAPIServicing {
    func userCategories(userToken: String) async throws -> APIResponse<UserCategoryData>
    func userPoints(userToken: String) async throws -> APIResponse<UserPointData>
    func userRanks(userToken: String) async throws -> APIResponse<UserRankData>
    func genericPoints(userToken: String) async throws -> APIResponse<GenericPointData>
    func updateUserPoints(userToken: String, point: ScannedPoint) async throws -> APIResponse<UserPointData>
    func sponsorImage(userToken: String, sponsorId: String, width: Int, height: Int) async throws -> Data
}

final class UserDataAPIService: BaseClass, UserDataAPIServicing {
    typealias Dependencies = HasNetwork & HasLoggerServicing
    
    private let network: Networking
    private let logger: LoggerServicing
    
    init(dependencies: Dependencies) {
        self.network = dependencies.network
        self.logger = dependencies.logger
    }
    
    func userPoints(userToken: String) async throws -> APIResponse<UserPointData> {
        let endpoint = Endpoint.userpoints
        return try await network.performAuthorizedRequest(
            endpoint: endpoint,
            errorObject: APIResponseError.self,
            userToken: userToken
        )
    }
    
    func userCategories(userToken: String) async throws -> APIResponse<UserCategoryData> {
        let endpoint = Endpoint.usercategory
        return try await network.performAuthorizedRequest(
            endpoint: endpoint,
            errorObject: APIResponseError.self,
            userToken: userToken
        )
    }
    
    func userRanks(userToken: String) async throws -> APIResponse<UserRankData> {
        let endpoint = Endpoint.rank
        return try await network.performAuthorizedRequest(
            endpoint: endpoint,
            errorObject: APIResponseError.self,
            userToken: userToken
        )
    }
    
    func genericPoints(userToken: String) async throws -> APIResponse<GenericPointData> {
        let endpoint = Endpoint.points
        return try await network.performAuthorizedRequest(
            endpoint: endpoint,
            errorObject: APIResponseError.self,
            userToken: userToken
        )
    }
    
    func updateUserPoints(userToken: String, point: ScannedPoint) async throws -> APIResponse<UserPointData> {
        let endpoint = Endpoint.userpoints
        let task = ApiTask.postScannedPoint(point: point)
        let data = try task.encodeParams()
        return try await network.performAuthorizedRequest(
            endpoint: endpoint,
            method: .POST,
            body: data,
            errorObject: APIResponseError.self,
            userToken: userToken
        )
    }
    
    func sponsorImage(userToken: String, sponsorId: String, width: Int, height: Int) async throws -> Data {
        let endpoint = Endpoint.sponsorImage(sponsorId: sponsorId, width: width, height: height)
        return try await network.performAuthorizedRequest(
            endpoint: endpoint,
            errorObject: APIResponseError.self,
            userToken: userToken
        )
    }
}
