//
//  ForgotPasswordAPIServiceMock.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 02.10.2024.
//

import Foundation
@testable import lifeisskillapp

final class ForgotPasswordAPIServiceMock: ForgotPasswordAPIServicing {
    var errorToThrow: Error? = nil
    
    var fetchPinResponseToReturn: APIResponse<ForgotPasswordData> = APIResponse(data: ForgotPasswordData.mock())
    var setNewPasswordResponseToReturn: APIResponse<ForgotPasswordConfirmation> = APIResponse(data: ForgotPasswordConfirmation.mock())
    
    func fetchPin(username: String) async throws -> APIResponse<ForgotPasswordData> {
        guard let error = errorToThrow else {
            return fetchPinResponseToReturn
        }
        throw error
    }
    
    func setNewPassword(credentials: ForgotPasswordCredentials) async throws -> APIResponse<ForgotPasswordConfirmation> {
        guard let error = errorToThrow else {
            return setNewPasswordResponseToReturn
        }
        throw error
    }
}
