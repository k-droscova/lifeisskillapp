//
//  LoginViewModelTests.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 18.10.2024.
//

import XCTest
@testable import lifeisskillapp

final class LoginViewModelTests: XCTestCase {
    
    private var viewModel: LoginViewModel<SettingsBarViewModelMock<LocationStatusBarViewModelMock>>!
    private var mockUserManager: UserManagerMock!
    private var mockDelegate: LoginFlowDelegateMock!
    private var mockLogger: LoggingServiceMock!
    private var mockNetworkMonitor: NetworkMonitorMock!
    private var mockLocationManager: LocationManagerMock!
    private var dependencies: MockDependencies!

    struct MockDependencies: LoginViewModel.Dependencies {
        var userManager: UserManaging
        var logger: LoggerServicing
        var locationManager: LocationManaging
        var networkMonitor: NetworkMonitoring
    }
    
    override func setUp() {
        super.setUp()
        
        // Initialize the mocks
        mockUserManager = UserManagerMock()
        mockDelegate = LoginFlowDelegateMock()
        mockLogger = LoggingServiceMock()
        mockNetworkMonitor = NetworkMonitorMock()
        mockLocationManager = LocationManagerMock()
        
        dependencies = MockDependencies(
            userManager: mockUserManager,
            logger: mockLogger,
            locationManager: mockLocationManager,
            networkMonitor: mockNetworkMonitor
        )
    }
    
    override func tearDown() {
        viewModel = nil
        mockUserManager = nil
        mockDelegate = nil
        mockLogger = nil
        mockNetworkMonitor = nil
        mockLocationManager = nil
        dependencies = nil
        super.tearDown()
    }
    
    // MARK: - Test Login Button Enabling

    func testLoginButtonIsDisabledWhenUsernameOrPasswordIsEmpty() {
        // Arrange
        viewModel = LoginViewModel<SettingsBarViewModelMock<LocationStatusBarViewModelMock>>(
            dependencies: dependencies,
            delegate: mockDelegate,
            settingsDelegate: SettingsBarFlowDelegateMock()
        )
        viewModel.username = "John"
        viewModel.password = ""
        
        // Act & Assert
        XCTAssertFalse(viewModel.isLoginEnabled, "Login button should be disabled when password is empty")
        
        viewModel.username = ""
        viewModel.password = "password"
        
        XCTAssertFalse(viewModel.isLoginEnabled, "Login button should be disabled when username is empty")
    }
    
    func testLoginButtonIsEnabledWhenBothUsernameAndPasswordAreFilled() {
        // Arrange
        viewModel = LoginViewModel<SettingsBarViewModelMock<LocationStatusBarViewModelMock>>(
            dependencies: dependencies,
            delegate: mockDelegate,
            settingsDelegate: SettingsBarFlowDelegateMock()
        )
        viewModel.username = "John"
        viewModel.password = "password"
        
        // Act & Assert
        XCTAssertTrue(viewModel.isLoginEnabled, "Login button should be enabled when both username and password are filled")
    }
    
    // MARK: - Test Login Success

    func testLogin_WhenLoginIsSuccessful_CallsLoginSuccessfulDelegate() async {
        // Arrange
        mockUserManager.loggedInUser = LoggedInUser.mock(activationStatus: .fullyActivated)
        viewModel = LoginViewModel<SettingsBarViewModelMock<LocationStatusBarViewModelMock>>(
            dependencies: dependencies,
            delegate: mockDelegate,
            settingsDelegate: SettingsBarFlowDelegateMock()
        )
        
        let expectation = expectation(description: "login should complete")
        
        // Act
        Task {
            viewModel.login()
            expectation.fulfill()
        }
        
        await fulfillment(of: [expectation], timeout: 5)

        // Assert
        XCTAssertTrue(mockUserManager.loginCalled, "UserManager login should be called")
        XCTAssertTrue(mockDelegate.loginSuccessfulCalled, "loginSuccessful should be called on delegate")
    }
    
    // TODO: more login tests
}
