//
//  RegistrationViewModelTests.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 19.10.2024.
//

import XCTest
import Combine
@testable import lifeisskillapp

final class RegistrationViewModelTests: XCTestCase {
    
    // MARK: - Mocks and Dependencies
    var loggerMock: LoggingServiceMock!
    var userManagerMock: UserManagerMock!
    var registrationFlowDelegateMock: RegistrationFlowDelegateMock!
    
    // ViewModel to test
    var viewModel: RegistrationViewModel!
    
    var cancellables: Set<AnyCancellable>!
    
    // MARK: - Setup
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        // Initialize mocks
        loggerMock = LoggingServiceMock()
        userManagerMock = UserManagerMock()
        registrationFlowDelegateMock = RegistrationFlowDelegateMock()
        
        // Initialize cancellables
        cancellables = []
    }
    
    // MARK: - Teardown
    override func tearDownWithError() throws {
        // Clean up mocks and viewModel
        loggerMock = nil
        userManagerMock = nil
        registrationFlowDelegateMock = nil
        viewModel = nil
        cancellables = nil
        
        try super.tearDownWithError()
    }
    
    func testIsFormValid_WhenInitialized_IsFalse() {
        // Arrange
        viewModel = RegistrationViewModel(
            dependencies: .init(logger: loggerMock, userManager: userManagerMock),
            delegate: registrationFlowDelegateMock
        )
        // Assert
        XCTAssertFalse(viewModel.isFormValid, "Expected isFormValid to be false when the viewModel is initialized.")
    }
    
    func testViewModelInitialization() {
        // Arrange
        viewModel = RegistrationViewModel(dependencies: .init(logger: loggerMock, userManager: userManagerMock), delegate: registrationFlowDelegateMock)
        
        // Act
        
        // Assert
        // Check that the initial state of all the fields is as expected
        XCTAssertEqual(viewModel.username, "", "username should be empty on initialization")
        XCTAssertEqual(viewModel.email, "", "email should be empty on initialization")
        XCTAssertEqual(viewModel.password, "", "password should be empty on initialization")
        XCTAssertEqual(viewModel.passwordConfirm, "", "passwordConfirm should be empty on initialization")
        XCTAssertFalse(viewModel.isGdprConfirmed, "isGdprConfirmed should be false on initialization")
        XCTAssertFalse(viewModel.isRulesConfirmed, "isRulesConfirmed should be false on initialization")
        XCTAssertNil(viewModel.referenceUsername, "referenceUsername should be nil on initialization")
        XCTAssertNil(viewModel.referenceInfo, "referenceInfo should be nil on initialization")
        XCTAssertFalse(viewModel.addReference, "addReference should be false on initialization")
        
        // Validation States
        guard let usernameValidation = viewModel.usernameValidationState as? UsernameValidationState else {
            return XCTFail("usernameValidationState is not of type UsernameValidationState")
        }
        XCTAssertEqual(usernameValidation, .initial, "usernameValidationState should be .initial on initialization")
        
        guard let emailValidation = viewModel.emailValidationState as? EmailValidationState else {
            return XCTFail("emailValidationState is not of type EmailValidationState")
        }
        XCTAssertEqual(emailValidation, .initial, "emailValidationState should be .initial on initialization")
        
        guard let passwordValidation = viewModel.passwordValidationState as? PasswordValidationState else {
            return XCTFail("passwordValidationState is not of type PasswordValidationState")
        }
        XCTAssertEqual(passwordValidation, .initial, "passwordValidationState should be .initial on initialization")
        
        guard let confirmPasswordValidation = viewModel.confirmPasswordValidationState as? ConfirmPasswordValidationState else {
            return XCTFail("confirmPasswordValidationState is not of type ConfirmPasswordValidationState")
        }
        XCTAssertEqual(confirmPasswordValidation, .initial, "confirmPasswordValidationState should be .initial on initialization")
        
        // Ensure form validation is invalid by default
        XCTAssertFalse(viewModel.isFormValid, "isFormValid should be false on initialization")
    }
    
    // MARK: - Validation tests
    
    func testUsernameValidationChangesToValid() async {
        // Arrange
        userManagerMock.checkUsernameAvailabilityReturnValue = true // Mock username is available
        viewModel = RegistrationViewModel(dependencies: .init(logger: loggerMock, userManager: userManagerMock), delegate: registrationFlowDelegateMock)
        
        // Create an expectation to wait for the username validation state to change
        let validationExpectation = XCTestExpectation(description: "Username validation state should change to valid")
        
        // Subscribe to changes on usernameValidationState
        let validationCancellable = viewModel.$usernameValidationState
            .dropFirst() // Drop the initial state
            .sink { validationState in
                validationExpectation.fulfill()
            }
        
        // Act: Set a valid username
        viewModel.username = "validusername"
        
        // Wait for the expectation
        await fulfillment(of: [validationExpectation], timeout: 2.0)
        
        // Assert: Ensure the validation state has been updated to valid
        guard let usernameValidation = viewModel.usernameValidationState as? UsernameValidationState else {
            return XCTFail("usernameValidationState is not of type UsernameValidationState")
        }
        XCTAssertEqual(usernameValidation, .valid, "usernameValidationState should be .valid when username is valid and available")
        
        // Clean up the cancellable
        validationCancellable.cancel()
    }
    
    func testUsernameValidationChangesToTaken() async {
        // Arrange
        userManagerMock.checkUsernameAvailabilityReturnValue = false
        viewModel = RegistrationViewModel(dependencies: .init(logger: loggerMock, userManager: userManagerMock), delegate: registrationFlowDelegateMock)
        
        // Create an expectation to wait for the username validation state to change
        let validationExpectation = XCTestExpectation(description: "Username validation state should change to valid")
        
        // Subscribe to changes on usernameValidationState
        let validationCancellable = viewModel.$usernameValidationState
            .dropFirst() // Drop the initial state
            .sink { validationState in
                validationExpectation.fulfill()
            }
        
        // Act: Set a valid username
        viewModel.username = "takenUsername"
        
        // Wait for the expectation
        await fulfillment(of: [validationExpectation], timeout: 2.0)
        
        // Assert: Ensure the validation state has been updated to valid
        guard let usernameValidation = viewModel.usernameValidationState as? UsernameValidationState else {
            return XCTFail("usernameValidationState is not of type UsernameValidationState")
        }
        XCTAssertEqual(usernameValidation, .alreadyTaken, "usernameValidationState should be taken")
        
        // Clean up the cancellable
        validationCancellable.cancel()
    }
    
    func testUsernameValidationChangesToEmpty() async {
        // Arrange
        viewModel = RegistrationViewModel(dependencies: .init(logger: loggerMock, userManager: userManagerMock), delegate: registrationFlowDelegateMock)
        
        // Create an expectation to wait for the username validation state to change
        let validationExpectation = XCTestExpectation(description: "Username validation state should change to invalid format")
        
        // Subscribe to changes on usernameValidationState
        let validationCancellable = viewModel.$usernameValidationState
            .dropFirst() // Drop the initial state
            .sink { validationState in
                validationExpectation.fulfill()
            }
        
        // Act: Set a username that is too short (e.g., 3 characters)
        viewModel.username = ""
        
        // Wait for the expectation
        await fulfillment(of: [validationExpectation], timeout: 2.0)
        
        // Assert: Ensure the validation state has been updated to `invalidFormat` due to short username
        guard let usernameValidation = viewModel.usernameValidationState as? UsernameValidationState else {
            return XCTFail("usernameValidationState is not of type UsernameValidationState")
        }
        XCTAssertEqual(usernameValidation, .empty, "usernameValidationState should be .empty")
        
        // Clean up the cancellable
        validationCancellable.cancel()
    }
    
    func testUsernameValidationChangesToInvalidFormat_WhenTooShort() async {
        // Arrange
        viewModel = RegistrationViewModel(dependencies: .init(logger: loggerMock, userManager: userManagerMock), delegate: registrationFlowDelegateMock)
        
        // Create an expectation to wait for the username validation state to change
        let validationExpectation = XCTestExpectation(description: "Username validation state should change to invalid format")
        
        // Subscribe to changes on usernameValidationState
        let validationCancellable = viewModel.$usernameValidationState
            .dropFirst() // Drop the initial state
            .sink { validationState in
                validationExpectation.fulfill()
            }
        
        // Act: Set a username that is too short (e.g., 3 characters)
        viewModel.username = "abc"
        
        // Wait for the expectation
        await fulfillment(of: [validationExpectation], timeout: 2.0)
        
        // Assert: Ensure the validation state has been updated to `invalidFormat` due to short username
        guard let usernameValidation = viewModel.usernameValidationState as? UsernameValidationState else {
            return XCTFail("usernameValidationState is not of type UsernameValidationState")
        }
        XCTAssertEqual(usernameValidation, .short, "usernameValidationState should be .short when username has fewer than 4 characters")
        
        // Clean up the cancellable
        validationCancellable.cancel()
    }
    
    func testEmailValidationChangesToEmpty() async {
        // Arrange
        viewModel = RegistrationViewModel(dependencies: .init(logger: loggerMock, userManager: userManagerMock), delegate: registrationFlowDelegateMock)
        
        // Create an expectation to wait for the email validation state to change
        let validationExpectation = XCTestExpectation(description: "Email validation state should change to empty")
        
        // Subscribe to changes on emailValidationState
        let validationCancellable = viewModel.$emailValidationState
            .dropFirst() // Drop the initial state
            .sink { validationState in
                validationExpectation.fulfill()
            }
        
        // Act: Set an empty email
        viewModel.email = ""
        
        // Wait for the expectation
        await fulfillment(of: [validationExpectation], timeout: 2.0)
        
        // Assert: Ensure the validation state has been updated to empty
        guard let emailValidation = viewModel.emailValidationState as? EmailValidationState else {
            return XCTFail("emailValidationState is not of type EmailValidationState")
        }
        XCTAssertEqual(emailValidation, .empty, "emailValidationState should be .empty when email is empty")
        
        // Clean up the cancellable
        validationCancellable.cancel()
    }
    
    func testEmailValidationChangesToInvalidFormat() async {
        // Arrange
        viewModel = RegistrationViewModel(dependencies: .init(logger: loggerMock, userManager: userManagerMock), delegate: registrationFlowDelegateMock)
        
        // Create an expectation to wait for the email validation state to change
        let validationExpectation = XCTestExpectation(description: "Email validation state should change to invalid format")
        
        // Subscribe to changes on emailValidationState
        let validationCancellable = viewModel.$emailValidationState
            .dropFirst() // Drop the initial state
            .sink { validationState in
                validationExpectation.fulfill()
            }
        
        // Act: Set an invalid email
        viewModel.email = "invalidEmailFormat"
        
        // Wait for the expectation
        await fulfillment(of: [validationExpectation], timeout: 2.0)
        
        // Assert: Ensure the validation state has been updated to invalid format
        guard let emailValidation = viewModel.emailValidationState as? EmailValidationState else {
            return XCTFail("emailValidationState is not of type EmailValidationState")
        }
        XCTAssertEqual(emailValidation, .invalidFormat, "emailValidationState should be .invalidFormat when email format is invalid")
        
        // Clean up the cancellable
        validationCancellable.cancel()
    }
    
    func testEmailValidationChangesToAlreadyTaken() async {
        // Arrange
        userManagerMock.checkEmailAvailabilityReturnValue = false
        viewModel = RegistrationViewModel(dependencies: .init(logger: loggerMock, userManager: userManagerMock), delegate: registrationFlowDelegateMock)
        
        // Create an expectation to wait for the email validation state to change
        let validationExpectation = XCTestExpectation(description: "Email validation state should change to already taken")
        
        // Subscribe to changes on emailValidationState
        let validationCancellable = viewModel.$emailValidationState
            .dropFirst() // Drop the initial state
            .sink { validationState in
                validationExpectation.fulfill()
            }
        
        // Act: Set a valid email that's already taken
        viewModel.email = "taken@example.com"
        
        // Wait for the expectation
        await fulfillment(of: [validationExpectation], timeout: 2.0)
        
        // Assert: Ensure the validation state has been updated to already taken
        guard let emailValidation = viewModel.emailValidationState as? EmailValidationState else {
            return XCTFail("emailValidationState is not of type EmailValidationState")
        }
        XCTAssertEqual(emailValidation, .alreadyTaken, "emailValidationState should be .alreadyTaken when email is already taken")
        
        // Clean up the cancellable
        validationCancellable.cancel()
    }
    
    func testEmailValidationChangesToValid() async {
        // Arrange
        userManagerMock.checkEmailAvailabilityReturnValue = true // Mock email is available
        viewModel = RegistrationViewModel(dependencies: .init(logger: loggerMock, userManager: userManagerMock), delegate: registrationFlowDelegateMock)
        
        // Create an expectation to wait for the email validation state to change
        let validationExpectation = XCTestExpectation(description: "Email validation state should change to valid")
        
        // Subscribe to changes on emailValidationState
        let validationCancellable = viewModel.$emailValidationState
            .dropFirst() // Drop the initial state
            .sink { validationState in
                validationExpectation.fulfill()
            }
        
        // Act: Set a valid email
        viewModel.email = "valid@example.com"
        
        // Wait for the expectation
        await fulfillment(of: [validationExpectation], timeout: 2.0)
        
        // Assert: Ensure the validation state has been updated to valid
        guard let emailValidation = viewModel.emailValidationState as? EmailValidationState else {
            return XCTFail("emailValidationState is not of type EmailValidationState")
        }
        XCTAssertEqual(emailValidation, .valid, "emailValidationState should be .valid when email is valid and available")
        
        // Clean up the cancellable
        validationCancellable.cancel()
    }
    
    func testPasswordValidationChangesToEmpty_WhenPasswordIsEmpty() async {
        // Arrange
        viewModel = RegistrationViewModel(dependencies: .init(logger: loggerMock, userManager: userManagerMock), delegate: registrationFlowDelegateMock)
        
        // Create an expectation to wait for the password validation state to change
        let validationExpectation = XCTestExpectation(description: "Password validation state should change to empty")
        
        // Subscribe to changes on passwordValidationState
        let validationCancellable = viewModel.$passwordValidationState
            .dropFirst() // Drop the initial state
            .sink { validationState in
                validationExpectation.fulfill()
            }
        
        // Act: Set an empty password
        viewModel.password = ""
        
        // Wait for the expectation
        await fulfillment(of: [validationExpectation], timeout: 2.0)
        
        // Assert: Ensure the validation state has been updated to `.empty`
        guard let passwordValidation = viewModel.passwordValidationState as? PasswordValidationState else {
            return XCTFail("passwordValidationState is not of type PasswordValidationState")
        }
        XCTAssertEqual(passwordValidation, .empty, "passwordValidationState should be .empty when the password is empty")
        
        // Clean up the cancellable
        validationCancellable.cancel()
    }
    
    func testPasswordValidationChangesToInvalidFormat_WhenTooShort() async {
        // Arrange
        viewModel = RegistrationViewModel(dependencies: .init(logger: loggerMock, userManager: userManagerMock), delegate: registrationFlowDelegateMock)
        
        // Create an expectation to wait for the password validation state to change
        let validationExpectation = XCTestExpectation(description: "Password validation state should change to invalid format")
        
        // Subscribe to changes on passwordValidationState
        let validationCancellable = viewModel.$passwordValidationState
            .dropFirst() // Drop the initial state
            .sink { validationState in
                validationExpectation.fulfill()
            }
        
        // Act: Set a password that is too short (e.g., 5 characters)
        viewModel.password = "12345"
        
        // Wait for the expectation
        await fulfillment(of: [validationExpectation], timeout: 2.0)
        
        // Assert: Ensure the validation state has been updated to `.invalidFormat` due to short password
        guard let passwordValidation = viewModel.passwordValidationState as? PasswordValidationState else {
            return XCTFail("passwordValidationState is not of type PasswordValidationState")
        }
        XCTAssertEqual(passwordValidation, .invalidFormat, "passwordValidationState should be .invalidFormat when the password has fewer than 6 characters")
        
        // Clean up the cancellable
        validationCancellable.cancel()
    }
    
    func testPasswordValidationChangesToValid_WhenPasswordIsLongEnough() async {
        // Arrange
        viewModel = RegistrationViewModel(dependencies: .init(logger: loggerMock, userManager: userManagerMock), delegate: registrationFlowDelegateMock)
        
        // Create an expectation to wait for the password validation state to change
        let validationExpectation = XCTestExpectation(description: "Password validation state should change to valid")
        
        // Subscribe to changes on passwordValidationState
        let validationCancellable = viewModel.$passwordValidationState
            .dropFirst() // Drop the initial state
            .sink { validationState in
                validationExpectation.fulfill()
            }
        
        // Act: Set a valid password (at least 6 characters)
        viewModel.password = "123456"
        
        // Wait for the expectation
        await fulfillment(of: [validationExpectation], timeout: 2.0)
        
        // Assert: Ensure the validation state has been updated to `.valid`
        guard let passwordValidation = viewModel.passwordValidationState as? PasswordValidationState else {
            return XCTFail("passwordValidationState is not of type PasswordValidationState")
        }
        XCTAssertEqual(passwordValidation, .valid, "passwordValidationState should be .valid when the password has at least 6 characters")
        
        // Clean up the cancellable
        validationCancellable.cancel()
    }
    
    func testConfirmPasswordValidationChangesToMismatching_WhenPasswordsDoNotMatch() async {
        // Arrange
        viewModel = RegistrationViewModel(dependencies: .init(logger: loggerMock, userManager: userManagerMock), delegate: registrationFlowDelegateMock)
        
        // Create an expectation to wait for the confirm password validation state to change
        let validationExpectation = XCTestExpectation(description: "Confirm password validation state should change to mismatching")
        
        // Subscribe to changes on confirmPasswordValidationState
        let validationCancellable = viewModel.$confirmPasswordValidationState
            .dropFirst() // Drop the initial state
            .sink { validationState in
                validationExpectation.fulfill()
            }
        
        // Act: Set password and confirmPassword to different values
        viewModel.password = "Password1"
        viewModel.passwordConfirm = "Password2"
        
        // Wait for the expectation
        await fulfillment(of: [validationExpectation], timeout: 2.0)
        
        // Assert: Ensure the validation state has been updated to `.mismatching`
        guard let confirmPasswordValidation = viewModel.confirmPasswordValidationState as? ConfirmPasswordValidationState else {
            return XCTFail("confirmPasswordValidationState is not of type ConfirmPasswordValidationState")
        }
        XCTAssertEqual(confirmPasswordValidation, .mismatching, "confirmPasswordValidationState should be .mismatching when passwords do not match")
        
        // Clean up the cancellable
        validationCancellable.cancel()
    }
    
    func testConfirmPasswordValidationChangesToValid_WhenPasswordsMatch() async {
        // Arrange
        viewModel = RegistrationViewModel(dependencies: .init(logger: loggerMock, userManager: userManagerMock), delegate: registrationFlowDelegateMock)
        
        // Create an expectation to wait for the confirm password validation state to change
        let validationExpectation = XCTestExpectation(description: "Confirm password validation state should change to valid")
        
        // Subscribe to changes on confirmPasswordValidationState
        let validationCancellable = viewModel.$confirmPasswordValidationState
            .dropFirst() // Drop the initial state
            .sink { validationState in
                validationExpectation.fulfill()
            }
        
        // Act: Set password and confirmPassword to the same value
        viewModel.password = "Password123"
        viewModel.passwordConfirm = "Password123"
        
        // Wait for the expectation
        await fulfillment(of: [validationExpectation], timeout: 2.0)
        
        // Assert: Ensure the validation state has been updated to `.valid`
        guard let confirmPasswordValidation = viewModel.confirmPasswordValidationState as? ConfirmPasswordValidationState else {
            return XCTFail("confirmPasswordValidationState is not of type ConfirmPasswordValidationState")
        }
        XCTAssertEqual(confirmPasswordValidation, .valid, "confirmPasswordValidationState should be .valid when passwords match")
        
        // Clean up the cancellable
        validationCancellable.cancel()
    }
    
    func testConfirmPasswordValidationChangesToMismatching_WhenConfirmPasswordIsEmpty() async {
        // Arrange
        viewModel = RegistrationViewModel(dependencies: .init(logger: loggerMock, userManager: userManagerMock), delegate: registrationFlowDelegateMock)
        
        // Create an expectation to wait for the confirm password validation state to change
        let validationExpectation = XCTestExpectation(description: "Confirm password validation state should change to mismatching")
        
        // Subscribe to changes on confirmPasswordValidationState
        let validationCancellable = viewModel.$confirmPasswordValidationState
            .dropFirst() // Drop the initial state
            .sink { validationState in
                validationExpectation.fulfill()
            }
        
        // Act: Set password but leave confirmPassword empty
        viewModel.password = "Password123"
        viewModel.passwordConfirm = ""
        
        // Wait for the expectation
        await fulfillment(of: [validationExpectation], timeout: 2.0)
        
        // Assert: Ensure the validation state has been updated to `.mismatching`
        guard let confirmPasswordValidation = viewModel.confirmPasswordValidationState as? ConfirmPasswordValidationState else {
            return XCTFail("confirmPasswordValidationState is not of type ConfirmPasswordValidationState")
        }
        XCTAssertEqual(confirmPasswordValidation, .mismatching, "confirmPasswordValidationState should be .mismatching when confirmPassword is empty and password is not")
        
        // Clean up the cancellable
        validationCancellable.cancel()
    }
    
    func testConfirmPasswordValidationChangesToMismatching_WhenPasswordChanges() async {
        // Arrange
        viewModel = RegistrationViewModel(dependencies: .init(logger: loggerMock, userManager: userManagerMock), delegate: registrationFlowDelegateMock)
        
        // Set initial valid password and confirmPassword
        viewModel.password = "Password123"
        viewModel.passwordConfirm = "Password123"
        
        // Create an expectation to wait for the confirm password validation state to change
        let validationExpectation = XCTestExpectation(description: "Confirm password validation state should change to mismatching after password changes")
        
        // Subscribe to changes on confirmPasswordValidationState
        let validationCancellable = viewModel.$confirmPasswordValidationState
            .dropFirst() // Drop the initial valid state
            .sink { validationState in
                validationExpectation.fulfill()
            }
        
        // Act: Change the password
        viewModel.password = "NewPassword123"
        
        // Wait for the expectation
        await fulfillment(of: [validationExpectation], timeout: 2.0)
        
        // Assert: Ensure the validation state has been updated to `.mismatching`
        guard let confirmPasswordValidation = viewModel.confirmPasswordValidationState as? ConfirmPasswordValidationState else {
            return XCTFail("confirmPasswordValidationState is not of type ConfirmPasswordValidationState")
        }
        XCTAssertEqual(confirmPasswordValidation, .mismatching, "confirmPasswordValidationState should be .mismatching when password changes and confirmPassword remains the same")
        
        // Clean up the cancellable
        validationCancellable.cancel()
    }
    
    func testSubmitRegistration_WhenFormIsValid() async {
        // Arrange
        userManagerMock.checkEmailAvailabilityReturnValue = true
        userManagerMock.checkUsernameAvailabilityReturnValue = true
        viewModel = RegistrationViewModel(dependencies: .init(logger: loggerMock, userManager: userManagerMock), delegate: registrationFlowDelegateMock)
        
        // Create expectations for the validation changes
        let usernameValidationExpectation = XCTestExpectation(description: "Username validation should become valid")
        let emailValidationExpectation = XCTestExpectation(description: "Email validation should become valid")
        let passwordValidationExpectation = XCTestExpectation(description: "Password validation should become valid")
        let confirmPasswordValidationExpectation = XCTestExpectation(description: "Confirm password validation should become valid")
        
        // Observe validation state changes
        let usernameValidationCancellable = viewModel.$usernameValidationState
            .dropFirst() // Skip initial value
            .sink { validationState in
                if let validation = validationState as? UsernameValidationState, validation == .valid {
                    usernameValidationExpectation.fulfill()
                }
            }
        
        let emailValidationCancellable = viewModel.$emailValidationState
            .dropFirst() // Skip initial value
            .sink { validationState in
                if let validation = validationState as? EmailValidationState, validation == .valid {
                    emailValidationExpectation.fulfill()
                }
            }
        
        let passwordValidationCancellable = viewModel.$passwordValidationState
            .dropFirst() // Skip initial value
            .sink { validationState in
                if let validation = validationState as? PasswordValidationState, validation == .valid {
                    passwordValidationExpectation.fulfill()
                }
            }
        
        let confirmPasswordValidationCancellable = viewModel.$confirmPasswordValidationState
            .dropFirst() // Skip initial value
            .sink { validationState in
                if let validation = validationState as? ConfirmPasswordValidationState, validation == .valid {
                    confirmPasswordValidationExpectation.fulfill()
                }
            }
        
        // Act: Set form to a valid state (this triggers the validation tasks)
        setValidFormState()
        
        // Wait for all validation expectations to be fulfilled
        await fulfillment(of: [
            usernameValidationExpectation,
            emailValidationExpectation,
            passwordValidationExpectation,
            confirmPasswordValidationExpectation
        ], timeout: 2.0)
        
        // Set form to a valid state
        setValidFormState()
        
        // Create an expectation to wait for isLoading to become false
        let isLoadingExpectation = XCTestExpectation(description: "isLoading should become false after registration completes")
        
        // Subscribe to changes on isLoading
        let isLoadingCancellable = viewModel.$isLoading
            .dropFirst() // Drop the initial value
            .sink { isLoading in
                if !isLoading {
                    isLoadingExpectation.fulfill()
                }
            }
        
        // Act: Call `submitRegistration`
        viewModel.submitRegistration()
        
        // Wait for the expectation
        await fulfillment(of: [isLoadingExpectation], timeout: 2.0)
        
        // Assert: Ensure isLoading is set to false
        XCTAssertTrue(userManagerMock.registerUserCalled, "registerUser should have been called")
        XCTAssertTrue(registrationFlowDelegateMock.registrationDidSucceedCalled, "registrationDidSucceed should have been called")
        
        // Clean up the cancellable
        usernameValidationCancellable.cancel()
        emailValidationCancellable.cancel()
        passwordValidationCancellable.cancel()
        confirmPasswordValidationCancellable.cancel()
        isLoadingCancellable.cancel()
    }
    
    func testSubmitRegistration_WhenFormIsValidButRegistrationFails_InformsDelegate() async {
        // Arrange
        userManagerMock.checkEmailAvailabilityReturnValue = true
        userManagerMock.checkUsernameAvailabilityReturnValue = true
        viewModel = RegistrationViewModel(dependencies: .init(logger: loggerMock, userManager: userManagerMock), delegate: registrationFlowDelegateMock)
        
        // Create expectations for the validation changes
        let usernameValidationExpectation = XCTestExpectation(description: "Username validation should become valid")
        let emailValidationExpectation = XCTestExpectation(description: "Email validation should become valid")
        let passwordValidationExpectation = XCTestExpectation(description: "Password validation should become valid")
        let confirmPasswordValidationExpectation = XCTestExpectation(description: "Confirm password validation should become valid")
        
        // Observe validation state changes
        let usernameValidationCancellable = viewModel.$usernameValidationState
            .dropFirst() // Skip initial value
            .sink { validationState in
                if let validation = validationState as? UsernameValidationState, validation == .valid {
                    usernameValidationExpectation.fulfill()
                }
            }
        
        let emailValidationCancellable = viewModel.$emailValidationState
            .dropFirst() // Skip initial value
            .sink { validationState in
                if let validation = validationState as? EmailValidationState, validation == .valid {
                    emailValidationExpectation.fulfill()
                }
            }
        
        let passwordValidationCancellable = viewModel.$passwordValidationState
            .dropFirst() // Skip initial value
            .sink { validationState in
                if let validation = validationState as? PasswordValidationState, validation == .valid {
                    passwordValidationExpectation.fulfill()
                }
            }
        
        let confirmPasswordValidationCancellable = viewModel.$confirmPasswordValidationState
            .dropFirst() // Skip initial value
            .sink { validationState in
                if let validation = validationState as? ConfirmPasswordValidationState, validation == .valid {
                    confirmPasswordValidationExpectation.fulfill()
                }
            }
        
        // Act: Set form to a valid state (this triggers the validation tasks)
        setValidFormState()
        
        // Wait for all validation expectations to be fulfilled
        await fulfillment(of: [
            usernameValidationExpectation,
            emailValidationExpectation,
            passwordValidationExpectation,
            confirmPasswordValidationExpectation
        ], timeout: 3.0)
        
        userManagerMock.errorToThrow = NSError(domain: "mock", code: 404)

        // Set form to a valid state
        setValidFormState()
        
        // Create an expectation to wait for isLoading to become false
        let isLoadingExpectation = XCTestExpectation(description: "isLoading should become false after registration completes")
        
        // Subscribe to changes on isLoading
        let isLoadingCancellable = viewModel.$isLoading
            .dropFirst() // Drop the initial value
            .sink { isLoading in
                if !isLoading {
                    isLoadingExpectation.fulfill()
                }
            }
        
        // Act: Call `submitRegistration`
        viewModel.submitRegistration()
        
        // Wait for the expectation
        await fulfillment(of: [isLoadingExpectation], timeout: 2.0)
        
        // Assert: Ensure isLoading is set to false
        XCTAssertTrue(userManagerMock.registerUserCalled, "registerUser should have been called")
        XCTAssertTrue(registrationFlowDelegateMock.registrationDidFailCalled, "registrationDidFail should have been called")
        
        // Clean up the cancellable
        usernameValidationCancellable.cancel()
        emailValidationCancellable.cancel()
        passwordValidationCancellable.cancel()
        confirmPasswordValidationCancellable.cancel()
        isLoadingCancellable.cancel()
    }
    
    func testShowReferenceInstructions_CallsDelegate() {
        // Arrange
        viewModel = RegistrationViewModel(
            dependencies: .init(logger: loggerMock, userManager: userManagerMock),
            delegate: registrationFlowDelegateMock
        )
        
        // Act
        viewModel.showReferenceInstructions()
        
        // Assert
        XCTAssertTrue(registrationFlowDelegateMock.showReferenceInstructionsCalled, "Expected showReferenceInstructions to be called on the delegate.")
    }
    
    func testScanQR_CreatesQRReferenceViewModelAndCallsLoadQR() {
        // Arrange
        viewModel = RegistrationViewModel(
            dependencies: .init(logger: loggerMock, userManager: userManagerMock),
            delegate: registrationFlowDelegateMock
        )
        
        // Act
        viewModel.scanQR()
        
        // Assert
        XCTAssertTrue(registrationFlowDelegateMock.loadQRCalled, "Expected loadQR to be called on the delegate.")
        XCTAssertNotNil(registrationFlowDelegateMock.capturedViewModel, "Expected a QRReferenceViewModel to be passed to the delegate.")
    }
    
    func testGdprButtonClicked_OpensGdprLink() {
        // Arrange
        viewModel = RegistrationViewModel(
            dependencies: .init(logger: loggerMock, userManager: userManagerMock),
            delegate: registrationFlowDelegateMock
        )
        
        // Act
        viewModel.gdprButtonClicked()
        
        // Assert
        XCTAssertTrue(registrationFlowDelegateMock.openLinkCalled, "Expected openLink to be called on the delegate.")
        XCTAssertEqual(registrationFlowDelegateMock.capturedLink, APIUrl.gdprUrl, "Expected GDPR URL to be passed to openLink.")
    }
    
    func testRulesButtonClicked_OpensRulesLink() {
        // Arrange
        viewModel = RegistrationViewModel(
            dependencies: .init(logger: loggerMock, userManager: userManagerMock),
            delegate: registrationFlowDelegateMock
        )
        
        // Act
        viewModel.rulesButtonClicked()
        
        // Assert
        XCTAssertTrue(registrationFlowDelegateMock.openLinkCalled, "Expected openLink to be called on the delegate.")
        XCTAssertEqual(registrationFlowDelegateMock.capturedLink, APIUrl.rulesUrl, "Expected Rules URL to be passed to openLink.")
    }
}

private extension RegistrationViewModelTests {
    func setValidFormState() {
        viewModel.username = "ValidUser"
        viewModel.email = "valid@example.com"
        viewModel.password = "ValidPassword1"
        viewModel.passwordConfirm = "ValidPassword1"
        viewModel.isGdprConfirmed = true
        viewModel.isRulesConfirmed = true
    }
}
