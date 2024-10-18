//
//  RegisterUserAPIServiceTests.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 02.10.2024.
//

import Foundation
@testable import lifeisskillapp

final class RegisterUserAPIServiceMock: RegisterUserAPIServicing {
    
    // MARK: - Properties for capturing arguments
    var registerUserCalled = false
    var receivedCredentials: NewRegistrationCredentials?
    var receivedLocation: UserLocation?
    
    var completeRegistrationCalled = false
    var receivedFullRegistrationCredentials: FullRegistrationCredentials?
    
    var requestParentEmailActivationLinkCalled = false
    var receivedParentEmail: String?
    
    // MARK: - Error simulation
    var errorToThrow: Error? = nil
    
    // MARK: - Mocked Responses
    var checkUsernameAvailabilityResponseToReturn: APIResponse<UsernameAvailabilityResponse> = APIResponse(data: UsernameAvailabilityResponse.mock())
    var checkEmailAvailabilityResponseToReturn: APIResponse<EmailAvailabilityResponse> = APIResponse(data: EmailAvailabilityResponse.mock())
    var registerUserResponseToReturn: APIResponse<RegistrationResponse> = APIResponse(data: RegistrationResponse.mock())
    var completeRegistrationResponseToReturn: APIResponse<CompleteRegistrationAPIResponse> = APIResponse(data: CompleteRegistrationAPIResponse.mock())
    var requestParentEmailActivationLinkResponseToReturn: APIResponse<ParentEmailActivationReponse> = APIResponse(data: ParentEmailActivationReponse.mock())
    
    // MARK: - API Method Implementations
    
    func checkUsernameAvailability(_ username: String) async throws -> APIResponse<UsernameAvailabilityResponse> {
        guard let error = errorToThrow else {
            return checkUsernameAvailabilityResponseToReturn
        }
        throw error
    }
    
    func checkEmailAvailability(_ email: String) async throws -> APIResponse<EmailAvailabilityResponse> {
        guard let error = errorToThrow else {
            return checkEmailAvailabilityResponseToReturn
        }
        throw error
    }
    
    func registerUser(credentials: NewRegistrationCredentials, location: UserLocation?) async throws -> APIResponse<RegistrationResponse> {
        // Capture the arguments
        registerUserCalled = true
        receivedCredentials = credentials
        receivedLocation = location
        
        guard let error = errorToThrow else {
            guard location != nil else {
                throw BaseError(
                    context: .location,
                    message: "User Location Required for registration",
                    logger: LoggingServiceMock()
                )
            }
            return registerUserResponseToReturn
        }
        throw error
    }
    
    func completeRegistration(credentials: FullRegistrationCredentials) async throws -> APIResponse<CompleteRegistrationAPIResponse> {
        // Capture the full registration credentials
        completeRegistrationCalled = true
        receivedFullRegistrationCredentials = credentials
        
        guard let error = errorToThrow else {
            return completeRegistrationResponseToReturn
        }
        throw error
    }
    
    func requestParentEmailActivationLink(email: String) async throws -> APIResponse<ParentEmailActivationReponse> {
        // Capture the email passed for parent email activation link
        requestParentEmailActivationLinkCalled = true
        receivedParentEmail = email
        
        guard let error = errorToThrow else {
            return requestParentEmailActivationLinkResponseToReturn
        }
        throw error
    }
}
