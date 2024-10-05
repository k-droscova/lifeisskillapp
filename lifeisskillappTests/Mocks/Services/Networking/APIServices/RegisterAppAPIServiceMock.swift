//
//  RegisterAppAPIServiceMock.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 02.10.2024.
//

import Foundation
@testable import lifeisskillapp

final class RegisterAppAPIServiceMock: RegisterAppAPIServicing {
    var errorToThrow: Error? = nil
    var responseToReturn: APIResponse<RegisterAppAPIResponse> = APIResponse(data: RegisterAppAPIResponse.mock())
    
    func registerApp() async throws -> APIResponse<RegisterAppAPIResponse> {
        guard let error = errorToThrow else {
            return responseToReturn
        }
        throw error
    }
}
