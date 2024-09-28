//
//  CredentialsMocks.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 28.09.2024.
//

import lifeisskillapp
import Foundation

// Mock for LoginCredentials
extension LoginCredentials {
    static func mock(
        username: String = "testUser",
        password: String = "testPass"
    ) -> LoginCredentials {
        return LoginCredentials(
            username: username,
            password: password
        )
    }
}

// Mock for NewRegistrationCredentials
extension NewRegistrationCredentials {
    static func mock(
        username: String = "testUser",
        email: String = "test@example.com",
        password: String = "testPass",
        referenceUserId: String? = nil
    ) -> NewRegistrationCredentials {
        return NewRegistrationCredentials(
            username: username,
            email: email,
            password: password,
            referenceUserId: referenceUserId
        )
    }
}

// Mock for ForgotPasswordCredentials
extension ForgotPasswordCredentials {
    static func mock(
        email: String = "test@example.com",
        newPassword: String = "newTestPass",
        pin: String = "123456"
    ) -> ForgotPasswordCredentials {
        return ForgotPasswordCredentials(
            email: email,
            newPassword: newPassword,
            pin: pin
        )
    }
}

// Mock for GuardianInfo
extension GuardianInfo {
    static func mock(
        firstName: String = "ParentFirstName",
        lastName: String = "ParentLastName",
        phoneNumber: String = "123456789",
        email: String = "parent@example.com",
        relationship: String = "Guardian"
    ) -> GuardianInfo {
        return GuardianInfo(
            firstName: firstName,
            lastName: lastName,
            phoneNumber: phoneNumber,
            email: email,
            relationship: relationship
        )
    }
}

// Mock for FullRegistrationCredentials
extension FullRegistrationCredentials {
    static func mock(
        firstName: String = "TestFirstName",
        lastName: String = "TestLastName",
        phoneNumber: String = "123456789",
        dateOfBirth: Date = Date(timeIntervalSince1970: 946684800), // 1st Jan 2000
        gender: UserGender = .male,
        postalCode: String = "12345",
        guardianInfo: GuardianInfo? = nil
    ) -> FullRegistrationCredentials {
        return FullRegistrationCredentials(
            firstName: firstName,
            lastName: lastName,
            phoneNumber: phoneNumber,
            dateOfBirth: dateOfBirth,
            gender: gender,
            postalCode: postalCode,
            guardianInfo: guardianInfo
        )
    }
}
