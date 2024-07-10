//
//  RegisterAppService.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 07.07.2024.
//

import Foundation

protocol HasRegisterAppAPIService {
    var registerAppAPI: RegisterAppAPIServicing { get }
}

protocol RegisterAppAPIServicing {
    func registerApp(baseURL: URL) async throws -> APIResponse<RegisterAppAPIResponse>
}

public final class RegisterAppAPIService: RegisterAppAPIServicing {
    
    typealias Dependencies = HasNetwork & HasLoggerServicing
    
    private let loggerService: LoggerServicing
    private let network: Networking
    
    init(dependencies: Dependencies) {
        self.loggerService = dependencies.logger
        self.network = dependencies.network
    }
    
    func registerApp(baseURL: URL) async throws -> APIResponse<RegisterAppAPIResponse> {
        let endpoint = Endpoint.appId
        let headers = endpoint.headers(token: APIHeader.Authorization)
        return try await network.performRequestWithDataDecoding(
            url: try endpoint.urlWithPath(base: baseURL, logger: loggerService),
            headers: headers,
            sensitiveRequestBodyData: false,
            sensitiveResponseData: false,
            errorObject: APIResponseError.self)
    }
    
    
}

extension RegisterAppAPIService {
    enum Endpoint: CaseIterable {
        case appId
        
        var path: String {
            switch self {
            case .appId: "/appid"
            }
        }
        
        var typeHeaders: [String: String] {
            switch self {
            case .appId:
                ["accept": "application/json"]
            }
        }
        
        func headers(token: String? = nil) -> [String: String] {
            var finalHeaders = typeHeaders
            let apiHeader = Network.apiKeyHeader(apiKey: APIHeader.ApiKey)
            finalHeaders[apiHeader.key] = apiHeader.val
            if let token {
                let authHeader = Network.authorizationHeader(token: token)
                finalHeaders[authHeader.key] = authHeader.val
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

