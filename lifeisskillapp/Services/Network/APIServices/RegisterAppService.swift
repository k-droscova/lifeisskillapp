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
    func registerApp() async throws -> APIResponse<RegisterAppAPIResponse>
}

public final class RegisterAppAPIService: BaseClass, RegisterAppAPIServicing {
    typealias Dependencies = HasNetwork & HasLoggerServicing
    
    private var network: Networking
    private var logger: LoggerServicing
    
    init(dependencies: Dependencies) {
        self.network = dependencies.network
        self.logger = dependencies.logger
    }
    
    func registerApp() async throws -> APIResponse<RegisterAppAPIResponse> {
        let endpoint = Endpoint.appId
        return try await network.performAuthorizedRequestWithDataDecoding(
            endpoint: endpoint,
            errorObject: APIResponseError.self
        )
    }
}
