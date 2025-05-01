//
//  UserManagerTests.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 18.10.2024.
//

import XCTest
import Combine
@testable import lifeisskillapp

final class UserManagerTests: XCTestCase {
    
    // MARK: - Mocks and Dependencies
    
    private struct Dependencies: UserManager.Dependencies {
        var registerAppAPI: RegisterAppAPIServicing
        var registerUserAPI: RegisterUserAPIServicing
        var loginAPI: LoginAPIServicing
        var forgotPasswordAPI: ForgotPasswordAPIServicing
        var logger: LoggerServicing
        var userDefaultsStorage: UserDefaultsStoraging
        var storage: PersistentUserDataStoraging
        var networkMonitor: NetworkMonitoring
        var keychainStorage: KeychainStoraging
        var gameDataManager: GameDataManaging
        var locationManager: LocationManaging
    }
    
    // Mocks for each dependency
    var registerAppAPIMock: RegisterAppAPIServiceMock!
    var registerUserAPIMock: RegisterUserAPIServiceMock!
    var loginAPIMock: LoginAPIServiceMock!
    var forgotPasswordAPIMock: ForgotPasswordAPIServiceMock!
    var loggerMock: LoggerServicing!
    var userDefaultsStorageMock: UserDefaultsStorageMock!
    var persistentStorageMock: PersistentUserDataStorageMock!
    var networkMonitorMock: NetworkMonitorMock!
    var keychainStorageMock: KeychainStorageMock!
    var gameDataManagerMock: GameDataManagerMock!
    var locationManagerMock: LocationManagerMock!
    var userManager: UserManager!
    var delegateMock: UserManagerFlowDelegateMock!
    
    var cancellables: Set<AnyCancellable>!

    // MARK: - Setup and Teardown

    override func setUpWithError() throws {
        try super.setUpWithError()
        
        // Initialize mocks
        loggerMock = LoggingServiceMock()
        registerAppAPIMock = RegisterAppAPIServiceMock()
        registerUserAPIMock = RegisterUserAPIServiceMock()
        loginAPIMock = LoginAPIServiceMock()
        forgotPasswordAPIMock = ForgotPasswordAPIServiceMock()
        userDefaultsStorageMock = UserDefaultsStorageMock()
        persistentStorageMock = PersistentUserDataStorageMock()
        networkMonitorMock = NetworkMonitorMock()
        keychainStorageMock = KeychainStorageMock()
        gameDataManagerMock = GameDataManagerMock()
        locationManagerMock = LocationManagerMock()
        delegateMock = UserManagerFlowDelegateMock()
        
        // Create dependency container
        let dependencies = Dependencies(
            registerAppAPI: registerAppAPIMock,
            registerUserAPI: registerUserAPIMock,
            loginAPI: loginAPIMock,
            forgotPasswordAPI: forgotPasswordAPIMock,
            logger: loggerMock,
            userDefaultsStorage: userDefaultsStorageMock,
            storage: persistentStorageMock,
            networkMonitor: networkMonitorMock,
            keychainStorage: keychainStorageMock,
            gameDataManager: gameDataManagerMock,
            locationManager: locationManagerMock
        )
        
        // Initialize UserManager with dependencies
        userManager = UserManager(dependencies: dependencies)
        userManager.delegate = delegateMock
        cancellables = []
    }
    
    override func tearDownWithError() throws {
        loggerMock = nil
        registerAppAPIMock = nil
        registerUserAPIMock = nil
        loginAPIMock = nil
        forgotPasswordAPIMock = nil
        userDefaultsStorageMock = nil
        persistentStorageMock = nil
        networkMonitorMock = nil
        keychainStorageMock = nil
        gameDataManagerMock = nil
        locationManagerMock = nil
        userManager = nil
        delegateMock = nil
        cancellables = nil
        try super.tearDownWithError()
    }
    
    func testHasAppId_FalseAfterInit() {
        userDefaultsStorageMock.appId = nil
        XCTAssertFalse(userManager.hasAppId, "UserManager should not have an appId after initialization.")
    }
    
    func testHasAppId_TrueWhenUserDefaultsHasAppId() {
        userDefaultsStorageMock.appId = "mock-app-id"
        XCTAssertTrue(userManager.hasAppId, "UserManager should have an appId after initialization.")
    }
    
    func testInitializeAppId_Success() async throws {
        // Arrange
        let mockAppId = "mock-app-id"
        userDefaultsStorageMock.appId = nil
        registerAppAPIMock.responseToReturn = APIResponse.init(data: RegisterAppAPIResponse.mock(appId: mockAppId))
        
        // Act
        try await userManager.initializeAppId()
        
        // Assert
        XCTAssertEqual(userDefaultsStorageMock.appId, mockAppId, "AppId should be saved in userDefaultsStorage after initialization.")
    }
    
    func testInitializeAppId_AppIdAlreadyExists() async throws {
        // Arrange
        let mockAppId = "existing-app-id"
        let mockAppIdResponse = "mock-app-id"

        userDefaultsStorageMock.appId = mockAppId // Simulate appId already existing
        registerAppAPIMock.responseToReturn = APIResponse.init(data: RegisterAppAPIResponse.mock(appId: mockAppIdResponse))
        // Act
        try await userManager.initializeAppId()
        
        // Assert
        XCTAssertEqual(userDefaultsStorageMock.appId, mockAppId, "AppId should remain unchanged if already exists.")
    }
    
    func testInitializeAppId_ThrowsError_WhenAPIThrowsError() async throws {
        // Arrange
        userDefaultsStorageMock.appId = nil // Simulate no existing appId
        let apiError = NSError(domain: "RegisterAppAPIError", code: 500, userInfo: nil) // Mocked API error
        registerAppAPIMock.errorToThrow = apiError // Simulate the API throwing an error
        
        // Act & Assert
        do {
            try await userManager.initializeAppId()
            XCTFail("Expected to throw an error, but no error was thrown.")
        } catch let error as BaseError {
            // Assert that a BaseError is thrown with the expected context and message
            XCTAssertEqual(error.context, .system, "Expected BaseError to have 'system' context.")
            XCTAssertEqual(error.message, "Unable to obtain App Id", "Expected error message to match.")
        } catch {
            XCTFail("Expected a BaseError, but received a different error: \(error).")
        }
    }
    
    func testPerformOnlineLogin_NoExistingUser_Success() async throws {
        // Arrange
        let credentials = LoginCredentials(username: "testUser", password: "testPassword")
        let mockUser = LoggedInUser.mock(userId: "newUserId")
        let loginResponse = LoginAPIResponse.mock(user: mockUser)
        
        loginAPIMock.loginResponseToReturn = APIResponse(data: loginResponse)
        persistentStorageMock.mockLoginDetails = nil // No existing user in storage
        networkMonitorMock.mockOnlineStatus = true
        locationManagerMock.location = UserLocation.mock()
        
        // Act
        try await userManager.login(credentials: credentials)
        
        // Assert
        XCTAssertEqual(userDefaultsStorageMock.token, mockUser.token, "User token should be saved to userDefaultsStorage.")
        XCTAssertTrue(keychainStorageMock.saveCalled, "Keychain save should be called with new credentials.")
        XCTAssertTrue(persistentStorageMock.loginCalled, "User details should be saved to storage.")
        XCTAssertFalse(persistentStorageMock.clearUserRelatedDataCalled, "clearUserRelatedData should not be called when there's no existing user.")
        XCTAssertFalse(keychainStorageMock.deleteCalled, "Keychain delete should not be called when there's no existing user.")
        XCTAssertTrue(gameDataManagerMock.performOnlineLoginCalled, "performOnlineLogin should be called on gameDataManager.")
        XCTAssertEqual(userManager.loggedInUser?.userId, mockUser.userId, "loggedInUser should be set to the user returned by the API.")
        XCTAssertTrue(userDefaultsStorageMock.isLoggedIn ?? false, "isLoggedIn should be set to true in userDefaultsStorage.")
    }
    
    func testPerformOnlineLogin_ThrowsError_WhenLocationIsNil() async throws {
        // Arrange
        let credentials = LoginCredentials(username: "testUser", password: "testPassword")
        locationManagerMock.location = nil
        networkMonitorMock.mockOnlineStatus = true

        // Act & Assert
        do {
            try await userManager.login(credentials: credentials)
            XCTFail("Expected an error to be thrown when location is nil, but no error was thrown.")
        } catch {
            XCTAssertTrue(error is BaseError, "Expected BaseError to be thrown.")
            let baseError = error as? BaseError
            XCTAssertEqual(baseError?.errorCode, ErrorCodes.login(.missingLocation).code, "Expected error code to be .missingLocation.")
        }

        // Additional assertions to ensure nothing else was called
        XCTAssertFalse(persistentStorageMock.loginCalled, "User details should not be saved to storage when location is nil.")
        XCTAssertFalse(gameDataManagerMock.performOnlineLoginCalled, "performOnlineLogin should not be called on gameDataManager.")
        XCTAssertFalse(userDefaultsStorageMock.isLoggedIn ?? false, "isLoggedIn should not be set to true when login fails.")
    }
    
    func testPerformOnlineLogin_ThrowsError_WhenLoginAPIFails() async throws {
        // Arrange
        let credentials = LoginCredentials(username: "testUser", password: "testPassword")
        let apiError = BaseError(
            context: .api,
            message: "Login failed",
            code: ErrorCodes.default, // Adjust this code to match your actual error codes
            logger: loggerMock
        )
        let initialToken = "initialToken"
        userDefaultsStorageMock.mockToken = initialToken
        
        // Simulate that loginAPI throws an error
        loginAPIMock.errorToThrow = apiError
        networkMonitorMock.mockOnlineStatus = true
        locationManagerMock.location = UserLocation.mock()

        // Act & Assert
        do {
            try await userManager.login(credentials: credentials)
            XCTFail("Expected an error to be thrown by loginAPI, but no error was thrown.")
        } catch {
            XCTAssertTrue(error is BaseError, "Expected BaseError to be thrown.")
            let baseError = error as? BaseError
            XCTAssertEqual(baseError?.message, "Login failed", "Expected error message to match the one thrown by loginAPI.")
        }

        // Assert: Ensure that no data was saved when the login fails
        XCTAssertFalse(persistentStorageMock.loginCalled, "User details should not be saved to storage when loginAPI fails.")
        XCTAssertFalse(keychainStorageMock.saveCalled, "Keychain save should not be called when loginAPI fails.")
        XCTAssertFalse(gameDataManagerMock.performOnlineLoginCalled, "performOnlineLogin should not be called on gameDataManager when loginAPI fails.")
        XCTAssertFalse(userDefaultsStorageMock.isLoggedIn ?? false, "isLoggedIn should not be set to true when loginAPI fails.")
        XCTAssertEqual(userDefaultsStorageMock.token, initialToken, "User token should remain unchanged when loginAPI fails.")
    }
    
    func testPerformOnlineLogin_FailureInKeychain_LoggedInUserIsNil() async throws {
        // Arrange
        let credentials = LoginCredentials(username: "testUser", password: "testPassword")
        let mockUser = LoggedInUser.mock(userId: "newUserId")
        let loginResponse = LoginAPIResponse.mock(user: mockUser)
        
        // Simulate login API success
        loginAPIMock.loginResponseToReturn = APIResponse(data: loginResponse)
        persistentStorageMock.mockLoginDetails = nil // No existing user in storage
        networkMonitorMock.mockOnlineStatus = true
        userDefaultsStorageMock.isLoggedIn = false
        locationManagerMock.location = UserLocation.mock()
        
        // Simulate keychain or storage failure
        keychainStorageMock.errorToThrow = BaseError(
            context: .system,
            message: "Failed to save credentials to keychain",
            logger: loggerMock
        )
        
        // Act & Assert
        do {
            try await userManager.login(credentials: credentials)
            XCTFail("Expected an error to be thrown due to keychain failure, but no error was thrown.")
        } catch {
            XCTAssertTrue(error is BaseError, "Expected BaseError to be thrown.")
            let baseError = error as? BaseError
            XCTAssertEqual(baseError?.message, "Failed to save credentials to keychain", "Expected keychain failure message.")
        }
        
        // Assert: loggedInUser should be nil
        XCTAssertNil(userManager.loggedInUser, "loggedInUser should be nil if keychain or storage fails.")
        
        // Assert: isLoggedIn in userDefaultsStorage should be false
        XCTAssertFalse(userDefaultsStorageMock.isLoggedIn ?? true, "isLoggedIn should be false when keychain or storage fails.")
    }

    func testPerformOnlineLogin_FailureInPersistentStorage_LoggedInUserIsNil() async throws {
        // Arrange
        let credentials = LoginCredentials(username: "testUser", password: "testPassword")
        let mockUser = LoggedInUser.mock(userId: "newUserId")
        let loginResponse = LoginAPIResponse.mock(user: mockUser)
        
        // Simulate login API success
        loginAPIMock.loginResponseToReturn = APIResponse(data: loginResponse)
        persistentStorageMock.mockLoginDetails = nil // No existing user in storage
        networkMonitorMock.mockOnlineStatus = true
        locationManagerMock.location = UserLocation.mock()
        userDefaultsStorageMock.isLoggedIn = false
        
        // Simulate persistent storage failure
        persistentStorageMock.errorToThrow = BaseError(
            context: .system,
            message: "Failed to save user details to storage",
            logger: loggerMock
        )
        
        // Act & Assert
        do {
            try await userManager.login(credentials: credentials)
            XCTFail("Expected an error to be thrown due to storage failure, but no error was thrown.")
        } catch {
            XCTAssertTrue(error is BaseError, "Expected BaseError to be thrown.")
            let baseError = error as? BaseError
            XCTAssertEqual(baseError?.message, "Failed to save user details to storage", "Expected storage failure message.")
        }
        
        // Assert: loggedInUser should be nil
        XCTAssertNil(userManager.loggedInUser, "loggedInUser should be nil if keychain or storage fails.")
        
        // Assert: isLoggedIn in userDefaultsStorage should be false
        XCTAssertFalse(userDefaultsStorageMock.isLoggedIn ?? true, "isLoggedIn should be false when keychain or storage fails.")
    }
    
    func testPerformOnlineLogin_DifferentUser_ClearsUserRelatedData() async throws {
        // Arrange
        let credentials = LoginCredentials(username: "testUser", password: "testPassword")
        let mockUser = LoggedInUser.mock(userId: "newUserId") // New user
        let existingUser = LoggedInUser.mock(userId: "existingUserId") // Existing user in storage
        let loginResponse = LoginAPIResponse.mock(user: mockUser)
        
        // Simulate login API success
        loginAPIMock.loginResponseToReturn = APIResponse(data: loginResponse)
        persistentStorageMock.mockLoginDetails = LoginUserData(user: existingUser)
        networkMonitorMock.mockOnlineStatus = true
        locationManagerMock.location = UserLocation.mock()

        // Act
        try await userManager.login(credentials: credentials)
        
        // Assert
        XCTAssertTrue(persistentStorageMock.clearUserRelatedDataCalled, "clearUserRelatedData should be called when the logged in user is different from the stored user.")
        XCTAssertTrue(persistentStorageMock.loginCalled, "New user details should be saved to storage.")
        XCTAssertTrue(keychainStorageMock.deleteCalled, "Keychain delete should be called when there is a different existing user.")
        XCTAssertTrue(keychainStorageMock.saveCalled, "Keychain save should be called with new credentials.")
        XCTAssertTrue(gameDataManagerMock.performOnlineLoginCalled, "performOnlineLogin should be called on gameDataManager.")
        XCTAssertEqual(userManager.loggedInUser?.userId, mockUser.userId, "loggedInUser should be set to the new user returned by the API.")
        XCTAssertTrue(userDefaultsStorageMock.isLoggedIn ?? false, "isLoggedIn should be set to true in userDefaultsStorage.")
    }
    
    func testPerformOnlineLogin_SameUser_NoClearUserRelatedDataOrPerformOnlineLogin() async throws {
        // Arrange
        let credentials = LoginCredentials(username: "testUser", password: "testPassword")
        let mockUser = LoggedInUser.mock(userId: "existingUserId") // Same user as in storage
        let loginResponse = LoginAPIResponse.mock(user: mockUser)
        
        // Simulate login API success
        loginAPIMock.loginResponseToReturn = APIResponse(data: loginResponse)
        persistentStorageMock.mockLoginDetails = LoginUserData(user: mockUser)
        networkMonitorMock.mockOnlineStatus = true
        locationManagerMock.location = UserLocation.mock()

        // Act
        try await userManager.login(credentials: credentials)
        
        // Assert
        XCTAssertFalse(persistentStorageMock.clearUserRelatedDataCalled, "clearUserRelatedData should not be called when the logged in user is the same as the stored user.")
        XCTAssertTrue(persistentStorageMock.loginCalled, "User details should still be saved to storage even if the user is the same.")
        XCTAssertTrue(keychainStorageMock.deleteCalled, "Keychain delete should be called to delete old credentials.")
        XCTAssertTrue(keychainStorageMock.saveCalled, "Keychain save should be called with new credentials.")
        XCTAssertFalse(gameDataManagerMock.performOnlineLoginCalled, "performOnlineLogin should not be called on gameDataManager when the logged in user is the same.")
        XCTAssertEqual(userManager.loggedInUser?.userId, mockUser.userId, "loggedInUser should still be set to the same user returned by the API.")
        XCTAssertTrue(userDefaultsStorageMock.isLoggedIn ?? false, "isLoggedIn should be set to true in userDefaultsStorage.")
    }
    
    func testPerformOfflineLogin_Success() async throws {
        // Arrange
        let credentials = LoginCredentials(username: "testUser", password: "testPassword")
        let mockUser = LoggedInUser.mock(userId: "existingUserId")
        
        // Simulate that keychain has matching credentials
        keychainStorageMock.mockUsername = credentials.username
        keychainStorageMock.mockPassword = credentials.password

        // Simulate that storage has user details and saved login data
        persistentStorageMock.mockLoginDetails = LoginUserData(user: mockUser)
        
        // Set network to offline
        networkMonitorMock.mockOnlineStatus = false

        // Act
        try await userManager.login(credentials: credentials)

        // Assert
        XCTAssertTrue(persistentStorageMock.markUserAsLoggedInCalled, "markUserAsLoggedIn should be called on the storage when offline login succeeds.")
        XCTAssertTrue(gameDataManagerMock.performOfflineLoginCalled, "performOfflineLogin should be called on gameDataManager when offline login succeeds.")
        XCTAssertEqual(userManager.loggedInUser?.userId, mockUser.userId, "loggedInUser should be set to the user from storage.")
        XCTAssertTrue(userDefaultsStorageMock.isLoggedIn ?? false, "isLoggedIn should be set to true in userDefaultsStorage.")
    }
    
    func testPerformOfflineLogin_FailsWithInvalidCredentials() async throws {
        // Arrange
        let credentials = LoginCredentials(username: "testUser", password: "wrongPassword")
        
        // Simulate that keychain has different credentials
        keychainStorageMock.mockUsername = "testUser"
        keychainStorageMock.mockPassword = "correctPassword"
        
        // Set network to offline
        networkMonitorMock.mockOnlineStatus = false
        userDefaultsStorageMock.isLoggedIn = false

        // Act & Assert
        do {
            try await userManager.login(credentials: credentials)
            XCTFail("Expected an error to be thrown for invalid credentials during offline login.")
        } catch {
            XCTAssertTrue(error is BaseError, "Expected BaseError to be thrown for invalid credentials.")
            let baseError = error as? BaseError
            XCTAssertEqual(baseError?.code, ErrorCodes.login(.offlineInvalidCredentials).code, "Expected credentials mismatch error message.")
        }

        // Additional assertions to ensure nothing else was called
        XCTAssertFalse(persistentStorageMock.markUserAsLoggedInCalled, "markUserAsLoggedIn should not be called when credentials are invalid.")
        XCTAssertFalse(gameDataManagerMock.performOfflineLoginCalled, "performOfflineLogin should not be called when credentials are invalid.")
        XCTAssertFalse(userDefaultsStorageMock.isLoggedIn ?? false, "isLoggedIn should not be set to true when offline login fails.")
    }
    
    func testPerformOfflineLogin_FailsWithMissingStoredData() async throws {
        // Arrange
        let credentials = LoginCredentials(username: "testUser", password: "testPassword")
        
        // Simulate that keychain has matching credentials
        keychainStorageMock.mockUsername = credentials.username
        keychainStorageMock.mockPassword = credentials.password
        
        // Simulate that storage does not have loggedInUserDetails or savedLoginDetails
        persistentStorageMock.mockLoggedInUserDetails = nil
        persistentStorageMock.mockLoginDetails = nil
        
        // Set network to offline
        networkMonitorMock.mockOnlineStatus = false

        // Act & Assert
        do {
            try await userManager.login(credentials: credentials)
            XCTFail("Expected an error to be thrown for missing stored user data during offline login.")
        } catch {
            XCTAssertTrue(error is BaseError, "Expected BaseError to be thrown for missing stored data.")
            let baseError = error as? BaseError
            XCTAssertEqual(baseError?.message, "Offline login failed: unable to retrieve realm data.", "Expected missing stored data error message.")
        }

        // Additional assertions to ensure nothing else was called
        XCTAssertFalse(persistentStorageMock.markUserAsLoggedInCalled, "markUserAsLoggedIn should not be called when stored user data is missing.")
        XCTAssertFalse(gameDataManagerMock.performOfflineLoginCalled, "performOfflineLogin should not be called when stored user data is missing.")
        XCTAssertFalse(userDefaultsStorageMock.isLoggedIn ?? false, "isLoggedIn should not be set to true when offline login fails.")
    }
    
    func testCheckUsernameAvailability_Success() async throws {
        // Arrange
        let username = "testUser"
        let mockResponse = UsernameAvailabilityResponse.mock(isAvailable: true)
        registerUserAPIMock.checkUsernameAvailabilityResponseToReturn = APIResponse(data: mockResponse)
        
        // Act
        let isAvailable = try await userManager.checkUsernameAvailability(username)
        
        // Assert
        XCTAssertTrue(isAvailable, "Expected the username to be available as per the mock response.")
    }

    func testCheckUsernameAvailability_PropagatesError() async throws {
        // Arrange
        let username = "testUser"
        let apiError = BaseError(
            context: .api,
            message: "Username check failed",
            code: ErrorCodes.default, // Adjust to match your actual error codes
            logger: loggerMock
        )
        
        // Simulate that the API call throws an error
        registerUserAPIMock.errorToThrow = apiError

        // Act & Assert
        do {
            _ = try await userManager.checkUsernameAvailability(username)
            XCTFail("Expected an error to be thrown, but no error was thrown.")
        } catch {
            XCTAssertTrue(error is BaseError, "Expected BaseError to be thrown.")
            let baseError = error as? BaseError
            XCTAssertEqual(baseError?.message, "Username check failed", "Expected error message to match the one thrown by the API.")
        }
    }
    
    func testCheckEmailAvailability_Success() async throws {
        // Arrange
        let email = "test@example.com"
        let mockResponse = EmailAvailabilityResponse.mock(isAvailable: true)
        registerUserAPIMock.checkEmailAvailabilityResponseToReturn = APIResponse(data: mockResponse)
        
        // Act
        let isAvailable = try await userManager.checkEmailAvailability(email)
        
        // Assert
        XCTAssertTrue(isAvailable, "Expected the email to be available as per the mock response.")
    }

    func testCheckEmailAvailability_PropagatesError() async throws {
        // Arrange
        let email = "test@example.com"
        let apiError = BaseError(
            context: .api,
            message: "Email check failed",
            code: ErrorCodes.default, // Adjust to match your actual error codes
            logger: loggerMock
        )
        
        // Simulate that the API call throws an error
        registerUserAPIMock.errorToThrow = apiError

        // Act & Assert
        do {
            _ = try await userManager.checkEmailAvailability(email)
            XCTFail("Expected an error to be thrown, but no error was thrown.")
        } catch {
            XCTAssertTrue(error is BaseError, "Expected BaseError to be thrown.")
            let baseError = error as? BaseError
            XCTAssertEqual(baseError?.message, "Email check failed", "Expected error message to match the one thrown by the API.")
        }
    }
    
    func testRegisterUser_Success() async throws {
        // Arrange
        let credentials = NewRegistrationCredentials(username: "testUser", email: "test@example.com", password: "password123")
        let mockLocation = UserLocation.mock(latitude: 50.0, longitude: 14.0)
        locationManagerMock.location = mockLocation // Simulate that locationManager returns a location
        
        // Act
        try await userManager.registerUser(credentials: credentials)
        // Assert
        XCTAssertEqual(registerUserAPIMock.receivedCredentials?.username, credentials.username, "The username passed to registerUser should match.")
        XCTAssertEqual(registerUserAPIMock.receivedCredentials?.email, credentials.email, "The email passed to registerUser should match.")
        XCTAssertEqual(registerUserAPIMock.receivedLocation?.latitude, mockLocation.latitude, "The latitude of the location passed should match.")
        XCTAssertEqual(registerUserAPIMock.receivedLocation?.longitude, mockLocation.longitude, "The longitude of the location passed should match.")
    }
    
    func testRegisterUser_PropagatesError() async throws {
        // Arrange
        let credentials = NewRegistrationCredentials(username: "testUser", email: "test@example.com", password: "password123")
        let mockLocation = UserLocation.mock()
        locationManagerMock.location = mockLocation // Simulate that locationManager returns a location
        
        let apiError = BaseError(
            context: .api,
            message: "Registration failed",
            code: ErrorCodes.default, // Adjust to match your actual error codes
            logger: loggerMock
        )
        
        // Simulate that the API throws an error
        registerUserAPIMock.errorToThrow = apiError
        
        // Act & Assert
        do {
            try await userManager.registerUser(credentials: credentials)
            XCTFail("Expected an error to be thrown, but no error was thrown.")
        } catch {
            XCTAssertTrue(error is BaseError, "Expected BaseError to be thrown.")
            let baseError = error as? BaseError
            XCTAssertEqual(baseError?.message, "Registration failed", "Expected error message to match the one thrown by the API.")
        }
        
        // Ensure that the API call was still made
        XCTAssertTrue(registerUserAPIMock.registerUserCalled, "registerUser should be called on the registerUserAPI.")
        XCTAssertEqual(registerUserAPIMock.receivedCredentials?.username, credentials.username, "The username passed to registerUser should match.")
        XCTAssertEqual(registerUserAPIMock.receivedLocation?.latitude, mockLocation.latitude, "The latitude of the location passed should match.")
    }
    
    func testCompleteUserRegistration_ThrowsError_WhenCredentialsMissingInKeychain() async throws {
        // Arrange
        let fullRegistrationCredentials = FullRegistrationCredentials.mock()
        keychainStorageMock.mockUsername = nil // Simulate missing username in Keychain
        keychainStorageMock.mockPassword = nil
        locationManagerMock.location = UserLocation.mock()
        networkMonitorMock.mockOnlineStatus = true

        // Act & Assert
        do {
            _ = try await userManager.completeUserRegistration(credentials: fullRegistrationCredentials)
            XCTFail("Expected an error to be thrown due to missing credentials in Keychain, but no error was thrown.")
        } catch {
            XCTAssertTrue(error is BaseError, "Expected BaseError to be thrown.")
            let baseError = error as? BaseError
            XCTAssertEqual(baseError?.message, "Unable to complete registration for user, no logged in user detected", "Expected error message to indicate missing credentials.")
        }

        // Assert that nothing else is called
        XCTAssertFalse(registerUserAPIMock.completeRegistrationCalled, "completeRegistration should not be called when credentials are missing.")
        XCTAssertFalse(gameDataManagerMock.reloadAfterRegistrationCalled, "reloadAfterRegistration should not be called when credentials are missing.")
    }

    func testCompleteUserRegistration_PropagatesAPIError() async throws {
        // Arrange
        let fullRegistrationCredentials = FullRegistrationCredentials.mock()
        keychainStorageMock.mockUsername = "testUser"
        keychainStorageMock.mockPassword = "testPassword"
        locationManagerMock.location = UserLocation.mock()
        networkMonitorMock.mockOnlineStatus = true
        
        let apiError = BaseError(context: .api, message: "API Error", logger: loggerMock)
        registerUserAPIMock.errorToThrow = apiError
        
        // Act & Assert
        do {
            _ = try await userManager.completeUserRegistration(credentials: fullRegistrationCredentials)
            XCTFail("Expected an error to be thrown due to API error, but no error was thrown.")
        } catch {
            XCTAssertTrue(error is BaseError, "Expected BaseError to be thrown.")
            let baseError = error as? BaseError
            XCTAssertEqual(baseError?.message, apiError.message, "Expected error message to propagate.")
        }

        // Assert that nothing else is called after API error
        XCTAssertFalse(gameDataManagerMock.reloadAfterRegistrationCalled, "reloadAfterRegistration should not be called when API error occurs.")
        XCTAssertFalse(persistentStorageMock.loginCalled, "login should not be called when API error occurs.")
    }

    func testCompleteUserRegistration_ThrowsError_WhenCompletionStatusIsFalse() async throws {
        // Arrange
        let fullRegistrationCredentials = FullRegistrationCredentials.mock()
        keychainStorageMock.mockUsername = "testUser"
        keychainStorageMock.mockPassword = "testPassword"
        locationManagerMock.location = UserLocation.mock()
        networkMonitorMock.mockOnlineStatus = true
        
        // Simulate API response with completionStatus as false
        let responseWithFailedCompletion = CompleteRegistrationAPIResponse(completionStatus: false, needParentActivation: false)
        registerUserAPIMock.completeRegistrationResponseToReturn = APIResponse(data: responseWithFailedCompletion)
        
        // Act & Assert
        do {
            _ = try await userManager.completeUserRegistration(credentials: fullRegistrationCredentials)
            XCTFail("Expected an error to be thrown due to incomplete registration, but no error was thrown.")
        } catch {
            XCTAssertTrue(error is BaseError, "Expected BaseError to be thrown.")
            let baseError = error as? BaseError
            XCTAssertEqual(baseError?.message, "Unable to register", "Expected error message to indicate incomplete registration.")
        }

        // Assert that nothing else is called after failed completion status
        XCTAssertFalse(gameDataManagerMock.reloadAfterRegistrationCalled, "reloadAfterRegistration should not be called when registration completion fails.")
        XCTAssertFalse(persistentStorageMock.loginCalled, "login should not be called when registration completion fails.")
    }

    func testCompleteUserRegistration_CallsReloadAfterRegistrationAndPerformsLogin() async throws {
        // Arrange
        let fullRegistrationCredentials = FullRegistrationCredentials.mock()
        let mockUsername = "testUser"
        let mockPassword = "testPassword"
        keychainStorageMock.mockUsername = mockUsername
        keychainStorageMock.mockPassword = mockPassword
        locationManagerMock.location = UserLocation.mock()
        networkMonitorMock.mockOnlineStatus = true

        // Simulate successful API response with completionStatus as true
        let responseWithSuccess = CompleteRegistrationAPIResponse(completionStatus: true, needParentActivation: true)
        registerUserAPIMock.completeRegistrationResponseToReturn = APIResponse(data: responseWithSuccess)
        let loginReponse = LoginAPIResponse.mock()
        loginAPIMock.loginResponseToReturn = APIResponse(data: loginReponse)
        
        // Act
        let response = try await userManager.completeUserRegistration(credentials: fullRegistrationCredentials)
        
        // Assert: Ensure reloadAfterRegistration is called
        XCTAssertTrue(gameDataManagerMock.reloadAfterRegistrationCalled, "reloadAfterRegistration should be called after successful registration.")
        
        // Assert: Ensure login is called with correct credentials
        XCTAssertTrue(keychainStorageMock.username == mockUsername, "login should be performed with correct username from Keychain.")
        XCTAssertTrue(keychainStorageMock.password == mockPassword, "login should be performed with correct password from Keychain.")
        XCTAssertTrue(persistentStorageMock.loginCalled, "User details should be saved to storage.")
        XCTAssertEqual(response.completionStatus, responseWithSuccess.completionStatus, "Completion status should match API response.")
        XCTAssertEqual(response.needParentActivation, responseWithSuccess.needParentActivation, "Need parent activation should match API response.")
    }
    
    func testRequestParentEmailActivationLink_ThrowsError_WhenCredentialsMissingInKeychain() async throws {
        // Arrange
        let email = "parent@example.com"
        keychainStorageMock.mockUsername = nil // Simulate missing username in Keychain
        keychainStorageMock.mockPassword = nil
        locationManagerMock.location = UserLocation.mock()
        networkMonitorMock.mockOnlineStatus = true

        // Act & Assert
        do {
            _ = try await userManager.requestParentEmailActivationLink(email: email)
            XCTFail("Expected an error to be thrown due to missing credentials in Keychain, but no error was thrown.")
        } catch {
            XCTAssertTrue(error is BaseError, "Expected BaseError to be thrown.")
            let baseError = error as? BaseError
            XCTAssertEqual(baseError?.message, "Unable to request activation email, no logged in user detected", "Expected error message to indicate missing credentials.")
        }

        // Assert that nothing else is called
        XCTAssertFalse(registerUserAPIMock.requestParentEmailActivationLinkCalled, "API should not be called when credentials are missing.")
    }
    
    func testRequestParentEmailActivationLink_PropagatesAPIError() async throws {
        // Arrange
        let email = "parent@example.com"
        keychainStorageMock.mockUsername = "testUser"
        keychainStorageMock.mockPassword = "testPassword"
        let apiError = BaseError(context: .api, message: "API Error", logger: loggerMock)
        registerUserAPIMock.errorToThrow = apiError
        networkMonitorMock.mockOnlineStatus = true

        // Act & Assert
        do {
            _ = try await userManager.requestParentEmailActivationLink(email: email)
            XCTFail("Expected an error to be thrown due to API error, but no error was thrown.")
        } catch {
            XCTAssertTrue(error is BaseError, "Expected BaseError to be thrown.")
            let baseError = error as? BaseError
            XCTAssertEqual(baseError?.message, apiError.message, "Expected the API error to propagate.")
        }

        // Assert that API was called
        XCTAssertTrue(registerUserAPIMock.requestParentEmailActivationLinkCalled, "API should still be called when propagating API error.")
    }

    func testRequestParentEmailActivationLink_CallsLogin_WhenParentEmailIsChanged() async throws {
        // Arrange
        let email = "newparent@example.com"
        let credentials = LoginCredentials(username: "testUser", password: "testPassword")
        let mockUser = LoggedInUser.mock(emailParent: "oldParent@example.com") // Simulate existing logged in user with different parent email
        persistentStorageMock.mockLoginDetails = LoginUserData(user: mockUser)
        keychainStorageMock.mockUsername = credentials.username
        keychainStorageMock.mockPassword = credentials.password
        networkMonitorMock.mockOnlineStatus = false

        // First, perform an offline login
        try await userManager.login(credentials: credentials)
        
        // Simulate online mode now
        networkMonitorMock.mockOnlineStatus = true
        locationManagerMock.location = UserLocation.mock()


        // Simulate successful API response
        let apiResponse = ParentEmailActivationReponse(status: true)
        registerUserAPIMock.requestParentEmailActivationLinkResponseToReturn = APIResponse(data: apiResponse)

        // Act
        let result = try await userManager.requestParentEmailActivationLink(email: email)
        // Assert that login is called to update the user's parent email
        XCTAssertTrue(persistentStorageMock.loginCalled, "User details should be saved to storage.")
        XCTAssertTrue(result, "API response status should be returned.")
    }
    
    func testRequestParentEmailActivationLink_DoesNotCallLogin_WhenParentEmailIsNotChanged() async throws {
        // Arrange
        let email = "parent@example.com"
        let credentials = LoginCredentials(username: "testUser", password: "testPassword")
        let mockUser = LoggedInUser.mock(emailParent: email)
        persistentStorageMock.mockLoginDetails = LoginUserData(user: mockUser)
        keychainStorageMock.mockUsername = credentials.username
        keychainStorageMock.mockPassword = credentials.password
        networkMonitorMock.mockOnlineStatus = false

        // First, perform an offline login
        try await userManager.login(credentials: credentials)

        // Simulate online mode now
        networkMonitorMock.mockOnlineStatus = true
        locationManagerMock.location = UserLocation.mock()

        // Simulate successful API response
        let apiResponse = ParentEmailActivationReponse(status: true)
        registerUserAPIMock.requestParentEmailActivationLinkResponseToReturn = APIResponse(data: apiResponse)

        // Act
        let result = try await userManager.requestParentEmailActivationLink(email: email)

        // Assert that login is not called as parent email is unchanged
        XCTAssertFalse(persistentStorageMock.loginCalled, "login should not be called when parent email is not changed.")
        XCTAssertTrue(result, "API response status should be returned.")
    }
    
    // Test for loadLoggedInUserData()
    func testLoadLoggedInUserData_LoadsDataWhenLoggedInUserIsNil() async throws {
        // Arrange
        let mockUser = LoggedInUser.mock()
        persistentStorageMock.mockLoggedInUserDetails = LoginUserData(user: mockUser)
        
        // Act
        await userManager.loadLoggedInUserData()
        
        // Assert
        XCTAssertEqual(userManager.loggedInUser?.userId, mockUser.userId, "loggedInUser should be set from storage when it's nil.")
    }

    func testLogout_CallsLogoutOperationsAndDelegate() async throws {
        // Arrange
        let expectation = XCTestExpectation(description: "Logout task should complete.")
        
        // Act
        Task {
            userManager.logout()
            expectation.fulfill()
        }
        
        // Wait for the Task to complete
        await fulfillment(of: [expectation], timeout: 2)

        // Assert
        XCTAssertTrue(persistentStorageMock.onLogoutCalled, "onLogout should be called in storage.")
        XCTAssertFalse(userDefaultsStorageMock.isLoggedIn ?? true, "isLoggedIn should be set to false in userDefaultsStorage.")
        XCTAssertTrue(delegateMock.onLogoutCalled, "Delegate onLogout should be called.")
    }

    func testOfflineLogout_CallsClearScannedPointDataAndDelegate() async throws {
        // Arrange
        let expectation = XCTestExpectation(description: "OfflineLogout task should complete.")
        
        // Act
        Task {
            userManager.offlineLogout()
            expectation.fulfill()
        }
        
        // Wait for the Task to complete
        await fulfillment(of: [expectation], timeout: 2)
        
        // Assert
        XCTAssertTrue(persistentStorageMock.clearScannedPointDataCalled, "clearScannedPointData should be called in storage.")
        XCTAssertTrue(persistentStorageMock.onLogoutCalled, "onLogout should be called in storage.")
        XCTAssertFalse(userDefaultsStorageMock.isLoggedIn ?? true, "isLoggedIn should be set to false in userDefaultsStorage.")
        XCTAssertTrue(delegateMock.onLogoutCalled, "Delegate onLogout should be called.")
    }

    func testForceLogout_CallsClearScannedPointDataAndForceLogoutDelegate() async throws {
        // Arrange
        let expectation = XCTestExpectation(description: "ForceLogout task should complete.")
        
        // Act
        Task {
            userManager.forceLogout()
            expectation.fulfill()
        }
        
        // Wait for the Task to complete
        await fulfillment(of: [expectation], timeout: 2)
        
        // Assert
        XCTAssertTrue(persistentStorageMock.clearScannedPointDataCalled, "clearScannedPointData should be called in storage.")
        XCTAssertTrue(persistentStorageMock.onLogoutCalled, "onLogout should be called in storage.")
        XCTAssertFalse(userDefaultsStorageMock.isLoggedIn ?? true, "isLoggedIn should be set to false in userDefaultsStorage.")
        XCTAssertTrue(delegateMock.onForceLogoutCalled, "Delegate onForceLogout should be called.")
    }

    // Test for requestPinForPasswordRenewal()
    func testRequestPinForPasswordRenewal_Success() async throws {
        // Arrange
        let username = "testUser"
        let mockPinData = ForgotPasswordData.mock()
        forgotPasswordAPIMock.fetchPinResponseToReturn = APIResponse(data: mockPinData)
        
        // Act
        let result = try await userManager.requestPinForPasswordRenewal(username: username)
        
        // Assert
        XCTAssertEqual(result.pin, mockPinData.pin, "The pin data returned should match the mock response.")
    }

    func testRequestPinForPasswordRenewal_PropagatesError() async throws {
        // Arrange
        let username = "testUser"
        let apiError = BaseError(context: .api, message: "API Error", logger: loggerMock)
        forgotPasswordAPIMock.errorToThrow = apiError
        
        // Act & Assert
        do {
            _ = try await userManager.requestPinForPasswordRenewal(username: username)
            XCTFail("Expected an error to be thrown, but no error was thrown.")
        } catch {
            XCTAssertTrue(error is BaseError, "Expected BaseError to be thrown.")
            let baseError = error as? BaseError
            XCTAssertEqual(baseError?.message, apiError.message, "Expected error message to propagate.")
        }
    }

    func testValidateNewPassword_Success() async throws {
        // Arrange
        let credentials = ForgotPasswordCredentials(email: "test@example.com", newPassword: "password123", pin: "1234")
        forgotPasswordAPIMock.setNewPasswordResponseToReturn = APIResponse(data: ForgotPasswordConfirmation.mock())
        
        // Act
        let result = try await userManager.validateNewPassword(credentials: credentials)
        
        // Assert
        XCTAssertTrue(result, "validateNewPassword should return true on success.")
    }

    func testValidateNewPassword_PropagatesError() async throws {
        // Arrange
        let credentials = ForgotPasswordCredentials(email: "test@example.com", newPassword: "password123", pin: "1234")
        let apiError = BaseError(context: .api, message: "Password reset failed", logger: loggerMock)
        forgotPasswordAPIMock.errorToThrow = apiError
        
        // Act & Assert
        do {
            _ = try await userManager.validateNewPassword(credentials: credentials)
            XCTFail("Expected an error to be thrown, but no error was thrown.")
        } catch {
            XCTAssertTrue(error is BaseError, "Expected BaseError to be thrown.")
            let baseError = error as? BaseError
            XCTAssertEqual(baseError?.message, apiError.message, "Expected error message to propagate.")
        }
    }

    func testSignature_ReturnsNilWhenTokenIsNil() async throws {
        // Arrange
        userDefaultsStorageMock.mockToken = nil
        
        // Act
        let signature = await userManager.signature()
        
        // Assert
        XCTAssertNil(signature, "Signature should return nil if token is nil.")
    }

    func testSignature_Success() async throws {
        // Arrange
        let token = "mockToken"
        let mockSignature = "mockSignature"
        userDefaultsStorageMock.mockToken = token
        loginAPIMock.signatureResponseToReturn = APIResponse(data: SignatureAPIResponse.mock(signature: mockSignature))
        
        // Act
        let signature = await userManager.signature()
        
        // Assert
        XCTAssertEqual(signature, mockSignature, "Signature should match the mock API response.")
    }

    func testSignature_PropagatesError() async throws {
        // Arrange
        let token = "mockToken"
        userDefaultsStorageMock.mockToken = token
        let apiError = BaseError(context: .api, message: "Signature fetch failed", logger: loggerMock)
        loginAPIMock.errorToThrow = apiError
        
        // Act
        let signature = await userManager.signature()
        
        // Assert
        XCTAssertNil(signature, "Signature should return nil when an error is thrown.")
    }
}
