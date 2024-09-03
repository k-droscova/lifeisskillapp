//
//  RegisterUserAPIService.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 03.09.2024.
//

import Foundation

protocol HasRegisterUserAPIService {
    var registerUserAPI: RegisterUserAPIServicing { get }
}

protocol RegisterUserAPIServicing {
    func checkUsernameAvailability(_ username: String) async throws -> APIResponse<UsernameAvailabilityResponse>
    func checkEmailAvailability(_ email: String) async throws -> APIResponse<EmailAvailabilityResponse>
    //func registerUser(credentials: RegistrationCredentials) async throws -> APIResponse<
}

public final class RegisterUserAPIService: BaseClass, RegisterUserAPIServicing {
    typealias Dependencies = HasNetwork & HasLoggerServicing
    
    private var network: Networking
    private var logger: LoggerServicing
    
    init(dependencies: Dependencies) {
        self.network = dependencies.network
        self.logger = dependencies.logger
    }

    func checkUsernameAvailability(_ username: String) async throws -> APIResponse<UsernameAvailabilityResponse> {
        return try await network.performAuthorizedRequestWithDataDecoding(
            endpoint: Endpoint.registration(.checkUsernameAvailability(username: username)),
            errorObject: APIResponseError.self
        )
    }
    
    func checkEmailAvailability(_ email: String) async throws -> APIResponse<EmailAvailabilityResponse> {
        return try await network.performAuthorizedRequestWithDataDecoding(
            endpoint: Endpoint.registration(.checkEmailAvailability(email: email)),
            errorObject: APIResponseError.self
        )
    }
}
