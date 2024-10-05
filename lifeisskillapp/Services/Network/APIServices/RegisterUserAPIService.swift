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
    func registerUser(credentials: NewRegistrationCredentials, location: UserLocation?) async throws -> APIResponse<RegistrationResponse>
    func completeRegistration(credentials: FullRegistrationCredentials) async throws -> APIResponse<CompleteRegistrationAPIResponse>
    func requestParentEmailActivationLink(email: String) async throws -> APIResponse<ParentEmailActivationReponse>
}

final class RegisterUserAPIService: BaseClass, RegisterUserAPIServicing {
    typealias Dependencies = HasNetwork & HasLoggerServicing & HasPersistentUserDataStoraging
    
    private var network: Networking
    private var logger: LoggerServicing
    private let storage: PersistentUserDataStoraging

    init(dependencies: Dependencies) {
        self.network = dependencies.network
        self.logger = dependencies.logger
        self.storage = dependencies.storage
    }
    
    func checkUsernameAvailability(_ username: String) async throws -> APIResponse<UsernameAvailabilityResponse> {
        return try await network.performAuthorizedRequest(
            endpoint: Endpoint.registration(.checkUsernameAvailability(username: username)),
            errorObject: APIResponseError.self
        )
    }
    
    func checkEmailAvailability(_ email: String) async throws -> APIResponse<EmailAvailabilityResponse> {
        return try await network.performAuthorizedRequest(
            endpoint: Endpoint.registration(.checkEmailAvailability(email: email)),
            errorObject: APIResponseError.self
        )
    }
    
    func registerUser(credentials: NewRegistrationCredentials, location: UserLocation?) async throws -> APIResponse<RegistrationResponse> {
        guard let location else {
            throw BaseError(
                context: .location,
                message: "User Location Required for registration",
                logger: logger
            )
        }
        
        let task = ApiTask.registerUser(credentials: credentials, location: location)
        let data = try task.encodeParams()
        
        return try await network.performAuthorizedRequest(
            endpoint: Endpoint.registration(.registerUser),
            method: .POST,
            body: data,
            sensitiveRequestBodyData: true,
            errorObject: APIResponseError.self
        )
    }
    
    func completeRegistration(credentials: FullRegistrationCredentials) async throws -> APIResponse<CompleteRegistrationAPIResponse> {
        let task = ApiTask.completeRegistration(credentials: credentials)
        let data = try task.encodeParams()
        
        return try await network.performAuthorizedRequest(
            endpoint: Endpoint.registration(.completeRegistration),
            method: .PUT,
            body: data,
            sensitiveRequestBodyData: false,
            errorObject: APIResponseError.self,
            userToken: storage.token
        )
    }
    
    func requestParentEmailActivationLink(email: String) async throws -> APIResponse<ParentEmailActivationReponse> {
        return try await network.performAuthorizedRequest(
            endpoint: Endpoint.parentEmailActivation(email: email),
            method: .PUT,
            sensitiveRequestBodyData: true,
            errorObject: APIResponseError.self,
            userToken: storage.token
        )
    }
}
