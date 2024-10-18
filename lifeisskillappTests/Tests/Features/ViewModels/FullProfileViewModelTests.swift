//
//  FullProfileViewModelTests\.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 18.10.2024.
//

import XCTest
@testable import lifeisskillapp

final class FullRegistrationViewModelTests: XCTestCase {
    
    private var viewModel: FullRegistrationViewModel!
    private var mockLogger: LoggingServiceMock!
    private var mockUserManager: UserManagerMock!
    private var mockDelegate: FullRegistrationFlowDelegateMock!
    
    struct MockDependencies: HasLoggers & HasUserManager {
        var logger: LoggerServicing
        var userManager: UserManaging
    }
    
    private var dependencies: MockDependencies!
    
    override func setUp() {
        super.setUp()
        
        // Initialize the mocks
        mockLogger = LoggingServiceMock()
        mockUserManager = UserManagerMock()
        mockDelegate = FullRegistrationFlowDelegateMock()
        
        // Set the dependencies
        dependencies = MockDependencies(
            logger: mockLogger,
            userManager: mockUserManager
        )
    }
    
    override func tearDown() {
        viewModel = nil
        mockLogger = nil
        mockUserManager = nil
        mockDelegate = nil
        dependencies = nil
        super.tearDown()
    }
    
    func testViewModelInitialization() {
        // Arrange
        viewModel = FullRegistrationViewModel(dependencies: dependencies)
        
        // Act
        
        // Assert
        
        // User info fields
        XCTAssertEqual(viewModel.firstName, "", "firstName should be empty on initialization")
        XCTAssertEqual(viewModel.lastName, "", "lastName should be empty on initialization")
        XCTAssertEqual(viewModel.phoneNumber, "", "phoneNumber should be empty on initialization")
        XCTAssertEqual(viewModel.postalCode, "", "postalCode should be empty on initialization")
        XCTAssertEqual(viewModel.gender, .male, "gender should be .male on initialization")
        XCTAssertEqual(viewModel.age, 0, "age should be 0 on initialization")
        XCTAssertTrue(viewModel.isMinor, "isMinor should be true on initialization")
        
        // Guardian info fields
        XCTAssertEqual(viewModel.guardianFirstName, "", "guardianFirstName should be empty on initialization")
        XCTAssertEqual(viewModel.guardianLastName, "", "guardianLastName should be empty on initialization")
        XCTAssertEqual(viewModel.guardianPhoneNumber, "", "guardianPhoneNumber should be empty on initialization")
        XCTAssertEqual(viewModel.guardianEmail, "", "guardianEmail should be empty on initialization")
        XCTAssertEqual(viewModel.guardianRelationship, "", "guardianRelationship should be empty on initialization")
        
        // Countries and Date
        XCTAssertEqual(viewModel.selectedCountry, Country.defaultCountry, "selectedCountry should be defaultCountry on initialization")
        XCTAssertEqual(viewModel.guardianSelectedCountry, Country.defaultCountry, "guardianSelectedCountry should be defaultCountry on initialization")
        XCTAssertEqual(viewModel.dateOfBirth.timeIntervalSinceNow, Date().timeIntervalSinceNow, accuracy: 1, "dateOfBirth should be today on initialization")
        
        // Validation States with `guard let` typecasting and failure messages
        
        // First Name Validation
        guard let firstNameValidation = viewModel.firstNameValidationState as? BasicValidationState else {
            return XCTFail("firstNameValidationState is not of type BasicValidationState")
        }
        XCTAssertEqual(firstNameValidation, .initial, "firstNameValidationState should be .initial on initialization")
        
        // Last Name Validation
        guard let lastNameValidation = viewModel.lastNameValidationState as? BasicValidationState else {
            return XCTFail("lastNameValidationState is not of type BasicValidationState")
        }
        XCTAssertEqual(lastNameValidation, .initial, "lastNameValidationState should be .initial on initialization")
        
        // Phone Number Validation
        guard let phoneNumberValidation = viewModel.phoneNumberValidationState as? PhoneNumberValidationState else {
            return XCTFail("phoneNumberValidationState is not of type PhoneNumberValidationState")
        }
        XCTAssertEqual(phoneNumberValidation, .initial, "phoneNumberValidationState should be .initial on initialization")
        
        // Postal Code Validation
        guard let postalCodeValidation = viewModel.postalCodeValidationState as? BasicValidationState else {
            return XCTFail("postalCodeValidationState is not of type BasicValidationState")
        }
        XCTAssertEqual(postalCodeValidation, .initial, "postalCodeValidationState should be .initial on initialization")
        
        // Guardian First Name Validation
        guard let guardianFirstNameValidation = viewModel.guardianFirstNameValidationState as? BasicValidationState else {
            return XCTFail("guardianFirstNameValidationState is not of type BasicValidationState")
        }
        XCTAssertEqual(guardianFirstNameValidation, .initial, "guardianFirstNameValidationState should be .initial on initialization")
        
        // Guardian Last Name Validation
        guard let guardianLastNameValidation = viewModel.guardianLastNameValidationState as? BasicValidationState else {
            return XCTFail("guardianLastNameValidationState is not of type BasicValidationState")
        }
        XCTAssertEqual(guardianLastNameValidation, .initial, "guardianLastNameValidationState should be .initial on initialization")
        
        // Guardian Phone Number Validation
        guard let guardianPhoneNumberValidation = viewModel.guardianPhoneNumberValidationState as? PhoneNumberValidationState else {
            return XCTFail("guardianPhoneNumberValidationState is not of type PhoneNumberValidationState")
        }
        XCTAssertEqual(guardianPhoneNumberValidation, .initial, "guardianPhoneNumberValidationState should be .initial on initialization")
        
        // Guardian Email Validation
        guard let guardianEmailValidation = viewModel.guardianEmailValidationState as? GuardianEmailValidationState else {
            return XCTFail("guardianEmailValidationState is not of type GuardianEmailValidationState")
        }
        XCTAssertEqual(guardianEmailValidation, GuardianEmailValidationState.base(.initial), "guardianEmailValidationState should be .initial on initialization")
        
        // Guardian Relationship Validation
        guard let guardianRelationshipValidation = viewModel.guardianRelationshipValidationState as? BasicValidationState else {
            return XCTFail("guardianRelationshipValidationState is not of type BasicValidationState")
        }
        XCTAssertEqual(guardianRelationshipValidation, .initial, "guardianRelationshipValidationState should be .initial on initialization")
        
        // Form validation
        XCTAssertFalse(viewModel.isFormValid, "isFormValid should be false on initialization")
    }
    
    func testFirstNameValidationChangesToEmptyWhenFirstNameIsEmpty() {
        // Arrange
        viewModel = FullRegistrationViewModel(dependencies: dependencies)
        
        // Act: Set first name to an empty string
        viewModel.firstName = ""
        
        // Assert: Check that the validation state is updated to `.empty`
        guard let firstNameValidation = viewModel.firstNameValidationState as? BasicValidationState else {
            return XCTFail("firstNameValidationState is not of type BasicValidationState")
        }
        
        XCTAssertEqual(firstNameValidation, .empty, "firstNameValidationState should be .empty when firstName is empty")
    }
    
    func testLastNameValidationChangesToEmptyWhenLastNameIsEmpty() {
        // Arrange
        viewModel = FullRegistrationViewModel(dependencies: dependencies)
        
        // Act: Set last name to an empty string
        viewModel.lastName = ""
        
        // Assert: Check that the validation state is updated to `.empty`
        guard let lastNameValidation = viewModel.lastNameValidationState as? BasicValidationState else {
            return XCTFail("lastNameValidationState is not of type BasicValidationState")
        }
        
        XCTAssertEqual(lastNameValidation, .empty, "lastNameValidationState should be .empty when lastName is empty")
    }
    
    func testGuardianFirstNameValidationChangesToEmptyWhenGuardianFirstNameIsEmpty() {
        // Arrange
        viewModel = FullRegistrationViewModel(dependencies: dependencies)
        
        // Act: Set guardian first name to an empty string
        viewModel.guardianFirstName = ""
        
        // Assert: Check that the validation state is updated to `.empty`
        guard let guardianFirstNameValidation = viewModel.guardianFirstNameValidationState as? BasicValidationState else {
            return XCTFail("guardianFirstNameValidationState is not of type BasicValidationState")
        }
        
        XCTAssertEqual(guardianFirstNameValidation, .empty, "guardianFirstNameValidationState should be .empty when guardianFirstName is empty")
    }
    
    func testGuardianLastNameValidationChangesToEmptyWhenGuardianLastNameIsEmpty() {
        // Arrange
        viewModel = FullRegistrationViewModel(dependencies: dependencies)
        
        // Act: Set guardian last name to an empty string
        viewModel.guardianLastName = ""
        
        // Assert: Check that the validation state is updated to `.empty`
        guard let guardianLastNameValidation = viewModel.guardianLastNameValidationState as? BasicValidationState else {
            return XCTFail("guardianLastNameValidationState is not of type BasicValidationState")
        }
        
        XCTAssertEqual(guardianLastNameValidation, .empty, "guardianLastNameValidationState should be .empty when guardianLastName is empty")
    }
    
    func testGuardianRelationshipValidationChangesToEmptyWhenGuardianRelationshipIsEmpty() {
        // Arrange
        viewModel = FullRegistrationViewModel(dependencies: dependencies)
        
        // Act: Set guardian relationship to an empty string
        viewModel.guardianRelationship = ""
        
        // Assert: Check that the validation state is updated to `.empty`
        guard let guardianRelationshipValidation = viewModel.guardianRelationshipValidationState as? BasicValidationState else {
            return XCTFail("guardianRelationshipValidationState is not of type BasicValidationState")
        }
        
        XCTAssertEqual(guardianRelationshipValidation, .empty, "guardianRelationshipValidationState should be .empty when guardianRelationship is empty")
    }
    
    func testDefaultCountryIsCzechRepublic() {
        // Arrange
        viewModel = FullRegistrationViewModel(dependencies: dependencies)
        
        // Act
        let czechRepublic = Country.czechia
        
        // Assert
        XCTAssertEqual(viewModel.selectedCountry, czechRepublic, "selectedCountry should be Czech Republic by default")
        XCTAssertEqual(viewModel.guardianSelectedCountry, czechRepublic, "guardianSelectedCountry should be Czech Republic by default")
    }
    
    func testPhoneNumberValidationChangesToInvalidWhenNonNumeric() {
        // Arrange
        viewModel = FullRegistrationViewModel(dependencies: dependencies)
        viewModel.phoneNumber = "123456789"
        
        // Act & Assert (Valid case)
        guard let initialPhoneNumberValidation = viewModel.phoneNumberValidationState as? PhoneNumberValidationState else {
            return XCTFail("phoneNumberValidationState is not of type PhoneNumberValidationState")
        }
        XCTAssertEqual(initialPhoneNumberValidation, .valid, "phoneNumberValidationState should be .valid when phone number is valid")
        
        // Act: Set phone number to a non-numeric string
        viewModel.phoneNumber = "12345678a"
        
        // Assert: Check that the validation state is `.invalidFormat`
        guard let updatedPhoneNumberValidation = viewModel.phoneNumberValidationState as? PhoneNumberValidationState else {
            return XCTFail("phoneNumberValidationState is not of type PhoneNumberValidationState after setting invalid phone number")
        }
        XCTAssertEqual(updatedPhoneNumberValidation, .invalidFormat, "phoneNumberValidationState should be .invalidFormat when phone number contains non-numeric characters")
    }
    
    func testPhoneNumberValidationChangesToInvalidWhenLengthIsIncorrect() {
        // Arrange
        viewModel = FullRegistrationViewModel(dependencies: dependencies)
        viewModel.selectedCountry = Country.czechia
        
        // Act
        viewModel.phoneNumber = "1234567"
        
        // Assert: Check that the validation state is `.invalidFormat`
        guard let phoneNumberValidation = viewModel.phoneNumberValidationState as? PhoneNumberValidationState else {
            return XCTFail("phoneNumberValidationState is not of type PhoneNumberValidationState")
        }
        
        XCTAssertEqual(phoneNumberValidation, .invalidFormat, "phoneNumberValidationState should be .invalidFormat when phone number length is different from the selected country's phone length")
    }
    
    func testPhoneNumberValidationIsValidWhenLengthMatches() {
        // Arrange
        viewModel = FullRegistrationViewModel(dependencies: dependencies)
        viewModel.selectedCountry = Country.czechia
        
        // Act
        viewModel.phoneNumber = "123456789"
        
        // Assert
        guard let phoneNumberValidation = viewModel.phoneNumberValidationState as? PhoneNumberValidationState else {
            return XCTFail("phoneNumberValidationState is not of type PhoneNumberValidationState")
        }
        
        XCTAssertEqual(phoneNumberValidation, .valid, "phoneNumberValidationState should be .valid when phone number length matches the selected country's phone length")
    }
    
    func testPhoneNumberValidationIsValidWhenLengthIsWithinRange() {
        // Arrange: Create a made-up country with phone length range 6 to 10
        let madeUpCountry = Country(
            label: "MadeUpLand",
            phone: "999",
            code: "MU",
            phoneLength: .range([6, 7, 8, 9, 10]) // Valid phone lengths are 6 to 10
        )
        
        viewModel = FullRegistrationViewModel(dependencies: dependencies)
        viewModel.selectedCountry = madeUpCountry
        
        // Act & Assert: Test phone number with valid lengths within the range
        
        // Test with 6 digits (valid)
        viewModel.phoneNumber = "123456"
        guard let phoneNumberValidation6 = viewModel.phoneNumberValidationState as? PhoneNumberValidationState else {
            return XCTFail("phoneNumberValidationState is not of type PhoneNumberValidationState for 6 digits")
        }
        XCTAssertEqual(phoneNumberValidation6, .valid, "phoneNumberValidationState should be .valid for 6-digit phone number")
        
        // Test with 8 digits (valid)
        viewModel.phoneNumber = "12345678"
        guard let phoneNumberValidation8 = viewModel.phoneNumberValidationState as? PhoneNumberValidationState else {
            return XCTFail("phoneNumberValidationState is not of type PhoneNumberValidationState for 8 digits")
        }
        XCTAssertEqual(phoneNumberValidation8, .valid, "phoneNumberValidationState should be .valid for 8-digit phone number")
        
        // Test with 10 digits (valid)
        viewModel.phoneNumber = "1234567890"
        guard let phoneNumberValidation10 = viewModel.phoneNumberValidationState as? PhoneNumberValidationState else {
            return XCTFail("phoneNumberValidationState is not of type PhoneNumberValidationState for 10 digits")
        }
        XCTAssertEqual(phoneNumberValidation10, .valid, "phoneNumberValidationState should be .valid for 10-digit phone number")
        
        // Act & Assert: Test phone number with invalid lengths outside the range
        
        // Test with 5 digits (invalid)
        viewModel.phoneNumber = "12345"
        guard let phoneNumberValidation5 = viewModel.phoneNumberValidationState as? PhoneNumberValidationState else {
            return XCTFail("phoneNumberValidationState is not of type PhoneNumberValidationState for 5 digits")
        }
        XCTAssertEqual(phoneNumberValidation5, .invalidFormat, "phoneNumberValidationState should be .invalidFormat for 5-digit phone number")
        
        // Test with 11 digits (invalid)
        viewModel.phoneNumber = "12345678901"
        guard let phoneNumberValidation11 = viewModel.phoneNumberValidationState as? PhoneNumberValidationState else {
            return XCTFail("phoneNumberValidationState is not of type PhoneNumberValidationState for 11 digits")
        }
        XCTAssertEqual(phoneNumberValidation11, .invalidFormat, "phoneNumberValidationState should be .invalidFormat for 11-digit phone number")
    }
    
    func testGuardianPhoneNumberValidationChangesToInvalidWhenNonNumeric() {
        // Arrange
        viewModel = FullRegistrationViewModel(dependencies: dependencies)
        viewModel.guardianPhoneNumber = "123456789"
        
        // Act & Assert (Valid case)
        guard let initialGuardianPhoneNumberValidation = viewModel.guardianPhoneNumberValidationState as? PhoneNumberValidationState else {
            return XCTFail("guardianPhoneNumberValidationState is not of type PhoneNumberValidationState")
        }
        XCTAssertEqual(initialGuardianPhoneNumberValidation, .valid, "guardianPhoneNumberValidationState should be .valid when guardian phone number is valid")
        
        // Act: Set guardian phone number to a non-numeric string
        viewModel.guardianPhoneNumber = "12345678a"
        
        // Assert: Check that the validation state is `.invalidFormat`
        guard let updatedGuardianPhoneNumberValidation = viewModel.guardianPhoneNumberValidationState as? PhoneNumberValidationState else {
            return XCTFail("guardianPhoneNumberValidationState is not of type PhoneNumberValidationState after setting invalid guardian phone number")
        }
        XCTAssertEqual(updatedGuardianPhoneNumberValidation, .invalidFormat, "guardianPhoneNumberValidationState should be .invalidFormat when guardian phone number contains non-numeric characters")
    }
    
    func testGuardianPhoneNumberValidationChangesToInvalidWhenLengthIsIncorrect() {
        // Arrange
        viewModel = FullRegistrationViewModel(dependencies: dependencies)
        viewModel.guardianSelectedCountry = Country.czechia
        
        // Act
        viewModel.guardianPhoneNumber = "1234567"
        
        // Assert: Check that the validation state is `.invalidFormat`
        guard let phoneNumberValidation = viewModel.guardianPhoneNumberValidationState as? PhoneNumberValidationState else {
            return XCTFail("guardianPhoneNumberValidationState is not of type PhoneNumberValidationState")
        }
        
        XCTAssertEqual(phoneNumberValidation, .invalidFormat, "guardianPhoneNumberValidationState should be .invalidFormat when phone number length is different from the selected country's phone length")
    }
    
    func testGuardianPhoneNumberValidationIsValidWhenLengthMatches() {
        // Arrange
        viewModel = FullRegistrationViewModel(dependencies: dependencies)
        viewModel.guardianSelectedCountry = Country.czechia
        
        // Act
        viewModel.guardianPhoneNumber = "123456789"
        
        // Assert
        guard let phoneNumberValidation = viewModel.guardianPhoneNumberValidationState as? PhoneNumberValidationState else {
            return XCTFail("guardianPhoneNumberValidationState is not of type PhoneNumberValidationState")
        }
        
        XCTAssertEqual(phoneNumberValidation, .valid, "guardianPhoneNumberValidationState should be .valid when phone number length matches the selected country's phone length")
    }
    
    func testGuardianPhoneNumberValidationIsValidWhenLengthIsWithinRange() {
        // Arrange: Create a made-up country with phone length range 6 to 10
        let madeUpCountry = Country(
            label: "MadeUpLand",
            phone: "999",
            code: "MU",
            phoneLength: .range([6, 7, 8, 9, 10]) // Valid phone lengths are 6 to 10
        )
        
        viewModel = FullRegistrationViewModel(dependencies: dependencies)
        viewModel.guardianSelectedCountry = madeUpCountry
        
        // Act & Assert: Test guardian phone number with valid lengths within the range
        
        // Test with 6 digits (valid)
        viewModel.guardianPhoneNumber = "123456"
        guard let phoneNumberValidation6 = viewModel.guardianPhoneNumberValidationState as? PhoneNumberValidationState else {
            return XCTFail("guardianPhoneNumberValidationState is not of type PhoneNumberValidationState for 6 digits")
        }
        XCTAssertEqual(phoneNumberValidation6, .valid, "guardianPhoneNumberValidationState should be .valid for 6-digit phone number")
        
        // Test with 8 digits (valid)
        viewModel.guardianPhoneNumber = "12345678"
        guard let phoneNumberValidation8 = viewModel.guardianPhoneNumberValidationState as? PhoneNumberValidationState else {
            return XCTFail("guardianPhoneNumberValidationState is not of type PhoneNumberValidationState for 8 digits")
        }
        XCTAssertEqual(phoneNumberValidation8, .valid, "guardianPhoneNumberValidationState should be .valid for 8-digit phone number")
        
        // Test with 10 digits (valid)
        viewModel.guardianPhoneNumber = "1234567890"
        guard let phoneNumberValidation10 = viewModel.guardianPhoneNumberValidationState as? PhoneNumberValidationState else {
            return XCTFail("guardianPhoneNumberValidationState is not of type PhoneNumberValidationState for 10 digits")
        }
        XCTAssertEqual(phoneNumberValidation10, .valid, "guardianPhoneNumberValidationState should be .valid for 10-digit phone number")
        
        // Act & Assert: Test guardian phone number with invalid lengths outside the range
        
        // Test with 5 digits (invalid)
        viewModel.guardianPhoneNumber = "12345"
        guard let phoneNumberValidation5 = viewModel.guardianPhoneNumberValidationState as? PhoneNumberValidationState else {
            return XCTFail("guardianPhoneNumberValidationState is not of type PhoneNumberValidationState for 5 digits")
        }
        XCTAssertEqual(phoneNumberValidation5, .invalidFormat, "guardianPhoneNumberValidationState should be .invalidFormat for 5-digit phone number")
        
        // Test with 11 digits (invalid)
        viewModel.guardianPhoneNumber = "12345678901"
        guard let phoneNumberValidation11 = viewModel.guardianPhoneNumberValidationState as? PhoneNumberValidationState else {
            return XCTFail("guardianPhoneNumberValidationState is not of type PhoneNumberValidationState for 11 digits")
        }
        XCTAssertEqual(phoneNumberValidation11, .invalidFormat, "guardianPhoneNumberValidationState should be .invalidFormat for 11-digit phone number")
    }
    
    func testAgeIsCalculatedCorrectlyBasedOnDateOfBirth() {
        // Arrange
        viewModel = FullRegistrationViewModel(dependencies: dependencies)
        
        // Act: Set dateOfBirth to a date 20 years ago
        let calendar = Calendar.current
        let twentyYearsAgo = calendar.date(byAdding: .year, value: -20, to: Date())!
        viewModel.dateOfBirth = twentyYearsAgo
        
        // Assert: Check if the age is 20
        XCTAssertEqual(viewModel.age, 20, "Age should be 20 when dateOfBirth is set to 20 years ago")
        
        // Act: Set dateOfBirth to a date 5 years ago
        let fiveYearsAgo = calendar.date(byAdding: .year, value: -5, to: Date())!
        viewModel.dateOfBirth = fiveYearsAgo
        
        // Assert: Check if the age is 5
        XCTAssertEqual(viewModel.age, 5, "Age should be 5 when dateOfBirth is set to 5 years ago")
        
        // Act: Set dateOfBirth to today's date
        viewModel.dateOfBirth = Date()
        
        // Assert: Check if the age is 0
        XCTAssertEqual(viewModel.age, 0, "Age should be 0 when dateOfBirth is set to today")
        
        // Act: Set dateOfBirth to a date in the future (invalid case)
        let futureDate = calendar.date(byAdding: .year, value: 1, to: Date())!
        viewModel.dateOfBirth = futureDate
        
        // Assert: Check if the age is still 0 (since it's in the future, age calculation should fail gracefully)
        XCTAssertEqual(viewModel.age, 0, "Age should be 0 when dateOfBirth is in the future")
    }
    
    func testIsMinorBasedOnAge() {
        // Arrange
        viewModel = FullRegistrationViewModel(dependencies: dependencies)
        let calendar = Calendar.current
        
        // Act & Assert: Set dateOfBirth to 14 years ago (age = 14, isMinor should be true)
        let fourteenYearsAgo = calendar.date(byAdding: .year, value: -14, to: Date())!
        viewModel.dateOfBirth = fourteenYearsAgo
        XCTAssertTrue(viewModel.isMinor, "isMinor should be true when age is 14")
        
        // Act & Assert: Set dateOfBirth to 15 years ago (age = 15, isMinor should be false)
        let fifteenYearsAgo = calendar.date(byAdding: .year, value: -15, to: Date())!
        viewModel.dateOfBirth = fifteenYearsAgo
        XCTAssertFalse(viewModel.isMinor, "isMinor should be false when age is 15")
        
        // Act & Assert: Set dateOfBirth to 16 years ago (age = 16, isMinor should be false)
        let sixteenYearsAgo = calendar.date(byAdding: .year, value: -16, to: Date())!
        viewModel.dateOfBirth = sixteenYearsAgo
        XCTAssertFalse(viewModel.isMinor, "isMinor should be false when age is 16")
        
        // Act & Assert: Set dateOfBirth to 13 years ago (age = 13, isMinor should be true)
        let thirteenYearsAgo = calendar.date(byAdding: .year, value: -13, to: Date())!
        viewModel.dateOfBirth = thirteenYearsAgo
        XCTAssertTrue(viewModel.isMinor, "isMinor should be true when age is 13")
    }
    
    func testIsFormValid_UserIs15AndAbove() {
        // Arrange
        viewModel = FullRegistrationViewModel(dependencies: dependencies)
        
        // Act: Set valid user info for a user aged 15+
        viewModel.firstName = "ValidFirstName"
        viewModel.lastName = "ValidLastName"
        viewModel.phoneNumber = "123456789"
        viewModel.postalCode = "12345"
        viewModel.selectedCountry = Country.czechia
        let fifteenYearsAgo = Calendar.current.date(byAdding: .year, value: -15, to: Date())!
        viewModel.dateOfBirth = fifteenYearsAgo // Age = 15
        
        // Assert: Form should be valid
        XCTAssertTrue(viewModel.isFormValid, "Form should be valid when all user fields are valid for a 15-year-old.")
        
        // Act: Make one field invalid (e.g., phone number)
        viewModel.phoneNumber = ""
        
        // Assert: Form should be invalid now
        XCTAssertFalse(viewModel.isFormValid, "Form should be invalid when any user field is invalid for a 15-year-old.")
    }
    
    func testIsFormValid_UserIsBelow15() {
        // Arrange
        viewModel = FullRegistrationViewModel(dependencies: dependencies)
        
        // Act: Set valid user and guardian info for a user below 15
        viewModel.firstName = "ValidFirstName"
        viewModel.lastName = "ValidLastName"
        viewModel.phoneNumber = "123456789"
        viewModel.postalCode = "12345"
        viewModel.selectedCountry = Country.czechia
        let fourteenYearsAgo = Calendar.current.date(byAdding: .year, value: -14, to: Date())!
        viewModel.dateOfBirth = fourteenYearsAgo // Age = 14
        
        viewModel.guardianFirstName = "ValidGuardianFirstName"
        viewModel.guardianLastName = "ValidGuardianLastName"
        viewModel.guardianPhoneNumber = "123456789"
        viewModel.guardianEmail = "guardian@example.com"
        viewModel.guardianRelationship = "Parent"
        
        // Assert: Form should be valid when both user and guardian fields are valid
        XCTAssertTrue(viewModel.isFormValid, "Form should be valid when all user and guardian fields are valid for a 14-year-old.")
        
        // Act: Make one guardian field invalid (e.g., guardian email)
        viewModel.guardianEmail = ""
        
        // Assert: Form should be invalid
        XCTAssertFalse(viewModel.isFormValid, "Form should be invalid when any guardian field is invalid for a user below 15.")
    }
    
    func testIsFormValid_UserIsBelow15_InvalidUserField() {
        // Arrange
        viewModel = FullRegistrationViewModel(dependencies: dependencies)
        
        // Act: Set valid guardian info, but an invalid user field (e.g., empty firstName)
        let fourteenYearsAgo = Calendar.current.date(byAdding: .year, value: -14, to: Date())!
        viewModel.dateOfBirth = fourteenYearsAgo // Age = 14
        viewModel.firstName = "" // Invalid firstName
        viewModel.lastName = "ValidLastName"
        viewModel.phoneNumber = "123456789"
        viewModel.postalCode = "12345"
        viewModel.selectedCountry = Country.czechia
        
        viewModel.guardianFirstName = "ValidGuardianFirstName"
        viewModel.guardianLastName = "ValidGuardianLastName"
        viewModel.guardianPhoneNumber = "123456789"
        viewModel.guardianEmail = "guardian@example.com"
        viewModel.guardianRelationship = "Parent"
        
        // Assert: Form should be invalid due to invalid user field
        XCTAssertFalse(viewModel.isFormValid, "Form should be invalid when any user field is invalid, even if guardian fields are valid for a user below 15.")
    }
    
    func testIsFormValid_UserIsAbove15_InvalidGuardianFields() {
        // Arrange
        viewModel = FullRegistrationViewModel(dependencies: dependencies)
        
        // Act: Set valid user info and invalid guardian info for a user aged 16 (guardian fields should be ignored)
        let sixteenYearsAgo = Calendar.current.date(byAdding: .year, value: -16, to: Date())!
        viewModel.dateOfBirth = sixteenYearsAgo // Age = 16
        
        viewModel.firstName = "ValidFirstName"
        viewModel.lastName = "ValidLastName"
        viewModel.phoneNumber = "123456789"
        viewModel.postalCode = "12345"
        viewModel.selectedCountry = Country.czechia
        
        viewModel.guardianFirstName = ""
        viewModel.guardianLastName = ""
        viewModel.guardianPhoneNumber = ""
        viewModel.guardianEmail = ""
        viewModel.guardianRelationship = ""
        
        // Assert: Form should still be valid as guardian fields are ignored for a user aged 15+
        XCTAssertTrue(viewModel.isFormValid, "Form should be valid even if guardian fields are invalid for a user aged 16+.")
    }
    
    func testGuardianEmailValidationWithPattern() {
        // Arrange
        let mockUser = LoggedInUser.mock(email: "mock@user.com")
        let mockUserManager = UserManagerMock()
        mockUserManager.loggedInUser = mockUser
        dependencies.userManager = mockUserManager
        viewModel = FullRegistrationViewModel(dependencies: dependencies)
        
        // Act & Assert: Valid email with complex format
        viewModel.guardianEmail = "user+name@sub.domain-example.co.uk"
        guard let validEmailValidation1 = viewModel.guardianEmailValidationState as? GuardianEmailValidationState else {
            return XCTFail("guardianEmailValidationState is not of type GuardianEmailValidationState")
        }
        XCTAssertEqual(validEmailValidation1, .base(.valid), "guardianEmailValidationState should be .valid for a correctly formatted email with complex format")
        
        // Act & Assert: Invalid email with consecutive dots
        viewModel.guardianEmail = "user..name@domain.com"
        guard let invalidEmailValidation1 = viewModel.guardianEmailValidationState as? GuardianEmailValidationState else {
            return XCTFail("guardianEmailValidationState is not of type GuardianEmailValidationState")
        }
        XCTAssertEqual(invalidEmailValidation1, .base(.invalidFormat), "guardianEmailValidationState should be .invalidFormat for an email with consecutive dots")
        
        // Act & Assert: Valid email with special characters
        viewModel.guardianEmail = "user!#$%&'*+-/=?^_`{|}~@domain.com"
        guard let validEmailValidation2 = viewModel.guardianEmailValidationState as? GuardianEmailValidationState else {
            return XCTFail("guardianEmailValidationState is not of type GuardianEmailValidationState")
        }
        XCTAssertEqual(validEmailValidation2, .base(.valid), "guardianEmailValidationState should be .valid for an email with valid special characters")
        
        // Act & Assert: Invalid email (missing '@')
        viewModel.guardianEmail = "testdomain.com"
        guard let invalidEmailValidation2 = viewModel.guardianEmailValidationState as? GuardianEmailValidationState else {
            return XCTFail("guardianEmailValidationState is not of type GuardianEmailValidationState")
        }
        XCTAssertEqual(invalidEmailValidation2, .base(.invalidFormat), "guardianEmailValidationState should be .invalidFormat when '@' is missing")
        
        // Act & Assert: Guardian email matches user email (should return .matchesUserEmail)
        viewModel.guardianEmail = "mock@user.com" // Same as logged-in user's email
        guard let matchesUserEmailValidation = viewModel.guardianEmailValidationState as? GuardianEmailValidationState else {
            return XCTFail("guardianEmailValidationState is not of type GuardianEmailValidationState")
        }
        XCTAssertEqual(matchesUserEmailValidation, .matchesUserEmail, "guardianEmailValidationState should be .matchesUserEmail when the guardian's email matches the logged-in user's email")
    }
    
    func testSubmitFullRegistration_DoesNotCallUserManagerOrDelegate_WhenFormIsInvalid() {
        // Arrange
        viewModel = FullRegistrationViewModel(dependencies: dependencies)
        viewModel.firstName = ""
        
        // Act
        viewModel.submitFullRegistration()
        
        // Assert: UserManager and delegate should not be called
        XCTAssertFalse(mockUserManager.completeUserRegistrationCalled, "completeUserRegistration should not be called if the form is invalid.")
        XCTAssertFalse(mockDelegate.registrationDidSucceedAdultCalled, "registrationDidSucceedAdult should not be called if the form is invalid.")
        XCTAssertFalse(mockDelegate.registrationDidSucceedMinorCalled, "registrationDidSucceedMinor should not be called if the form is invalid.")
        XCTAssertFalse(mockDelegate.registrationDidFailCalled, "registrationDidFail should not be called if the form is invalid.")
    }
    
    func testSubmitFullRegistration_WhenFormIsValid_CallsUserManagerWithCorrectCredentials() async {
        // Arrange
        viewModel = FullRegistrationViewModel(dependencies: dependencies, delegate: mockDelegate)
        viewModel.firstName = "John"
        viewModel.lastName = "Doe"
        viewModel.phoneNumber = "123456789"
        viewModel.dateOfBirth = Calendar.current.date(byAdding: .year, value: -18, to: Date())! // Valid adult age
        viewModel.postalCode = "12345"
        viewModel.gender = .male
        
        // Create expectation to wait for the async task
        let expectation = expectation(description: "submitFullRegistration should complete")
        
        // Act
        Task {
            viewModel.submitFullRegistration()
            // Fulfill the expectation once the task completes
            expectation.fulfill()
        }
        
        // Wait for the task to complete
        await fulfillment(of: [expectation], timeout: 5)

        // Assert
        XCTAssertTrue(mockUserManager.completeUserRegistrationCalled, "completeUserRegistration should be called")
        XCTAssertEqual(mockUserManager.fullRegistrationCredentialsPassed?.firstName, "John", "First name should be passed correctly")
        XCTAssertTrue(mockDelegate.registrationDidSucceedAdultCalled, "Delegate should be called when registration succeeds for an adult")
    }
    
    func testSubmitFullRegistration_WhenUserIsAdult_CallsDelegateForAdult() async {
        // Arrange
        viewModel = FullRegistrationViewModel(dependencies: dependencies, delegate: mockDelegate)
        viewModel.firstName = "John"
        viewModel.lastName = "Doe"
        viewModel.phoneNumber = "123456789"
        viewModel.dateOfBirth = Calendar.current.date(byAdding: .year, value: -18, to: Date())! // Valid adult age
        viewModel.postalCode = "12345"
        viewModel.gender = .male
        
        // Mock response indicating user is an adult (no parent activation required)
        mockUserManager.completeUserRegistrationReturnValue = .mock(completionStatus: true, needParentActivation: false)
        
        // Create expectation to wait for the async task
        let expectation = expectation(description: "submitFullRegistration should complete")
        
        // Act
        Task {
            viewModel.submitFullRegistration()
            expectation.fulfill()
        }
        
        // Wait for the task to complete
        await fulfillment(of: [expectation], timeout: 5)

        // Assert that delegate method for adult is called
        XCTAssertTrue(mockDelegate.registrationDidSucceedAdultCalled, "Delegate should be called when registration succeeds for an adult")
        XCTAssertFalse(mockDelegate.registrationDidSucceedMinorCalled, "Delegate should not be called for minor")
    }
    
    func testSubmitFullRegistration_WhenUserIsMinor_CallsDelegateForMinor() async {
        // Arrange
        mockUserManager.completeUserRegistrationReturnValue = .mock(completionStatus: false, needParentActivation: true)
        viewModel = FullRegistrationViewModel(dependencies: dependencies, delegate: mockDelegate)
        
        // Fill in the user information
        viewModel.firstName = "John"
        viewModel.lastName = "Doe"
        viewModel.phoneNumber = "123456789"
        viewModel.dateOfBirth = Calendar.current.date(byAdding: .year, value: -14, to: Date())! // Minor age
        viewModel.postalCode = "12345"
        viewModel.gender = .male
        
        // Fill in the guardian information
        viewModel.guardianFirstName = "Jane"
        viewModel.guardianLastName = "Doe"
        viewModel.guardianPhoneNumber = "987654321"
        viewModel.guardianEmail = "jane.doe@example.com"
        viewModel.guardianRelationship = "Parent"
        
        // Create expectation to wait for the async task
        let expectation = expectation(description: "submitFullRegistration should complete")
        
        // Act
        Task {
            viewModel.submitFullRegistration()
            expectation.fulfill()
        }
        
        // Wait for the task to complete
        await fulfillment(of: [expectation], timeout: 5)

        // Assert that delegate method for minor is called
        XCTAssertTrue(mockDelegate.registrationDidSucceedMinorCalled, "Delegate should be called when registration succeeds for a minor")
        XCTAssertFalse(mockDelegate.registrationDidSucceedAdultCalled, "Delegate should not be called for adult")
    }
    func testSubmitFullRegistration_WhenUserIsMinor_CallsDelegateForError() async {
        // Arrange
        mockUserManager.errorToThrow = BaseError(
            context: .system,
            logger: mockLogger
        )
        viewModel = FullRegistrationViewModel(dependencies: dependencies, delegate: mockDelegate)
        
        // Fill in the user information
        viewModel.firstName = "John"
        viewModel.lastName = "Doe"
        viewModel.phoneNumber = "123456789"
        viewModel.dateOfBirth = Calendar.current.date(byAdding: .year, value: -14, to: Date())! // Minor age
        viewModel.postalCode = "12345"
        viewModel.gender = .male
        
        // Fill in the guardian information
        viewModel.guardianFirstName = "Jane"
        viewModel.guardianLastName = "Doe"
        viewModel.guardianPhoneNumber = "987654321"
        viewModel.guardianEmail = "jane.doe@example.com"
        viewModel.guardianRelationship = "Parent"
    
        
        // Create expectation to wait for the async task
        let expectation = expectation(description: "submitFullRegistration should complete")
        
        // Act
        Task {
            viewModel.submitFullRegistration()
            expectation.fulfill()
        }
        
        // Wait for the task to complete
        await fulfillment(of: [expectation], timeout: 5)

        // Assert that delegate method for minor is called
        XCTAssertTrue(mockDelegate.registrationDidFailCalled, "Delegate should be called when registration fails")
    }
}
