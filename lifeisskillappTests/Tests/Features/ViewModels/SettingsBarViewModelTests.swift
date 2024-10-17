//
//  SettingsBarViewModelTests.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 17.10.2024.
//

import XCTest
@testable import lifeisskillapp

final class SettingsBarViewModelTests: XCTestCase {
    
    private var viewModel: SettingsBarViewModel<LocationStatusBarViewModelMock>!
    private var mockUserManager: UserManagerMock!
    private var mockNetworkMonitor: NetworkMonitorMock!
    private var mockLocationManager: LocationManagerMock!
    private var mockLogger: LoggingServiceMock!
    private var mockDelegate: SettingsBarFlowDelegateMock!
    
    struct MockDependencies: HasLoggers & HasLocationManager & HasUserManager & HasNetworkMonitor {
        let logger: LoggerServicing
        let locationManager: LocationManaging
        let userManager: UserManaging
        let networkMonitor: NetworkMonitoring
    }
    
    // MARK: - Setup
    
    override func setUp() {
        super.setUp()
        
        // Initialize the mocks
        mockUserManager = UserManagerMock()
        mockNetworkMonitor = NetworkMonitorMock()
        mockLocationManager = LocationManagerMock()
        mockLogger = LoggingServiceMock()
        mockDelegate = SettingsBarFlowDelegateMock()
        mockDelegate.userManager = mockUserManager
        
        let dependencies = MockDependencies(
            logger: mockLogger,
            locationManager: mockLocationManager,
            userManager: mockUserManager,
            networkMonitor: mockNetworkMonitor
        )
        
        // Initialize the view model with mock dependencies
        viewModel = SettingsBarViewModel<LocationStatusBarViewModelMock>(dependencies: dependencies, delegate: mockDelegate)
    }
    
    override func tearDown() {
        viewModel = nil
        mockUserManager = nil
        mockNetworkMonitor = nil
        mockLocationManager = nil
        mockLogger = nil
        mockDelegate = nil
        super.tearDown()
    }
    
    // MARK: - Test Cases
    
    func testLogoutPressed_WhileOnline() {
        // Arrange
        mockNetworkMonitor.mockOnlineStatus = true
        mockUserManager.isLoggedIn = true
        
        // Act
        viewModel.logoutPressed()
        
        // Assert
        XCTAssertTrue(mockUserManager.logoutCalled, "User should be logged out when network is online")
        XCTAssertFalse(mockDelegate.logoutPressedWhileOfflineCalled, "Delegate's logoutPressedWhileOffline should not be called when online")
    }
    
    func testLogoutPressed_WhileOffline_UserPressesLogout() {
        // Arrange
        mockNetworkMonitor.mockOnlineStatus = false
        
        // Act
        viewModel.logoutPressed()
        
        // Assert
        XCTAssertTrue(mockDelegate.logoutPressedWhileOfflineCalled, "Delegate's logoutPressedWhileOffline should be called when network is offline")
        XCTAssertTrue(mockUserManager.logoutCalled, "User should be logged out when network is offline, assuming he presses logout in pop up")
    }
    
    func testLogoutPressed_WhileOffline_UserCancelsLogout() {
        // Arrange
        mockNetworkMonitor.mockOnlineStatus = false
        mockDelegate.shouldLogout = false
        
        // Act
        viewModel.logoutPressed()
        
        // Assert
        XCTAssertTrue(mockDelegate.logoutPressedWhileOfflineCalled, "Delegate's logoutPressedWhileOffline should be called when network is offline")
        XCTAssertFalse(mockUserManager.logoutCalled, "User should not be logged out when network is offline, assuming he cancels logout in pop up")
    }
    
    func testProfilePressed_CallsDelegate() {
        // Arrange

        // Act
        viewModel.profilePressed()
        
        // Assert
        XCTAssertTrue(mockDelegate.profilePressedCalled, "Delegate's profilePressed should be called")
    }
    
    func testOnboardingPressed_CallsDelegate() {
        // Arrange
        // (Nothing to arrange in this case)

        // Act
        viewModel.onboardingPressed()
        
        // Assert
        XCTAssertTrue(mockDelegate.onboardingPressedCalled, "Delegate's onboardingPressed should be called")
    }
    
    func testHideProfileNavigationOption_HidesProfileOption() {
        // Arrange
        XCTAssertTrue(viewModel.showProfileMenuOption, "Profile menu option should be visible by default")
        
        // Act
        viewModel.hideProfileNavigationOption()
        
        // Assert
        XCTAssertFalse(viewModel.showProfileMenuOption, "Profile menu option should be hidden after hideProfileNavigationOption is called")
    }
    
    func testIsLoggedIn_ReturnsCorrectValue() {
        // Arrange
        mockUserManager.isLoggedIn = true
        
        // Act & Assert
        XCTAssertTrue(viewModel.isLoggedIn, "isLoggedIn should return true when the user is logged in")
        
        // Arrange
        mockUserManager.isLoggedIn = false
        
        // Act & Assert
        XCTAssertFalse(viewModel.isLoggedIn, "isLoggedIn should return false when the user is not logged in")
    }
}
