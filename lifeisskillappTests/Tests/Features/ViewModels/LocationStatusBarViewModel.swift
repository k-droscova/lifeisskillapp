//
//  LocationStatusBarViewModel.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 17.10.2024.
//

import XCTest
import Combine
@testable import lifeisskillapp

final class LocationStatusBarViewModelTests: XCTestCase {
    
    private var viewModel: LocationStatusBarViewModel!
    private var mockLocationManager: LocationManagerMock!
    private var mockNetworkMonitor: NetworkMonitorMock!
    private var mockLogger: LoggingServiceMock!
    private var cancellables: Set<AnyCancellable> = []
    
    struct MockDependencies: HasLoggers & HasLocationManager & HasNetworkMonitor {
        let logger: LoggerServicing
        let locationManager: LocationManaging
        let networkMonitor: NetworkMonitoring
    }
    
    // MARK: - Setup
    
    override func setUp() {
        super.setUp()
        mockLocationManager = LocationManagerMock()
        mockNetworkMonitor = NetworkMonitorMock()
        mockLogger = LoggingServiceMock()
        
        let dependencies = MockDependencies(
            logger: mockLogger,
            locationManager: mockLocationManager,
            networkMonitor: mockNetworkMonitor
        )
        
        viewModel = LocationStatusBarViewModel(dependencies: dependencies)
    }
    
    override func tearDown() {
        viewModel = nil
        mockLocationManager = nil
        mockNetworkMonitor = nil
        mockLogger = nil
        cancellables.removeAll()
        super.tearDown()
    }
    
    // MARK: - Initial Values Test
    
    func testInitialValues() {
        XCTAssertEqual(viewModel.isOnline, false)
        XCTAssertEqual(viewModel.isGpsOk, false)
        XCTAssertNil(viewModel.userLocation)
        XCTAssertEqual(viewModel.appVersion, "DEBUG")
    }
    
    // MARK: - Location Tests
    
    func testLocationChangeUpdatesUserLocation() {
        let mockLocation = UserLocation.mock()
        
        let locationExpectation = expectation(description: "Location should update")
        
        // Observe the changes to userLocation
        viewModel.$userLocation
            .sink { newLocation in
                if newLocation == mockLocation {
                    locationExpectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        // Simulate location change
        mockLocationManager.simulateLocationUpdate(mockLocation)
        
        // Wait for expectation
        wait(for: [locationExpectation], timeout: 1.0)
    }
    
    func testMultipleLocationChangesUpdateUserLocation() {
        let mockLocation1 = UserLocation.mock()
        let mockLocation2 = UserLocation.mock(latitude: 52.124, longitude: 17.292)
        
        let locationExpectation1 = expectation(description: "First location should update")
        let locationExpectation2 = expectation(description: "Second location should update")
        
        var locationUpdateCount = 0
        
        viewModel.$userLocation
            .sink { newLocation in
                if newLocation == mockLocation1 {
                    locationUpdateCount += 1
                    locationExpectation1.fulfill()
                }
                if newLocation == mockLocation2 && locationUpdateCount == 1 {
                    locationExpectation2.fulfill()
                }
            }
            .store(in: &cancellables)
        
        // Simulate first location change
        mockLocationManager.simulateLocationUpdate(mockLocation1)
        wait(for: [locationExpectation1], timeout: 1.0)
        
        // Simulate second location change
        mockLocationManager.simulateLocationUpdate(mockLocation2)
        wait(for: [locationExpectation2], timeout: 1.0)
    }
    
    // MARK: - GPS Status Tests
    
    func testGpsStatusChangeUpdatesViewModel() {
        let expectedGpsStatus = true
        let gpsExpectation = expectation(description: "GPS status should update")
        
        viewModel.$isGpsOk
            .receive(on: DispatchQueue.main)
            .sink { isGpsOk in
                if isGpsOk == expectedGpsStatus {
                    gpsExpectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        // Simulate GPS status change
        mockLocationManager.simulateGPSStatusChange(expectedGpsStatus)
        
        // Wait for expectation
        wait(for: [gpsExpectation], timeout: 1.0)
    }
    
    func testMultipleGpsStatusChangesUpdateViewModel() {
        let firstGpsStatus = true
        let secondGpsStatus = false
        
        let gpsExpectation1 = expectation(description: "First GPS status should update")
        let gpsExpectation2 = expectation(description: "Second GPS status should update")
        
        var gpsUpdateCount = 0
        
        viewModel.$isGpsOk
            .sink { isGpsOk in
                if isGpsOk == firstGpsStatus {
                    gpsUpdateCount += 1
                    gpsExpectation1.fulfill()
                }
                if isGpsOk == secondGpsStatus && gpsUpdateCount == 1 {
                    gpsExpectation2.fulfill()
                }
            }
            .store(in: &cancellables)
        
        // Simulate first GPS status change
        mockLocationManager.simulateGPSStatusChange(firstGpsStatus)
        wait(for: [gpsExpectation1], timeout: 1.0)
        
        // Simulate second GPS status change
        mockLocationManager.simulateGPSStatusChange(secondGpsStatus)
        wait(for: [gpsExpectation2], timeout: 1.0)
    }
    
    // MARK: - Network Status Tests
    // TODO: needs fixing, for some reason the publisher is triggered several times
    
    /*
    func testNetworkStatusChangeUpdatesViewModel() {
        let expectedNetworkStatus = true
        let networkExpectation = expectation(description: "Network status should update")
        
        viewModel.$isOnline
            .dropFirst(2) // Drop initial values (once from @Published default, once from NetworkMonitor's default)
            .prefix(1) // Only care about the first meaningful change
            .receive(on: DispatchQueue.main)
            .sink { isOnline in
                if isOnline == expectedNetworkStatus {
                    networkExpectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        // Simulate network status change
        mockNetworkMonitor.simulateNetworkChange(isOnline: expectedNetworkStatus)
        
        // Wait for expectation
        wait(for: [networkExpectation], timeout: 1.0)
    }
    
    func testMultipleNetworkStatusChangesUpdateViewModel() {
        let firstNetworkStatus = false
        let secondNetworkStatus = true
        
        let networkExpectation1 = expectation(description: "First network status should update")
        let networkExpectation2 = expectation(description: "Second network status should update")
        
        var networkUpdateCount = 0
        
        viewModel.$isOnline
            .receive(on: DispatchQueue.main)
            .dropFirst(2) // Drop initial values (once from @Published default, once from NetworkMonitor's default)
            .prefix(1) // Only care about the first meaningful change
            .sink { isOnline in
                networkUpdateCount += 1
                if networkUpdateCount == 1 && isOnline == firstNetworkStatus {
                    networkExpectation1.fulfill() // Fulfill first expectation
                } else if networkUpdateCount == 2 && isOnline == secondNetworkStatus {
                    networkExpectation2.fulfill() // Fulfill second expectation
                }
            }
            .store(in: &cancellables)
        
        // Simulate first network status change
        mockNetworkMonitor.simulateNetworkChange(isOnline: firstNetworkStatus)
        wait(for: [networkExpectation1], timeout: 2.0)
        
        // Simulate second network status change
        mockNetworkMonitor.simulateNetworkChange(isOnline: secondNetworkStatus)
        wait(for: [networkExpectation2], timeout: 2.0)
    }
     */
}
