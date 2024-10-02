//
//  LoginAPIServiceMock.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 02.10.2024.
//

import Foundation
@testable import lifeisskillapp

final class LoginAPIServiceMock: LoginAPIServicing {
    var errorToThrow: Error? = nil
    var loginResponseToReturn: APIResponse<LoginAPIResponse> = APIResponse(data: LoginAPIResponse.mock())
    var signatureResponseToReturn: APIResponse<SignatureAPIResponse> = APIResponse(data: SignatureAPIResponse.mock())
    
    func login(credentials: LoginCredentials, location: UserLocation?) async throws -> APIResponse<LoginAPIResponse> {
        if let error = errorToThrow {
            throw error
        }
        
        guard location != nil else {
            throw BaseError(
                context: .location,
                message: "User Location Required for login",
                logger: LoggingServiceMock()
            )
        }
        
        return loginResponseToReturn
    }
    
    func signature(userToken: String) async throws -> APIResponse<SignatureAPIResponse> {
        guard let error = errorToThrow else {
            return signatureResponseToReturn
        }
        throw error
    }
}
