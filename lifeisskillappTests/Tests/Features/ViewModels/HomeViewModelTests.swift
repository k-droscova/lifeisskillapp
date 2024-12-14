//
//  HomeViewModelTests.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 19.10.2024.
//

import XCTest
import Combine
@testable import lifeisskillapp

final class HomeViewModelTests: XCTestCase {
    
    // MARK: - Mocks and Dependencies
    typealias CategorySelectorVM = CategorySelectorViewModelMock
    typealias SettingsBarVM = SettingsBarViewModelMock<LocationStatusBarViewModelMock>
    
    struct Dependencies: HasLoggerServicing & HasLocationManager & HasGameDataManager & HasUserManager & SettingsBarViewModel.Dependencies {
        var gameDataManager: GameDataManaging
        var logger: LoggerServicing
        var locationManager: LocationManaging
        var userManager: UserManaging
        var networkMonitor: NetworkMonitoring
    }
    
    // Mocked dependencies
    var gameDataManagerMock: GameDataManagerMock!
    var loggerMock: LoggingServiceMock!
    var locationManagerMock: LocationManagerMock!
    var userManagerMock: UserManagerMock!
    var networkMonitorMock: NetworkMonitorMock!
    var categorySelectorViewModelMock: CategorySelectorVM!
    var settingsBarViewModelMock: SettingsBarVM!
    var homeFlowDelegateMock: HomeFlowDelegateMock!
    
    // ViewModels to test
    var homeViewModel: HomeViewModel<CategorySelectorVM, SettingsBarVM>!

    var cancellables: Set<AnyCancellable>!
    
    // MARK: - Setup
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        // Initialize mocks
        gameDataManagerMock = GameDataManagerMock()
        loggerMock = LoggingServiceMock()
        locationManagerMock = LocationManagerMock()
        userManagerMock = UserManagerMock()
        networkMonitorMock = NetworkMonitorMock()
        
        // Initialize CategorySelectorViewModel mock
        categorySelectorViewModelMock = CategorySelectorViewModelMock()
        let dependencies = Dependencies(
            gameDataManager: gameDataManagerMock,
            logger: loggerMock,
            locationManager: locationManagerMock,
            userManager: userManagerMock,
            networkMonitor: networkMonitorMock
        )
        
        // Initialize SettingsBarViewModel mock
        settingsBarViewModelMock = SettingsBarViewModelMock(
            dependencies: dependencies,
            delegate: nil
        )
        
        // Initialize HomeFlowDelegate mock
        homeFlowDelegateMock = HomeFlowDelegateMock()
        
        homeViewModel = HomeViewModel(
            dependencies: .init(
                gameDataManager: dependencies.gameDataManager,
                logger: dependencies.logger,
                locationManager: dependencies.locationManager,
                userManager: dependencies.userManager,
                networkMonitor: dependencies.networkMonitor
            ),
            categorySelectorVM: categorySelectorViewModelMock,
            delegate: homeFlowDelegateMock,
            settingsDelegate: nil
        )
        
        cancellables = []
    }
    
    // MARK: - Teardown
    
    override func tearDownWithError() throws {
        gameDataManagerMock = nil
        loggerMock = nil
        locationManagerMock = nil
        userManagerMock = nil
        networkMonitorMock = nil
        categorySelectorViewModelMock = nil
        settingsBarViewModelMock = nil
        homeFlowDelegateMock = nil
        homeViewModel = nil
        cancellables = nil
        
        try super.tearDownWithError()
    }
    
    func testOnAppear_LoadsUserDataAndUpdatesUsername() async {
        // Arrange
        let mockUser = LoggedInUser.mock(nick: "TestUser")
        userManagerMock.loggedInUser = mockUser
        userManagerMock.loadLoggedInUserDataCalled = false
        
        // Expectation for the `username` property change
        let usernameExpectation = XCTestExpectation(description: "Username updated")
        
        // Subscribe to changes on `username`
        let cancellable = homeViewModel.$username
            .dropFirst()  // Drop the initial value
            .sink { newUsername in
                if newUsername == "TestUser" {
                    usernameExpectation.fulfill()
                }
            }
        
        // Act
        homeViewModel.onAppear()  // Await the call directly
        
        // Wait for the expectation to fulfill or timeout
        await fulfillment(of: [usernameExpectation], timeout: 3.0)
        
        // Assert
        XCTAssertTrue(userManagerMock.loadLoggedInUserDataCalled, "Expected to call loadLoggedInUserData on UserManager.")
        XCTAssertEqual(homeViewModel.username, "TestUser", "Expected username to be updated from loggedInUser.")
        XCTAssertFalse(homeViewModel.isLoading, "Expected isLoading to be set to false after loading.")
        
        // Clean up the cancellable
        cancellable.cancel()
    }
    
    func testLoadWithNFC_InitializesNfcViewModelAndStartsScanning() {
        // Act
        homeViewModel.loadWithNFC()

        // Assert
        XCTAssertTrue(homeFlowDelegateMock.featureUnavailableCalled, "startScanning should be called on NfcViewModel which should call feature unavailable since NFC is not available in test environment.")
    }
    
    func testLoadWithQRCode_InitializesQRViewModelAndCallsDelegate() {
        // Act
        homeViewModel.loadWithQRCode()

        // Assert
        XCTAssertTrue(homeFlowDelegateMock.loadFromQRCalled, "Expected loadFromQR to be called on delegate.")
        XCTAssertNotNil(homeFlowDelegateMock.capturedQRViewModel, "Expected QRViewModel to be passed to the delegate.")
    }
    
    func testLoadFromCamera_InitializesOcrViewModelAndCallsDelegate() {
        // Act
        homeViewModel.loadFromCamera()

        // Assert
        XCTAssertTrue(homeFlowDelegateMock.loadFromCameraCalled, "Expected loadFromCamera to be called on delegate.")
        XCTAssertNotNil(homeFlowDelegateMock.capturedOcrViewModel, "Expected OcrViewModel to be passed to the delegate.")
    }
    
    func testDismissCamera_CallsDelegateMethod() {
        // Act
        homeViewModel.dismissCamera()

        // Assert
        XCTAssertTrue(homeFlowDelegateMock.dismissCameraCalled, "Expected dismissCamera to be called on delegate.")
    }
    
    func testShowOnboarding_CallsDelegateMethod() {
        // Act
        homeViewModel.showOnboarding()

        // Assert
        XCTAssertTrue(homeFlowDelegateMock.showOnboardingCalled, "Expected showOnboarding to be called on delegate.")
    }
    
    func testIsVirtualAvailable_UpdatesWhenGameDataManagerPublisherEmitsValue() {
        XCTAssertEqual(homeViewModel.isVirtualAvailable, false, "Initially, isVirtualAvailable should be false.")

        let expectation = XCTestExpectation(description: "isVirtualAvailable should be updated when the publisher emits a value")

        homeViewModel.$isVirtualAvailable
            .dropFirst(2) // game data manager mock emits 2 initial false values (intital for current subject and initial for isVirtualAvailable), so the mocked value is 3rd
            .sink { isAvailable in
                // Assert
                XCTAssertTrue(isAvailable, "Expected isVirtualAvailable to be true after the publisher emits true")
                expectation.fulfill()
            }
            .store(in: &cancellables)

        // Act
        gameDataManagerMock.isVirtualAvailable = true

        // Wait for expectations
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testLoadVirtual_CallsProcessVirtualOnGameDataManager() async {
        // Arrange
        let mockLocation = UserLocation.mock(latitude: 50.0, longitude: 14.0)
        locationManagerMock.location = mockLocation
        
        let expectation = XCTestExpectation(description: "onAppear completes")

        // Act
        Task {
            homeViewModel.loadVirtual()
            expectation.fulfill()
        }

        // Wait for the Task to complete
        await fulfillment(of: [expectation], timeout: 2.0)
        
        // Assert: Ensure the processVirtual method is called with the correct location
        XCTAssertTrue(gameDataManagerMock.processVirtualCalled, "Expected processVirtual to be called on GameDataManager.")
        XCTAssertEqual(gameDataManagerMock.virtualLocationArgument?.latitude, mockLocation.latitude, "Expected the latitude of the location passed to processVirtual to match.")
        XCTAssertEqual(gameDataManagerMock.virtualLocationArgument?.longitude, mockLocation.longitude, "Expected the longitude of the location passed to processVirtual to match.")
    }
}
