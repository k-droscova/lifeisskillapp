//
//  LoginAPIService.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 07.07.2024.
//

import Foundation

protocol HasLoginAPIService {
    var loginAPI: LoginAPIServicing { get }
}

protocol LoginAPIServicing {
    func login(credentials: LoginCredentials, location: UserLocation?) async throws -> APIResponse<LoginAPIResponse>
    func signature(userToken: String) async throws -> APIResponse<SignatureAPIResponse>
}

final class LoginAPIService: BaseClass, LoginAPIServicing {
    typealias Dependencies = HasNetwork & HasLoggerServicing
    
    private var network: Networking
    private var logger: LoggerServicing
    
    init(dependencies: Dependencies) {
        self.network = dependencies.network
        self.logger = dependencies.logger
    }
    
    func login(credentials: LoginCredentials, location: UserLocation?) async throws -> APIResponse<LoginAPIResponse> {
        guard let location else {
            throw BaseError(
                context: .location,
                message: "User Location Required for login",
                code: ErrorCodes.login(.missingLocation),
                logger: logger
            )
        }
        let task = ApiTask.login(credentials: credentials, location: location)
        let data = try task.encodeParams()
        
        return try await network.performAuthorizedRequest(
            endpoint: Endpoint.login,
            method: .POST,
            body: data,
            sensitiveRequestBodyData: true,
            errorObject: APIResponseError.self
        )
    }
    
    func signature(userToken: String) async throws -> APIResponse<SignatureAPIResponse> {
        return try await network.performAuthorizedRequest(
            endpoint: Endpoint.signature,
            sensitiveRequestBodyData: false,
            errorObject: APIResponseError.self,
            userToken: userToken
        )
    }
}
