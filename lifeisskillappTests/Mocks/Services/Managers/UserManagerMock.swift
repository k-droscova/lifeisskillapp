//
//  UserManagerMock.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 17.10.2024.
//

import Foundation
@testable import lifeisskillapp

final class UserManagerMock: UserManaging {
    
    // MARK: - Mock Data and State Tracking
    var isLoggedIn: Bool = false
    var hasAppId: Bool = true
    var loggedInUser: LoggedInUser?
    
    var delegate: UserManagerFlowDelegate?
    
    // Flags to track method calls
    var loadLoggedInUserDataCalled = false
    var initializeAppIdCalled = false
    var loginCalled = false
    var logoutCalled = false
    var forceLogoutCalled = false
    var offlineLogoutCalled = false
    var requestPinForPasswordRenewalCalled = false
    var validateNewPasswordCalled = false
    var checkUsernameAvailabilityCalled = false
    var checkEmailAvailabilityCalled = false
    var registerUserCalled = false
    var completeUserRegistrationCalled = false
    var requestParentEmailActivationLinkCalled = false
    var signatureCalled = false
    
    // Optional simulated errors for throwing
    var errorToThrow: Error?
    
    // Default return values (can be modified)
    var forgotPasswordDataReturnValue: ForgotPasswordData = .mock()
    var validateNewPasswordReturnValue: Bool = true
    var checkUsernameAvailabilityReturnValue: Bool = true
    var checkEmailAvailabilityReturnValue: Bool = true
    var completeUserRegistrationReturnValue: CompleteRegistrationAPIResponse = .mock()
    var requestParentEmailActivationLinkReturnValue: Bool = true
    var signatureReturnValue: String? = "mocked-signature"
    
    // To track arguments
    var loginCredentialsPassed: LoginCredentials?
    var passwordResetUsernamePassed: String?
    var validatePasswordCredentialsPassed: ForgotPasswordCredentials?
    var usernameAvailabilityPassed: String?
    var emailAvailabilityPassed: String?
    var newUserRegistrationCredentialsPassed: NewRegistrationCredentials?
    var fullRegistrationCredentialsPassed: FullRegistrationCredentials?
    var parentEmailPassed: String?
    
    // MARK: - Mock Methods for UserManaging
    
    func loadLoggedInUserData() async {
        loadLoggedInUserDataCalled = true
        // Simulate loading user data (e.g., from storage)
    }
    
    func initializeAppId() async throws {
        initializeAppIdCalled = true
        if let error = errorToThrow {
            throw error
        }
    }
    
    func login(credentials: LoginCredentials) async throws {
        loginCalled = true
        loginCredentialsPassed = credentials
        if let error = errorToThrow {
            throw error
        }
        loggedInUser = LoggedInUser.mock(nick: credentials.username)
        isLoggedIn = true
    }
    
    func logout() {
        logoutCalled = true
        isLoggedIn = false
        delegate?.onLogout()
    }
    
    func forceLogout() {
        forceLogoutCalled = true
        isLoggedIn = false
        delegate?.onForceLogout()
    }
    
    func offlineLogout() {
        offlineLogoutCalled = true
        isLoggedIn = false
        delegate?.onLogout()
    }
    
    func requestPinForPasswordRenewal(username: String) async throws -> ForgotPasswordData {
        requestPinForPasswordRenewalCalled = true
        passwordResetUsernamePassed = username
        if let error = errorToThrow {
            throw error
        }
        return forgotPasswordDataReturnValue
    }
    
    func validateNewPassword(credentials: ForgotPasswordCredentials) async throws -> Bool {
        validateNewPasswordCalled = true
        validatePasswordCredentialsPassed = credentials
        if let error = errorToThrow {
            throw error
        }
        return validateNewPasswordReturnValue
    }
    
    func checkUsernameAvailability(_ username: String) async throws -> Bool {
        checkUsernameAvailabilityCalled = true
        usernameAvailabilityPassed = username
        if let error = errorToThrow {
            throw error
        }
        return checkUsernameAvailabilityReturnValue
    }
    
    func checkEmailAvailability(_ email: String) async throws -> Bool {
        checkEmailAvailabilityCalled = true
        emailAvailabilityPassed = email
        if let error = errorToThrow {
            throw error
        }
        return checkEmailAvailabilityReturnValue
    }
    
    func registerUser(credentials: NewRegistrationCredentials) async throws {
        registerUserCalled = true
        newUserRegistrationCredentialsPassed = credentials
        if let error = errorToThrow {
            throw error
        }
    }
    
    func completeUserRegistration(credentials: FullRegistrationCredentials) async throws -> CompleteRegistrationAPIResponse {
        completeUserRegistrationCalled = true
        fullRegistrationCredentialsPassed = credentials
        if let error = errorToThrow {
            throw error
        }
        return completeUserRegistrationReturnValue
    }
    
    func requestParentEmailActivationLink(email: String) async throws -> Bool {
        requestParentEmailActivationLinkCalled = true
        parentEmailPassed = email
        if let error = errorToThrow {
            throw error
        }
        return requestParentEmailActivationLinkReturnValue
    }
    
    func signature() async -> String? {
        signatureCalled = true
        return signatureReturnValue
    }
}
