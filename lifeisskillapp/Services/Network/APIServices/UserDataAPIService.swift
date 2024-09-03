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

protocol UserDataAPIServicing: APITasking {
    func userCategories(userToken: String) async throws -> APIResponse<UserCategoryData>
    func userPoints(userToken: String) async throws -> APIResponse<UserPointData>
    func userRanks(userToken: String) async throws -> APIResponse<UserRankData>
    func genericPoints(userToken: String) async throws -> APIResponse<GenericPointData>
    func updateUserPoints(userToken: String, point: ScannedPoint) async throws -> APIResponse<UserPointData>
    func sponsorImage(userToken: String, sponsorId: String, width: Int, height: Int) async throws -> Data
}

public final class UserDataAPIService: BaseClass, UserDataAPIServicing {
    typealias Dependencies = HasNetwork & HasLoggerServicing
    
    private let network: Networking
    private let logger: LoggerServicing
    
    var task = ApiTask.userPoints
    
    init(dependencies: Dependencies) {
        self.network = dependencies.network
        self.logger = dependencies.logger
    }
    
    func userPoints(userToken: String) async throws -> APIResponse<UserPointData> {
        let endpoint = Endpoint.userpoints
        return try await network.performAuthorizedRequestWithDataDecoding(
            endpoint: endpoint,
            errorObject: APIResponseError.self,
            userToken: userToken
        )
    }
    
    func userCategories(userToken: String) async throws -> APIResponse<UserCategoryData> {
        let endpoint = Endpoint.usercategory
        return try await network.performAuthorizedRequestWithDataDecoding(
            endpoint: endpoint,
            errorObject: APIResponseError.self,
            userToken: userToken
        )
    }
    
    func userRanks(userToken: String) async throws -> APIResponse<UserRankData> {
        let endpoint = Endpoint.rank
        return try await network.performAuthorizedRequestWithDataDecoding(
            endpoint: endpoint,
            errorObject: APIResponseError.self,
            userToken: userToken
        )
    }
    
    func genericPoints(userToken: String) async throws -> APIResponse<GenericPointData> {
        let endpoint = Endpoint.points
        return try await network.performAuthorizedRequestWithDataDecoding(
            endpoint: endpoint,
            errorObject: APIResponseError.self,
            userToken: userToken
        )
    }
    
    func updateUserPoints(userToken: String, point: ScannedPoint) async throws -> APIResponse<UserPointData> {
        let endpoint = Endpoint.userpoints
        let data = try encodeParams(point: point)
        return try await network.performAuthorizedRequestWithDataDecoding(
            endpoint: endpoint,
            method: .POST,
            body: data,
            errorObject: APIResponseError.self,
            userToken: userToken
        )
    }
    
    func sponsorImage(userToken: String, sponsorId: String, width: Int, height: Int) async throws -> Data {
        let endpoint = Endpoint.sponsorImage(sponsorId: sponsorId, width: width, height: height)
        return try await network.performAuthorizedRequestWithoutDataDecoding(
            endpoint: endpoint,
            errorObject: APIResponseError.self,
            userToken: userToken
        )
    }
    
    // MARK: - Private Helpers
    
    private func encodeParams(point: ScannedPoint) throws -> Data {
        task = ApiTask.userPoints
        var taskParams = task.taskParams
        guard let location = point.location else {
            throw BaseError(
                context: .system,
                message: "Point is missing location",
                code: .general(.missingConfigItem),
                logger: logger
            )
        }
        let date = location.timestamp
        let params = [
            "code": point.code,
            "codeSource": point.codeSource.rawValue,
            "lat": String(location.latitude),
            "lng": String(location.longitude),
            "acc": String(location.accuracy),
            "alt": String(location.altitude),
            "time": date.toPointListString()
        ]
        taskParams.merge(params) { (_, new) in new }
        let jsonString = try JsonMapper.jsonString(from: taskParams)
        guard let jsonData = jsonString.data(using: .utf8) else {
            throw BaseError(
                context: .system,
                message: "Could not encode scan point params",
                code: .general(.jsonEncoding),
                logger: logger
            )
        }
        return jsonData
    }
}
