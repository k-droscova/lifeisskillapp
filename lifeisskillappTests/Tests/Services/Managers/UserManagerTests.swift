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
    
    
}
