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
    func getUserPoints(baseURL: URL) async throws -> APIResponse<CheckSumUserPointsData>
    
    func getRank(baseURL: URL) async throws -> APIResponse<CheckSumRankData>
    
    func getEvents(baseURL: URL) async throws -> APIResponse<CheckSumEventsData>
    
    func getMessages(baseURL: URL) async throws -> APIResponse<CheckSumMessagesData>
    
    func getPoints(baseURL: URL) async throws -> APIResponse<CheckSumPointsData>
}

public final class CheckSumAPIService: CheckSumAPIServicing {
    func getUserPoints(baseURL: URL) async throws -> APIResponse<CheckSumUserPointsData> {
        let endpoint = Endpoint.userpoints
        let headers = endpoint.headers(authToken: APIHeader.Authorization)
        return try await network.performRequestWithDataDecoding(
            url: try endpoint.urlWithPath(base: baseURL, logger: loggerService),
            method: .PATCH,
            headers: headers,
            sensitiveRequestBodyData: false,
            sensitiveResponseData: false,
            errorObject: APIResponseError.self)
    }
    
    func getRank(baseURL: URL) async throws -> APIResponse<CheckSumRankData> {
        let endpoint = Endpoint.rank
        let headers = endpoint.headers(authToken: APIHeader.Authorization, userToken: userManager.token)
        return try await network.performRequestWithDataDecoding(
            url: try endpoint.urlWithPath(base: baseURL, logger: loggerService),
            method: .PATCH,
            headers: headers,
            sensitiveRequestBodyData: false,
            sensitiveResponseData: false,
            errorObject: APIResponseError.self)
    }
    
    func getEvents(baseURL: URL) async throws -> APIResponse<CheckSumEventsData> {
        let endpoint = Endpoint.events
        let headers = endpoint.headers(authToken: APIHeader.Authorization, userToken: userManager.token)
        return try await network.performRequestWithDataDecoding(
            url: try endpoint.urlWithPath(base: baseURL, logger: loggerService),
            method: .PATCH,
            headers: headers,
            sensitiveRequestBodyData: false,
            sensitiveResponseData: false,
            errorObject: APIResponseError.self)
    }
    
    func getMessages(baseURL: URL) async throws -> APIResponse<CheckSumMessagesData> {
        let endpoint = Endpoint.messages
        let headers = endpoint.headers(authToken: APIHeader.Authorization, userToken: userManager.token)
        return try await network.performRequestWithDataDecoding(
            url: try endpoint.urlWithPath(base: baseURL, logger: loggerService),
            method: .PATCH,
            headers: headers,
            sensitiveRequestBodyData: false,
            sensitiveResponseData: false,
            errorObject: APIResponseError.self)
    }
    
    func getPoints(baseURL: URL) async throws -> APIResponse<CheckSumPointsData> {
        let endpoint = Endpoint.points
        let headers = endpoint.headers(authToken: APIHeader.Authorization, userToken: userManager.token)
        return try await network.performRequestWithDataDecoding(
            url: try endpoint.urlWithPath(base: baseURL, logger: loggerService),
            method: .PATCH,
            headers: headers,
            sensitiveRequestBodyData: false,
            sensitiveResponseData: false,
            errorObject: APIResponseError.self)
    }
    
    
    typealias Dependencies = HasNetwork & HasLoggerServicing & HasUserManager
    
    private let loggerService: LoggerServicing
    private let network: Networking
    private let userManager: UserManaging
    
    init(dependencies: Dependencies) {
        self.loggerService = dependencies.logger
        self.network = dependencies.network
        self.userManager = dependencies.userManager
    }
    
}

extension CheckSumAPIService {
    enum Endpoint: CaseIterable {
        case userpoints, rank, events, messages, points
        
        var path: String {
            switch self {
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

