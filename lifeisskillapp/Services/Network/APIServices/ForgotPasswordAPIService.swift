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
    func fetchPin(username: String) async throws -> APIResponse<ForgotPasswordData>
    func setNewPassword(credentials: ForgotPasswordCredentials) async throws -> APIResponse<ForgotPasswordConfirmation>
}

public final class ForgotPasswordAPIService: BaseClass, ForgotPasswordAPIServicing {
    typealias Dependencies = HasNetwork & HasLoggerServicing
    
    private var network: Networking
    private var logger: LoggerServicing
    let task: ApiTask = ApiTask.forgotPassword
    
    init(dependencies: Dependencies) {
        self.network = dependencies.network
        self.logger = dependencies.logger
    }
    
    func fetchPin(username: String) async throws -> APIResponse<ForgotPasswordData> {
        return try await network.performAuthorizedRequestWithDataDecoding(
            endpoint: Endpoint.resetPasswordRequest(username: username),
            errorObject: APIResponseError.self
        )
    }
    
    func setNewPassword(credentials: ForgotPasswordCredentials) async throws -> APIResponse<ForgotPasswordConfirmation> {
        let data = try encodeParams(credentials: credentials)
        return try await network.performAuthorizedRequestWithDataDecoding(
            endpoint: Endpoint.resetPasswordConfirm,
            method: .PUT,
            body: data,
            sensitiveRequestBodyData: true,
            errorObject: APIResponseError.self
        )
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
                logger: logger
            )
        }
        return jsonData
    }
}
