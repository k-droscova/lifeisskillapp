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
    func login(credentials: LoginCredentials, location: UserLocation?) async throws -> APIResponse<LoginAPIResponse>
}

public final class LoginAPIService: BaseClass, LoginAPIServicing {
    typealias Dependencies = HasNetwork & HasLoggerServicing
    
    private var network: Networking
    private var logger: LoggerServicing
    let task = ApiTask.login
    
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
        
        let endpoint = Endpoint.login
        let data = try encodeParams(credentials: credentials, location: location)
        
        return try await network.performAuthorizedRequestWithDataDecoding(
            endpoint: endpoint,
            method: .POST,
            body: data,
            sensitiveRequestBodyData: true,
            errorObject: APIResponseError.self
        )
    }
    
    private func encodeParams(credentials: LoginCredentials, location: UserLocation) throws -> Data {
        var taskParams = task.taskParams
        let params = [
            "user": credentials.username,
            "pswd": credentials.password,
            "lat": String(location.latitude),
            "lng": String(location.longitude)
        ]
        taskParams.merge(params) { (_, new) in new }
        let jsonString = try JsonMapper.jsonString(from: taskParams)
        guard let jsonData = jsonString.data(using: .utf8) else {
            throw BaseError(
                context: .system,
                message: "Could not encode login params",
                code: .general(.jsonEncoding),
                logger: logger
            )
        }
        return jsonData
    }
}
