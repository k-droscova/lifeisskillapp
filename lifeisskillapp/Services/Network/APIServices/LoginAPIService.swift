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

protocol LoginAPIServicing {
    func login(credentials: LoginCredentials, location: UserLocation?) async throws -> APIResponse<LoginAPIResponse>
}

public final class LoginAPIService: BaseClass, LoginAPIServicing {
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
                logger: logger
            )
        }
        let task = ApiTask.login(credentials: credentials, location: location)
        let data = try task.encodeParams()
        
        return try await network.performAuthorizedRequestWithDataDecoding(
            endpoint: Endpoint.login,
            method: .POST,
            body: data,
            sensitiveRequestBodyData: true,
            errorObject: APIResponseError.self
        )
    }
}
