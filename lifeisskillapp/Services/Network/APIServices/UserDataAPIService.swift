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
    func getUserCategory(baseURL: URL, userToken: String) async throws -> APIResponse<UserCategoryData>
    
    func getUserPoints(baseURL: URL, userToken: String) async throws -> APIResponse<UserPointData>
    
    func getRank(baseURL: URL, userToken: String) async throws -> APIResponse<UserRankData>
    /*
     func getEvents(baseURL: URL) async throws -> APIResponse<CheckSumEventsData>
     
     func getMessages(baseURL: URL) async throws -> APIResponse<CheckSumMessagesData>
     */
    func getPoints(baseURL: URL, userToken: String) async throws -> APIResponse<GenericPointData>
    
    func postUserPoints(baseURL: URL, userToken: String, point: LoadPoint) async throws -> APIResponse<UserPointData>
}

public final class UserDataAPIService: BaseClass, UserDataAPIServicing {
    typealias Dependencies = HasNetwork & HasLoggerServicing
    
    private var loggerService: LoggerServicing
    private var network: Networking
    var task = ApiTask.userPoints
    
    init(dependencies: Dependencies) {
        self.loggerService = dependencies.logger
        self.network = dependencies.network
    }
    
    func getUserPoints(baseURL: URL, userToken: String) async throws -> APIResponse<UserPointData> {
        let endpoint = Endpoint.userpoints
        let headers = endpoint.headers(authToken: APIHeader.Authorization, userToken: userToken)
        return try await network.performRequestWithDataDecoding(
            url: try endpoint.urlWithPath(base: baseURL, logger: loggerService),
            method: .GET,
            headers: headers,
            sensitiveRequestBodyData: false,
            errorObject: APIResponseError.self)
    }
    
    func getUserCategory(baseURL: URL, userToken: String) async throws -> APIResponse<UserCategoryData> {
        let endpoint = Endpoint.usercategory
        let headers = endpoint.headers(authToken: APIHeader.Authorization, userToken: userToken)
        return try await network.performRequestWithDataDecoding(
            url: try endpoint.urlWithPath(base: baseURL, logger: loggerService),
            method: .GET,
            headers: headers,
            sensitiveRequestBodyData: false,
            errorObject: APIResponseError.self)
    }
    
    func getRank(baseURL: URL, userToken: String) async throws -> APIResponse<UserRankData> {
        let endpoint = Endpoint.rank
        let headers = endpoint.headers(authToken: APIHeader.Authorization, userToken: userToken)
        return try await network.performRequestWithDataDecoding(
            url: try endpoint.urlWithPath(base: baseURL, logger: loggerService),
            method: .GET,
            headers: headers,
            sensitiveRequestBodyData: false,
            errorObject: APIResponseError.self)
    }
    /*
     func getEvents(baseURL: URL, userToken: String) async throws -> APIResponse<CheckSumEventsData> {
     let endpoint = Endpoint.events
     let headers = endpoint.headers(authToken: APIHeader.Authorization, userToken: userManager.token)
     return try await network.performRequestWithDataDecoding(
     url: try endpoint.urlWithPath(base: baseURL, logger: loggerService),
     method: .GET,
     headers: headers,
     sensitiveRequestBodyData: false,
     sensitiveResponseData: false,
     errorObject: APIResponseError.self)
     }
     
     func getMessages(baseURL: URL, userToken: String) async throws -> APIResponse<CheckSumMessagesData> {
     let endpoint = Endpoint.messages
     let headers = endpoint.headers(authToken: APIHeader.Authorization, userToken: userManager.token)
     return try await network.performRequestWithDataDecoding(
     url: try endpoint.urlWithPath(base: baseURL, logger: loggerService),
     method: .GET,
     headers: headers,
     sensitiveRequestBodyData: false,
     sensitiveResponseData: false,
     errorObject: APIResponseError.self)
     }
     */
    func getPoints(baseURL: URL, userToken: String) async throws -> APIResponse<GenericPointData> {
        let endpoint = Endpoint.points
        let headers = endpoint.headers(authToken: APIHeader.Authorization, userToken: userToken)
        return try await network.performRequestWithDataDecoding(
            url: try endpoint.urlWithPath(base: baseURL, logger: loggerService),
            method: .GET,
            headers: headers,
            sensitiveRequestBodyData: false,
            errorObject: APIResponseError.self)
    }
    
    func postUserPoints(baseURL: URL, userToken: String, point: LoadPoint) async throws -> APIResponse<UserPointData> {
        let endpoint = Endpoint.userpoints
        let headers = endpoint.headers(authToken: APIHeader.Authorization, userToken: userToken)
        task = ApiTask.userPoints
        let data = try encodeParams(point: point)
        return try await network.performRequestWithDataDecoding(
            url: try endpoint.urlWithPath(base: baseURL, logger: loggerService),
            method: .POST,
            headers: headers,
            body: data,
            sensitiveRequestBodyData: true,
            errorObject: APIResponseError.self)
    }
    
    private func encodeParams(point: LoadPoint) throws -> Data {
        task = ApiTask.userPoints
        var taskParams = task.taskParams
        let params = [
            "code": point.code,
            "codeSource": point.codeSource.rawValue
        ]
        taskParams.merge(params) { (_, new) in new }
        let jsonString = try JsonMapper.jsonString(from: taskParams)
        guard let jsonData = jsonString.data(using: .utf8) else {
            throw BaseError(context: .system, message: "Could not encode login params", code: .general(.jsonEncoding),logger: loggerService)
        }
        return jsonData
    }
}

extension UserDataAPIService {
    enum Endpoint: CaseIterable {
        case usercategory, userpoints, rank, events, messages, points
        
        var path: String {
            switch self {
            case .usercategory:
                return "/usercategory"
            case .userpoints:
                return "/userpoints"
            case .rank:
                return "/rank"
            case .events:
                return "/events"
            case .messages:
                return "/messages"
            case .points:
                return "/points"
            }
        }
        
        var typeHeaders: [String: String] {
            switch self {
            default:
                ["accept": "application/json"]
            }
        }
        
        func headers(authToken: String? = nil, userToken: String? = nil) -> [String: String] {
            var finalHeaders = typeHeaders
            let apiHeader = Network.apiKeyHeader(apiKey: APIHeader.ApiKey)
            finalHeaders[apiHeader.key] = apiHeader.val
            if let authToken {
                let authHeader = Network.authorizationHeader(token: authToken)
                finalHeaders[authHeader.key] = authHeader.val
            }
            if let userToken {
                let userToken = Network.apiTokenHeader(token: userToken)
                finalHeaders[userToken.key] = userToken.val
            }
            return finalHeaders
        }
        
        func urlWithPath(base: URL, logger: LoggerServicing) throws -> URL {
            let finalURLString = base.absoluteString + path
            guard let url = URL(string: finalURLString) else {
                throw BaseError(
                    context: .network,
                    message: "Invalid URL",
                    logger: logger
                )
            }
            return url
        }
    }
}

