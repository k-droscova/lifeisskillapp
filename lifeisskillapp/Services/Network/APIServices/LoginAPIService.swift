//
//  LoginAPIService.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 07.07.2024.
//

import Foundation

struct LoginCredentials: Codable {
    let username: String
    let password: String
}

protocol HasLoginAPIService {
    var loginAPI: LoginAPIServicing { get }
}

protocol LoginAPIServicing: APITasking {
    func login(loginCredentials: LoginCredentials, baseURL: URL) async throws -> APIResponse<LoginAPIResponse>
}

public final class LoginAPIService: LoginAPIServicing {
    typealias Dependencies = HasNetwork & HasLoggerServicing
    
    private var loggerService: LoggerServicing
    private var network: Networking
    let task = ApiTask.login
    
    init(dependencies: Dependencies) {
        self.loggerService = dependencies.logger
        self.network = dependencies.network
    }
    
    func login(loginCredentials: LoginCredentials, baseURL: URL) async throws -> APIResponse<LoginAPIResponse> {
        let endpoint = Endpoint.login
        let headers = endpoint.headers(token: APIHeader.Authorization)
        let data = try encodeParams(loginCredentials: loginCredentials)
        return try await network.performRequestWithDataDecoding(
            url: try endpoint.urlWithPath(base: baseURL, logger: loggerService),
            method: .POST,
            headers: headers,
            body: data,
            sensitiveRequestBodyData: true,
            errorObject: APIResponseError.self)
    }
    
    private func encodeParams(loginCredentials: LoginCredentials) throws -> Data {
        var taskParams = task.taskParams
        let params = [
            "user": loginCredentials.username,
            "pswd": loginCredentials.password
        ]
        taskParams.merge(params) { (_, new) in new }
        let jsonString = try JsonMapper.jsonString(from: taskParams)
        guard let jsonData = jsonString.data(using: .utf8) else {
            throw BaseError(context: .system, message: "Could not encode login params", code: .general(.jsonEncoding),logger: loggerService)
        }
        return jsonData
    }
}

extension LoginAPIService {
    enum Endpoint: CaseIterable {
        case login
        
        var path: String {
            switch self {
            case .login: "/login"
            }
        }
        
        var typeHeaders: [String: String] {
            switch self {
            case .login:
                ["accept": "application/json"]
            }
        }
        
        func headers(headers: [String: String]? = nil, token: String? = nil) -> [String: String] {
            var finalHeaders = typeHeaders
            if let headers {
                finalHeaders.merge(headers) { (current, _) in current }
            }
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
