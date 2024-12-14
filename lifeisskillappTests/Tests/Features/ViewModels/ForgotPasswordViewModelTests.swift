//
//  ForgotPasswordViewModelTests.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 19.10.2024.
//

import XCTest
import Combine
@testable import lifeisskillapp

final class ForgotPasswordViewModelTests: XCTestCase {
    
    // MARK: - Mocks and Dependencies
    var loggerMock: LoggingServiceMock!
    var userManagerMock: UserManagerMock!
    var forgotPasswordFlowDelegateMock: ForgotPasswordFlowDelegateMock!
    struct Dependencies: ForgotPasswordViewModel.Dependencies {
        var logger: LoggerServicing
        var userManager: UserManaging
    }
    
    // ViewModel to test
    var viewModel: ForgotPasswordViewModel!
    
    // A collection to hold Combine cancellables
    var cancellables: Set<AnyCancellable>!
    
    // MARK: - Setup
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        // Initialize mocks
        loggerMock = LoggingServiceMock()
        userManagerMock = UserManagerMock()
        forgotPasswordFlowDelegateMock = ForgotPasswordFlowDelegateMock()
        
        let dependencies = Dependencies(logger: loggerMock, userManager: userManagerMock)
        // Initialize viewModel with mocks and delegate
        viewModel = ForgotPasswordViewModel(
            dependencies: dependencies,
            delegate: forgotPasswordFlowDelegateMock
        )
        
        // Initialize cancellables
        cancellables = []
    }
    
    // MARK: - Teardown
    override func tearDownWithError() throws {
        // Clean up mocks and viewModel
        loggerMock = nil
        userManagerMock = nil
        forgotPasswordFlowDelegateMock = nil
        viewModel = nil
        cancellables = nil
        
        try super.tearDownWithError()
    }
    
    func testSendEmail_SuccessfulRequest() async {
        // Arrange
        userManagerMock.forgotPasswordDataReturnValue = ForgotPasswordData.mock() // Mock successful response
        viewModel.email = "test@example.com"
        
        let isLoadingExpectation = XCTestExpectation(description: "isLoading set to false after email request")
        
        // Observe the isLoading property
        let isLoadingCancellable = viewModel.$isLoading
            .sink { isLoading in
                if !isLoading {
                    isLoadingExpectation.fulfill()
                }
            }
        
        // Act
        viewModel.sendEmail()
        
        // Assert: Wait for isLoading and delegate call
        await fulfillment(of: [isLoadingExpectation], timeout: 2.0)
        XCTAssertTrue(userManagerMock.requestPinForPasswordRenewalCalled, "Expected requestPinForPasswordRenewal to be called.")
        XCTAssertTrue(forgotPasswordFlowDelegateMock.didRequestNewPinCalled, "Expected didRequestNewPin to be called on the delegate.")
        
        isLoadingCancellable.cancel()
    }
    
    // TODO: fix this
    /*
    func testSendEmail_ErrorRequest() async {
        // Arrange
        userManagerMock.errorToThrow = NSError(domain: "random", code: 404)
        viewModel.email = "test@example.com"
        
        let isLoadingExpectation = XCTestExpectation(description: "isLoading set to false after email request")
        
        // Observe the isLoading property
        let isLoadingCancellable = viewModel.$isLoading
            .sink { isLoading in
                if !isLoading {
                    isLoadingExpectation.fulfill()
                }
            }
        
        // Act
        viewModel.sendEmail()
        
        // Assert: Wait for isLoading and delegate call
        await fulfillment(of: [isLoadingExpectation], timeout: 2.0)
        
        XCTAssertTrue(userManagerMock.requestPinForPasswordRenewalCalled, "Expected requestPinForPasswordRenewal to be called.")
        XCTAssertTrue(forgotPasswordFlowDelegateMock.failedRequestNewPinCalled, "Expected failedRequestNewPin to be called on the delegate.")
        
        isLoadingCancellable.cancel()
    }
     */
    
    func testValidatePin_SuccessfulRequest() async {
        // Arrange
        let mockPin = "123456"
        userManagerMock.forgotPasswordDataReturnValue = ForgotPasswordData.mock(pin: mockPin) // Mock successful response
        viewModel.email = "test@example.com"
        
        let isLoadingExpectation = XCTestExpectation(description: "isLoading set to false after email request")
        
        // Observe the isLoading property
        let isLoadingCancellable = viewModel.$isLoading
            .sink { isLoading in
                if !isLoading {
                    isLoadingExpectation.fulfill()
                }
            }
        viewModel.sendEmail()
        
        // Assert: Wait for isLoading and delegate call
        await fulfillment(of: [isLoadingExpectation], timeout: 2.0)
        
        viewModel.pin = mockPin
        
        let didValidateExpectation = XCTestExpectation(description: "didValidate set to true after email request")
        let validatePinCancellable = viewModel.$isLoading
            .sink { isLoading in
                if !isLoading {
                    didValidateExpectation.fulfill()
                }
            }
        viewModel.validatePin()
        await fulfillment(of: [didValidateExpectation], timeout: 2.0)
        
        XCTAssertTrue(forgotPasswordFlowDelegateMock.didValidatePinCalled, "Expected didValidatePin to be called on the delegate.")
        
        isLoadingCancellable.cancel()
        validatePinCancellable.cancel()
    }
    
    func testValidatePin_ErrorRequest() async {
        // Arrange
        let mockPin = "123456"
        userManagerMock.forgotPasswordDataReturnValue = ForgotPasswordData.mock(pin: mockPin) // Mock successful response
        viewModel.email = "test@example.com"
        
        let isLoadingExpectation = XCTestExpectation(description: "isLoading set to false after email request")
        
        // Observe the isLoading property
        let isLoadingCancellable = viewModel.$isLoading
            .sink { isLoading in
                if !isLoading {
                    isLoadingExpectation.fulfill()
                }
            }
        viewModel.sendEmail()
        
        // Assert: Wait for isLoading and delegate call
        await fulfillment(of: [isLoadingExpectation], timeout: 2.0)
        
        viewModel.pin = "not mock pin"
        
        let didValidateExpectation = XCTestExpectation(description: "didValidate set to true after email request")
        let validatePinCancellable = viewModel.$isLoading
            .sink { isLoading in
                if !isLoading {
                    didValidateExpectation.fulfill()
                }
            }
        viewModel.validatePin()
        await fulfillment(of: [didValidateExpectation], timeout: 2.0)
        
        XCTAssertTrue(forgotPasswordFlowDelegateMock.failedValidatePinCalled, "Expected didValidatePin to be called on the delegate.")
        
        isLoadingCancellable.cancel()
        validatePinCancellable.cancel()
    }
}
