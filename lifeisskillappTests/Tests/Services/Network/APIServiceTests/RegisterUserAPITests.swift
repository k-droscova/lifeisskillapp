//
//  RegisterUserAPITests.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 29.09.2024.
//

import XCTest
@testable import lifeisskillapp

final class RegisterUserAPIServiceTests: XCTestCase {
    
    private struct Dependencies: RegisterUserAPIService.Dependencies {
        let network: Networking
        let logger: LoggerServicing
        let storage: PersistentUserDataStoraging
    }
    
    var networkMock: NetworkingMock!
    var loggerMock: LoggerServicing!
    var storageMock: PersistentUserDataStorageMock!
    var service: RegisterUserAPIServicing!
    
    override func setUpWithError() throws {
        networkMock = NetworkingMock()
        loggerMock = LoggingServiceMock()
        storageMock = PersistentUserDataStorageMock()
        let dependencies = Dependencies(network: networkMock, logger: loggerMock, storage: storageMock)
        service = RegisterUserAPIService(dependencies: dependencies)
    }
    
    override func tearDownWithError() throws {
        networkMock = nil
        loggerMock = nil
        storageMock = nil
        service = nil
    }
}

// MARK: - Testing that each protocol func calls API with correct request

extension RegisterUserAPIServiceTests {
    
    func testCheckUsernameAvailabilityCallsAPIWithCorrectRequest() async throws {
        do {
            // Arrange
            let username = "mockUsername"
            let expectedURL = URL(string: "https://api-test.lifeisskill.cz/v1.0/nick/\(username)/check")!
            let mockResponse = APIResponse(data: UsernameAvailabilityResponse.mock())
            networkMock.responseToReturn = mockResponse
            
            // Act
            _ = try await service.checkUsernameAvailability(username)
            
            // Assert
            XCTAssertEqual(networkMock.capturedMethod, .GET, "HTTP method should be GET")
            XCTAssertEqual(networkMock.capturedURL, expectedURL, "The URL should match the check username availability endpoint")
            XCTAssertNil(networkMock.capturedBody, "The request body should be nil for a GET request")
        } catch {
            XCTFail("Unexpected error thrown: \(error)")
        }
    }
    
    func testCheckEmailAvailabilityCallsAPIWithCorrectRequest() async throws {
        do {
            // Arrange
            let email = "mockEmail@example.com"
            let expectedURL = URL(string: "https://api-test.lifeisskill.cz/v1.0/email/\(email)/check")!
            let mockResponse = APIResponse(data: EmailAvailabilityResponse.mock())
            networkMock.responseToReturn = mockResponse
            
            // Act
            _ = try await service.checkEmailAvailability(email)
            
            // Assert
            XCTAssertEqual(networkMock.capturedMethod, .GET, "HTTP method should be GET")
            XCTAssertEqual(networkMock.capturedURL, expectedURL, "The URL should match the check email availability endpoint")
            XCTAssertNil(networkMock.capturedBody, "The request body should be nil for a GET request")
        } catch {
            XCTFail("Unexpected error thrown: \(error)")
        }
    }
    
    func testRegisterUserCallsAPIWithCorrectRequestHeaders() async throws {
        do {
            // Arrange
            let credentials = NewRegistrationCredentials.mock()
            let location = UserLocation.mock()
            let expectedURL = URL(string: "https://api-test.lifeisskill.cz/v1.0/users")!
            let mockResponse = APIResponse(data: RegistrationResponse.mock())
            networkMock.responseToReturn = mockResponse
            
            // Act
            _ = try await service.registerUser(credentials: credentials, location: location)
            
            // Assert
            XCTAssertEqual(networkMock.capturedMethod, .POST, "HTTP method should be POST")
            XCTAssertEqual(networkMock.capturedURL, expectedURL, "The URL should match the registration endpoint")
        } catch {
            XCTFail("Unexpected error thrown: \(error)")
        }
    }
    
    func testRegisterUserCallsAPIWithCorrectRequestBodyWithoutRefId() async throws {
        do {
            // Arrange
            let credentials = NewRegistrationCredentials.mock(
                username: "testUser",
                email: "testUser@example.com",
                password: "password123"
            )
            let location = UserLocation.mock(
                latitude: 50.087236,
                longitude: 14.4155773,
                altitude: 237.8,
                accuracy: 12.58
            )
            let mockResponse = APIResponse(data: RegistrationResponse.mock())
            networkMock.responseToReturn = mockResponse
            
            // Act
            _ = try await service.registerUser(credentials: credentials, location: location)
            
            // Assert
            guard let capturedBody = networkMock.capturedBody,
                  let bodyDict = try JSONSerialization.jsonObject(with: capturedBody, options: []) as? [String: Any] else {
                XCTFail("Captured body is not valid JSON")
                return
            }
            
            // Check keys in the body
            XCTAssertEqual(bodyDict["nick"] as? String, credentials.username, "The username should match the credentials")
            XCTAssertEqual(bodyDict["email"] as? String, credentials.email, "The email should match the credentials")
            XCTAssertEqual(bodyDict["pswd"] as? String, credentials.password, "The password should match the credentials")
            XCTAssertEqual(bodyDict["lat"] as? String, "\(location.latitude)", "The latitude should match the location data")
            XCTAssertEqual(bodyDict["lng"] as? String, "\(location.longitude)", "The longitude should match the location data")
        } catch {
            XCTFail("Unexpected error thrown: \(error)")
        }
    }
    
    func testRegisterUserCallsAPIWithCorrectRequestBodyWithRefId() async throws {
        do {
            // Arrange
            let credentials = NewRegistrationCredentials.mock(
                username: "testUser",
                email: "testUser@example.com",
                password: "password123",
                referenceUserId: "mockRefId"
            )
            let location = UserLocation.mock(
                latitude: 50.087236,
                longitude: 14.4155773,
                altitude: 237.8,
                accuracy: 12.58
            )
            let mockResponse = APIResponse(data: RegistrationResponse.mock())
            networkMock.responseToReturn = mockResponse
            
            // Act
            _ = try await service.registerUser(credentials: credentials, location: location)
            
            // Assert
            guard let capturedBody = networkMock.capturedBody,
                  let bodyDict = try JSONSerialization.jsonObject(with: capturedBody, options: []) as? [String: Any] else {
                XCTFail("Captured body is not valid JSON")
                return
            }
            
            // Check keys in the body
            XCTAssertEqual(bodyDict["nick"] as? String, credentials.username, "The username should match the credentials")
            XCTAssertEqual(bodyDict["email"] as? String, credentials.email, "The email should match the credentials")
            XCTAssertEqual(bodyDict["pswd"] as? String, credentials.password, "The password should match the credentials")
            XCTAssertEqual(bodyDict["refId"] as? String, credentials.referenceUserId, "The reference ID should match the credentials")
            XCTAssertEqual(bodyDict["lat"] as? String, "\(location.latitude)", "The latitude should match the location data")
            XCTAssertEqual(bodyDict["lng"] as? String, "\(location.longitude)", "The longitude should match the location data")
        } catch {
            XCTFail("Unexpected error thrown: \(error)")
        }
    }
    
    func testCompleteRegistrationCallsAPIWithCorrectRequestHeaders() async throws {
        do {
            // Arrange
            storageMock.mockToken = "mockToken"
            let credentials = FullRegistrationCredentials.mock()
            let expectedURL = URL(string: "https://api-test.lifeisskill.cz/v1.0/users")!
            let mockResponse = APIResponse(data: CompleteRegistrationAPIResponse.mock())
            networkMock.responseToReturn = mockResponse
            
            // Act
            _ = try await service.completeRegistration(credentials: credentials)
            
            // Assert
            XCTAssertEqual(networkMock.capturedMethod, .PUT, "HTTP method should be PUT")
            XCTAssertEqual(networkMock.capturedURL, expectedURL, "The URL should match the complete registration endpoint")
        } catch {
            XCTFail("Unexpected error thrown: \(error)")
        }
    }
    
    func testCompleteRegistrationCallsAPIWithCorrectRequestBodyWithGuardianInfo() async throws {
        do {
            // Arrange
            storageMock.mockToken = "mockToken"
            let guardianInfo = GuardianInfo(
                firstName: "GuardianFirstName",
                lastName: "GuardianLastName",
                phoneNumber: "123456789",
                email: "guardian@example.com",
                relationship: "Parent"
            )
            
            let credentials = FullRegistrationCredentials(
                firstName: "John",
                lastName: "Doe",
                phoneNumber: "987654321",
                dateOfBirth: Date(timeIntervalSince1970: 946684800),  // Jan 1, 2000
                gender: .male,
                postalCode: "12345",
                guardianInfo: guardianInfo
            )
            
            let mockResponse = APIResponse(data: CompleteRegistrationAPIResponse.mock())
            networkMock.responseToReturn = mockResponse
            
            // Act
            _ = try await service.completeRegistration(credentials: credentials)
            
            // Assert
            guard let capturedBody = networkMock.capturedBody,
                  let bodyDict = try JSONSerialization.jsonObject(with: capturedBody, options: []) as? [String: Any] else {
                XCTFail("Captured body is not valid JSON")
                return
            }
            
            // Check the basic user info fields
            XCTAssertEqual(bodyDict["name"] as? String, credentials.firstName, "The first name should match the credentials")
            XCTAssertEqual(bodyDict["surname"] as? String, credentials.lastName, "The last name should match the credentials")
            XCTAssertEqual(bodyDict["phone"] as? String, credentials.phoneNumber, "The phone number should match the credentials")
            XCTAssertEqual(bodyDict["birthday"] as? String, Date.Backend.getBirthdayString(from: credentials.dateOfBirth), "The birthday should match the formatted date of birth")
            XCTAssertEqual(bodyDict["sex"] as? String, credentials.gender.rawValue, "The gender should match the credentials")
            XCTAssertEqual(bodyDict["zip"] as? String, credentials.postalCode, "The postal code should match the credentials")
            
            // Check the guardian info fields
            XCTAssertEqual(bodyDict["nameParent"] as? String, guardianInfo.firstName, "The guardian first name should match")
            XCTAssertEqual(bodyDict["surnameParent"] as? String, guardianInfo.lastName, "The guardian last name should match")
            XCTAssertEqual(bodyDict["phoneParent"] as? String, guardianInfo.phoneNumber, "The guardian phone number should match")
            XCTAssertEqual(bodyDict["emailParent"] as? String, guardianInfo.email, "The guardian email should match")
            XCTAssertEqual(bodyDict["relation"] as? String, guardianInfo.relationship, "The guardian relationship should match")
            
        } catch {
            XCTFail("Unexpected error thrown: \(error)")
        }
    }
    
    func testCompleteRegistrationCallsAPIWithCorrectRequestBodyWithoutGuardianInfo() async throws {
        do {
            // Arrange
            storageMock.mockToken = "mockToken"
            let credentials = FullRegistrationCredentials(
                firstName: "John",
                lastName: "Doe",
                phoneNumber: "987654321",
                dateOfBirth: Date(timeIntervalSince1970: 946684800),  // Jan 1, 2000
                gender: .male,
                postalCode: "12345",
                guardianInfo: nil  // No guardian info
            )
            let mockResponse = APIResponse(data: CompleteRegistrationAPIResponse.mock())
            networkMock.responseToReturn = mockResponse
            
            // Act
            _ = try await service.completeRegistration(credentials: credentials)
            
            // Assert
            guard let capturedBody = networkMock.capturedBody,
                  let bodyDict = try JSONSerialization.jsonObject(with: capturedBody, options: []) as? [String: Any] else {
                XCTFail("Captured body is not valid JSON")
                return
            }
            
            // Check only the basic user info fields are present
            XCTAssertEqual(bodyDict["name"] as? String, credentials.firstName, "The first name should match the credentials")
            XCTAssertEqual(bodyDict["surname"] as? String, credentials.lastName, "The last name should match the credentials")
            XCTAssertEqual(bodyDict["phone"] as? String, credentials.phoneNumber, "The phone number should match the credentials")
            XCTAssertEqual(bodyDict["birthday"] as? String, Date.Backend.getBirthdayString(from: credentials.dateOfBirth), "The birthday should match the formatted date of birth")
            XCTAssertEqual(bodyDict["sex"] as? String, credentials.gender.rawValue, "The gender should match the credentials")
            XCTAssertEqual(bodyDict["zip"] as? String, credentials.postalCode, "The postal code should match the credentials")
            
            // Check that no guardian info is present
            XCTAssertNil(bodyDict["nameParent"], "There should be no guardian first name in the request body")
            XCTAssertNil(bodyDict["surnameParent"], "There should be no guardian last name in the request body")
            XCTAssertNil(bodyDict["phoneParent"], "There should be no guardian phone number in the request body")
            XCTAssertNil(bodyDict["emailParent"], "There should be no guardian email in the request body")
            XCTAssertNil(bodyDict["relation"], "There should be no guardian relationship in the request body")
            
        } catch {
            XCTFail("Unexpected error thrown: \(error)")
        }
    }
    
    func testRequestParentEmailActivationLinkCallsAPIWithCorrectRequest() async throws {
        do {
            // Arrange
            storageMock.mockToken = "mockToken"
            let email = "parent@example.com"
            let expectedURL = URL(string: "https://api-test.lifeisskill.cz/v1.0/parentLink/parent@example.com/users")!
            let mockResponse = APIResponse(data: ParentEmailActivationReponse.mock())
            networkMock.responseToReturn = mockResponse
            
            // Act
            _ = try await service.requestParentEmailActivationLink(email: email)
            
            // Assert
            XCTAssertEqual(networkMock.capturedMethod, .PUT, "HTTP method should be PUT")
            XCTAssertEqual(networkMock.capturedURL, expectedURL, "The URL should match the parent email activation endpoint")
            XCTAssertNil(networkMock.capturedBody, "The request body should be nil for a PUT request")
        } catch {
            XCTFail("Unexpected error thrown: \(error)")
        }
    }
}

// MARK: - Testing that each protocol func returns expected data upon successful call

extension RegisterUserAPIServiceTests {
    
    func testCheckUsernameAvailabilityReturnsExpectedData() async throws {
        do {
            // Arrange
            let mockAPIResponse = UsernameAvailabilityResponse.mock(isAvailable: true)
            let mockResponse = APIResponse(data: mockAPIResponse)
            networkMock.responseToReturn = mockResponse
            
            // Act
            let response: APIResponse<UsernameAvailabilityResponse> = try await service.checkUsernameAvailability("mockUsername")
            
            // Assert
            XCTAssertEqual(response.data.isAvailable, mockAPIResponse.isAvailable, "The availability should match the mock data")
        } catch {
            XCTFail("Unexpected error thrown: \(error)")
        }
    }
    
    func testCheckEmailAvailabilityReturnsExpectedData() async throws {
        do {
            // Arrange
            let mockAPIResponse = EmailAvailabilityResponse.mock(isAvailable: true)
            let mockResponse = APIResponse(data: mockAPIResponse)
            networkMock.responseToReturn = mockResponse
            
            // Act
            let response: APIResponse<EmailAvailabilityResponse> = try await service.checkEmailAvailability("mockEmail@example.com")
            
            // Assert
            XCTAssertEqual(response.data.isAvailable, mockAPIResponse.isAvailable, "The availability should match the mock data")
        } catch {
            XCTFail("Unexpected error thrown: \(error)")
        }
    }
    
    func testRegisterUserReturnsExpectedData() async throws {
        do {
            // Arrange
            let mockAPIResponse = RegistrationResponse.mock(message: "mockNewUser")
            let mockResponse = APIResponse(data: mockAPIResponse)
            networkMock.responseToReturn = mockResponse
            
            // Act
            let response: APIResponse<RegistrationResponse> = try await service.registerUser(credentials: NewRegistrationCredentials.mock(), location: UserLocation.mock())
            
            // Assert
            XCTAssertEqual(response.data.message, mockAPIResponse.message, "The registration message should match the mock data")
        } catch {
            XCTFail("Unexpected error thrown: \(error)")
        }
    }
    
    func testCompleteRegistrationReturnsExpectedData() async throws {
        do {
            // Arrange
            let mockAPIResponse = CompleteRegistrationAPIResponse.mock(completionStatus: true)
            let mockResponse = APIResponse(data: mockAPIResponse)
            networkMock.responseToReturn = mockResponse
            
            // Act
            let response: APIResponse<CompleteRegistrationAPIResponse> = try await service.completeRegistration(credentials: FullRegistrationCredentials.mock())
            
            // Assert
            XCTAssertEqual(response.data.completionStatus, mockAPIResponse.completionStatus, "The completion status should match the mock data")
        } catch {
            XCTFail("Unexpected error thrown: \(error)")
        }
    }
    
    func testRequestParentEmailActivationLinkReturnsExpectedData() async throws {
        do {
            // Arrange
            let mockAPIResponse = ParentEmailActivationReponse.mock(status: true)
            let mockResponse = APIResponse(data: mockAPIResponse)
            networkMock.responseToReturn = mockResponse
            
            // Act
            let response: APIResponse<ParentEmailActivationReponse> = try await service.requestParentEmailActivationLink(email: "parent@example.com")
            
            // Assert
            XCTAssertEqual(response.data.status, mockAPIResponse.status, "The activation status should match the mock data")
        } catch {
            XCTFail("Unexpected error thrown: \(error)")
        }
    }
}

// MARK: - Testing that each protocol func propagates errors

extension RegisterUserAPIServiceTests {
    
    func testCheckUsernameAvailabilityPropagatesNetworkError() async throws {
        // Arrange: Simulate a network error
        networkMock.errorToThrow = BaseError(
            context: .network,
            message: "Test network error",
            code: .networking(.unknown),
            logger: loggerMock
        )
        
        // Act & Assert
        do {
            let _: APIResponse<UsernameAvailabilityResponse> = try await service.checkUsernameAvailability("mockUsername")
            XCTFail("Expected an error to be thrown, but none was thrown")
        } catch let error as BaseError {
            XCTAssertEqual(error.message, "Test network error", "The error message should match")
            XCTAssertEqual(error.code, ErrorCodes.networking(.unknown).code, "The error code should match")
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }
    
    func testCheckEmailAvailabilityPropagatesNetworkError() async throws {
        // Arrange: Simulate a network error
        networkMock.errorToThrow = BaseError(
            context: .network,
            message: "Test network error",
            code: .networking(.unknown),
            logger: loggerMock
        )
        
        // Act & Assert
        do {
            let _: APIResponse<EmailAvailabilityResponse> = try await service.checkEmailAvailability("mockEmail@example.com")
            XCTFail("Expected an error to be thrown, but none was thrown")
        } catch let error as BaseError {
            XCTAssertEqual(error.message, "Test network error", "The error message should match")
            XCTAssertEqual(error.code, ErrorCodes.networking(.unknown).code, "The error code should match")
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }
    
    func testRegisterUserPropagatesNetworkError() async throws {
        // Arrange: Simulate a network error
        networkMock.errorToThrow = BaseError(
            context: .network,
            message: "Test network error",
            code: .networking(.unknown),
            logger: loggerMock
        )
        
        // Act & Assert
        do {
            let _: APIResponse<RegistrationResponse> = try await service.registerUser(credentials: NewRegistrationCredentials.mock(), location: UserLocation.mock())
            XCTFail("Expected an error to be thrown, but none was thrown")
        } catch let error as BaseError {
            XCTAssertEqual(error.message, "Test network error", "The error message should match")
            XCTAssertEqual(error.code, ErrorCodes.networking(.unknown).code, "The error code should match")
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }
    
    func testCompleteRegistrationPropagatesNetworkError() async throws {
        // Arrange: Simulate a network error
        networkMock.errorToThrow = BaseError(
            context: .network,
            message: "Test network error",
            code: .networking(.unknown),
            logger: loggerMock
        )
        
        // Act & Assert
        do {
            let _: APIResponse<CompleteRegistrationAPIResponse> = try await service.completeRegistration(credentials: FullRegistrationCredentials.mock())
            XCTFail("Expected an error to be thrown, but none was thrown")
        } catch let error as BaseError {
            XCTAssertEqual(error.message, "Test network error", "The error message should match")
            XCTAssertEqual(error.code, ErrorCodes.networking(.unknown).code, "The error code should match")
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }
    
    func testRequestParentEmailActivationLinkPropagatesNetworkError() async throws {
        // Arrange: Simulate a network error
        networkMock.errorToThrow = BaseError(
            context: .network,
            message: "Test network error",
            code: .networking(.unknown),
            logger: loggerMock
        )
        
        // Act & Assert
        do {
            let _: APIResponse<ParentEmailActivationReponse> = try await service.requestParentEmailActivationLink(email: "parent@example.com")
            XCTFail("Expected an error to be thrown, but none was thrown")
        } catch let error as BaseError {
            XCTAssertEqual(error.message, "Test network error", "The error message should match")
            XCTAssertEqual(error.code, ErrorCodes.networking(.unknown).code, "The error code should match")
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }
}
