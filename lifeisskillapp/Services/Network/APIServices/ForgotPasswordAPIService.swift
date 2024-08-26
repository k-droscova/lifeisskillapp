//
//  ForgotPasswordAPIService.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 26.08.2024.
//

import Foundation

struct ForgotPasswordCredentials: Codable {
    let email: String
    let newPassword: String
    let pin: String
}

protocol HasForgotPasswordAPIService {
    var forgotPasswordAPI: ForgotPasswordAPIServicing { get }
}

protocol ForgotPasswordAPIServicing: APITasking {
    func fetchPin(username: String, baseURL: URL) async throws -> APIResponse<ForgotPasswordData>
    func setNewPassword(credentials: ForgotPasswordCredentials, baseURL: URL) async throws -> APIResponse<ForgotPasswordConfirmation>
}

public final class ForgotPasswordAPIService: BaseClass, ForgotPasswordAPIServicing {
    typealias Dependencies = HasNetwork & HasLoggerServicing
    
    private var loggerService: LoggerServicing
    private var network: Networking
    let task: ApiTask = ApiTask.forgotPassword
    
    init(dependencies: Dependencies) {
        self.loggerService = dependencies.logger
        self.network = dependencies.network
    }
    
    func fetchPin(username: String, baseURL: URL) async throws -> APIResponse<ForgotPasswordData> {
        let endpoint = Endpoint.request
        let headers = endpoint.headers(token: APIHeader.Authorization)
        return try await network.performRequestWithDataDecoding(
            url: try endpoint.urlWithPath(base: baseURL, username: username, logger: loggerService),
            headers: headers,
            sensitiveRequestBodyData: false,
            errorObject: APIResponseError.self)
    }
    
    func setNewPassword(credentials: ForgotPasswordCredentials, baseURL: URL) async throws -> APIResponse<ForgotPasswordConfirmation> {
        let endpoint = Endpoint.confirm
        let data = try encodeParams(credentials: credentials)
        let headers = endpoint.headers(token: APIHeader.Authorization)
        return try await network.performRequestWithDataDecoding(
            url: try endpoint.urlWithPath(base: baseURL, logger: loggerService),
            method: .PUT,
            headers: headers,
            body: data,
            sensitiveRequestBodyData: true,
            errorObject: APIResponseError.self)
    }
    
    private func encodeParams(credentials: ForgotPasswordCredentials) throws -> Data {
        var taskParams = task.taskParams
        let params = [
            "pin": credentials.pin,
            "newPswd": credentials.newPassword,
            "email": credentials.email
        ]
        taskParams.merge(params) { (_, new) in new }
        let jsonString = try JsonMapper.jsonString(from: taskParams)
        guard let jsonData = jsonString.data(using: .utf8) else {
            throw BaseError(
                context: .system,
                message: "Could not encode forgot password params",
                code: .general(.jsonEncoding),
                logger: loggerService
            )
        }
        return jsonData
    }
}

extension ForgotPasswordAPIService {
    enum Endpoint: CaseIterable {
        case request
        case confirm
        
        var path: String {
            switch self {
            case .request: "/pswd/?user="
            case .confirm: "/pswd"
            }
        }
        
        var typeHeaders: [String: String] {
            switch self {
            default:
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
        
        func urlWithPath(base: URL, username: String? = nil, logger: LoggerServicing) throws -> URL {
            let finalURLString = base.absoluteString + path + (username ?? "")
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
