//
//  KeychainStorageMock.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 18.10.2024.
//

@testable import lifeisskillapp


final class KeychainStorageMock: KeychainStoraging {
    
    // MARK: - Properties to Simulate Stored Credentials
    
    var mockUsername: String?
    var mockPassword: String?
    var saveCalled = false
    var deleteCalled = false
    var errorToThrow: Error?
    
    // MARK: - KeychainStoraging Conformance
    
    var username: String? {
        mockUsername
    }
    
    var password: String? {
        mockPassword
    }
    
    // Simulate saving credentials
    func save(credentials: LoginCredentials) throws {
        saveCalled = true
        // Check if the mock is set to throw an error
        if let error = errorToThrow {
            throw error
        }
        // Simulate saving the credentials
        mockUsername = credentials.username
        mockPassword = credentials.password
    }
    
    // Simulate deleting credentials
    func delete() throws {
        deleteCalled = true
        // Check if the mock is set to throw an error
        if let error = errorToThrow {
            throw error
        }
        // Simulate deleting the credentials
        mockUsername = nil
        mockPassword = nil
    }
}
