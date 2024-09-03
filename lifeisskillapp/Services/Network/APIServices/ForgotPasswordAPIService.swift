//
//  ForgotPasswordAPIService.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 26.08.2024.
//

import Foundation

protocol HasForgotPasswordAPIService {
    var forgotPasswordAPI: ForgotPasswordAPIServicing { get }
}

protocol ForgotPasswordAPIServicing {
    func fetchPin(username: String) async throws -> APIResponse<ForgotPasswordData>
    func setNewPassword(credentials: ForgotPasswordCredentials) async throws -> APIResponse<ForgotPasswordConfirmation>
}

public final class ForgotPasswordAPIService: BaseClass, ForgotPasswordAPIServicing {
    typealias Dependencies = HasNetwork & HasLoggerServicing
    
    private var network: Networking
    private var logger: LoggerServicing
    
    init(dependencies: Dependencies) {
        self.network = dependencies.network
        self.logger = dependencies.logger
    }
    
    func fetchPin(username: String) async throws -> APIResponse<ForgotPasswordData> {
        return try await network.performAuthorizedRequestWithDataDecoding(
            endpoint: Endpoint.resetPassword(.request(username: username)),
            errorObject: APIResponseError.self
        )
    }
    
    func setNewPassword(credentials: ForgotPasswordCredentials) async throws -> APIResponse<ForgotPasswordConfirmation> {
        let task = ApiTask.renewPassword(credentials: credentials)
        let data = try task.encodeParams()
        return try await network.performAuthorizedRequestWithDataDecoding(
            endpoint: Endpoint.resetPassword(.confirm),
            method: .PUT,
            body: data,
            sensitiveRequestBodyData: true,
            errorObject: APIResponseError.self
        )
    }
}
