//
//  PointsViewModelTests.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 19.10.2024.
//

import XCTest
import Combine
@testable import lifeisskillapp

final class PointsViewModelTests: XCTestCase {
    
    // MARK: - Mocks and Dependencies
    typealias CategorySelectorVM = CategorySelectorViewModelMock
    typealias SettingsBarVM = SettingsBarViewModelMock<LocationStatusBarViewModelMock>
    
    struct Dependencies: HasLoggerServicing & HasLocationManager & HasGameDataManager & HasUserManager & HasUserCategoryManager & HasUserPointManager & HasGenericPointManager & SettingsBarViewModel.Dependencies {
        var logger: LoggerServicing
        var locationManager: LocationManaging
        var gameDataManager: GameDataManaging
        var userManager: UserManaging
        var userCategoryManager: any UserCategoryManaging
        var userPointManager: any UserPointManaging
        var genericPointManager: any GenericPointManaging
        var networkMonitor: NetworkMonitoring
    }
    
    // Mocked dependencies
    var loggerMock: LoggingServiceMock!
    var locationManagerMock: LocationManagerMock!
    var gameDataManagerMock: GameDataManagerMock!
    var userManagerMock: UserManagerMock!
    var userCategoryManagerMock: UserCategoryManagerMock!
    var userPointManagerMock: UserPointManagerMock!
    var genericPointManagerMock: GenericPointManagerMock!
    var networkMonitorMock: NetworkMonitorMock!
    var categorySelectorViewModelMock: CategorySelectorVM!
    var settingsBarViewModelMock: SettingsBarVM!
    var pointsFlowDelegateMock: PointsFlowDelegateMock!
    
    // ViewModel to test
    var pointsViewModel: PointsViewModel<CategorySelectorVM, SettingsBarVM>!
    
    var cancellables: Set<AnyCancellable>!
    
    // MARK: - Setup
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        // Initialize mocks
        loggerMock = LoggingServiceMock()
        locationManagerMock = LocationManagerMock()
        gameDataManagerMock = GameDataManagerMock()
        userManagerMock = UserManagerMock()
        userCategoryManagerMock = UserCategoryManagerMock()
        userPointManagerMock = UserPointManagerMock()
        genericPointManagerMock = GenericPointManagerMock()
        networkMonitorMock = NetworkMonitorMock()
        
        // Initialize CategorySelectorViewModel mock
        categorySelectorViewModelMock = CategorySelectorViewModelMock()
        
        let dependencies = Dependencies(
            logger: loggerMock,
            locationManager: locationManagerMock,
            gameDataManager: gameDataManagerMock,
            userManager: userManagerMock,
            userCategoryManager: userCategoryManagerMock,
            userPointManager: userPointManagerMock,
            genericPointManager: genericPointManagerMock,
            networkMonitor: networkMonitorMock
        )
        
        // Initialize SettingsBarViewModel mock
        settingsBarViewModelMock = SettingsBarViewModelMock(
            dependencies: dependencies,
            delegate: nil
        )
        
        // Initialize PointsFlowDelegate mock
        pointsFlowDelegateMock = PointsFlowDelegateMock()
        
        // Initialize PointsViewModel
        pointsViewModel = PointsViewModel(
            dependencies: dependencies,
            categorySelectorVM: categorySelectorViewModelMock,
            delegate: pointsFlowDelegateMock,
            mapDelegate: nil,
            settingsDelegate: nil
        )
        
        cancellables = []
    }
    
    // MARK: - Teardown
    
    override func tearDownWithError() throws {
        loggerMock = nil
        locationManagerMock = nil
        gameDataManagerMock = nil
        userManagerMock = nil
        userCategoryManagerMock = nil
        userPointManagerMock = nil
        genericPointManagerMock = nil
        networkMonitorMock = nil
        categorySelectorViewModelMock = nil
        settingsBarViewModelMock = nil
        pointsFlowDelegateMock = nil
        pointsViewModel = nil
        cancellables = nil
        
        try super.tearDownWithError()
    }
    
    func testOnAppear_LoadsUserDataAndUpdatesUsername() async {
        // Arrange
        let mockUser = LoggedInUser.mock(nick: "TestUser")
        userManagerMock.loggedInUser = mockUser
        userManagerMock.loadLoggedInUserDataCalled = false
        
        // Expectations for `isLoading` property changes
        let isLoadingExpectation = XCTestExpectation(description: "isLoading set to false")
        
        // Subscribe to changes on `isLoading`
        let isLoadingCancellable = pointsViewModel.$isLoading
            .dropFirst()  // Drop the initial value
            .sink { isLoading in
                if !isLoading {
                    isLoadingExpectation.fulfill()
                }
            }
        
        // Act
        pointsViewModel.onAppear()
        
        // Wait for the expectations to fulfill or timeout
        await fulfillment(of: [isLoadingExpectation], timeout: 3.0)
        
        // Assert
        XCTAssertEqual(pointsViewModel.username, "TestUser", "Expected username to be updated from loggedInUser.")
        XCTAssertFalse(pointsViewModel.isLoading, "Expected isLoading to be set to false after loading.")
        
        // Clean up the cancellables
        isLoadingCancellable.cancel()
    }
    
    func testOnAppear_UpdatesUsernameAndLoadsPoints() async {
        // Arrange
        let mockUser = LoggedInUser.mock(nick: "TestUser")
        userManagerMock.loggedInUser = mockUser
        userManagerMock.loadLoggedInUserDataCalled = false
        
        // Mock the selected category in the userCategoryManager
        let mockCategory = UserCategory.mock(id: "1", name: "Category1")
        userCategoryManagerMock.selectedCategory = mockCategory
        
        // Mock the points in the userPointManager
        let mockPoints = [
            UserPoint.mock(id: "1", pointValue: 10, pointCategory: ["1"]),
            UserPoint.mock(id: "2", pointValue: 20, pointCategory: ["1"]),
            UserPoint.mock(id: "3", pointValue: 25, pointCategory: ["2"])
        ]
        userPointManagerMock.points = mockPoints
        
        let isLoadingExpectation = XCTestExpectation(description: "isLoading set to false")
        
        // Subscribe to changes on `isLoading`
        let isLoadingCancellable = pointsViewModel.$isLoading
            .dropFirst()  // Drop the initial value
            .sink { isLoading in
                if !isLoading {
                    isLoadingExpectation.fulfill()
                }
            }

        // Act
        pointsViewModel.onAppear()
        
        // Wait for the expectations to fulfill or timeout
        await fulfillment(of: [isLoadingExpectation], timeout: 2.0)
        
        // Assert
        XCTAssertEqual(pointsViewModel.username, mockUser.nick, "Expected username to be updated from UserManager.")
        XCTAssertEqual(pointsViewModel.totalPoints, 30, "Expected totalPoints to be the sum of mock points.")
        XCTAssertEqual(pointsViewModel.categoryPoints.count, 2, "Expected categoryPoints to be updated with mock points.")
        XCTAssertEqual(pointsViewModel.categoryPoints.map { $0.value }, [10, 20], "Expected point values to match the mock data.")
        XCTAssertFalse(pointsViewModel.isLoading, "Expected isLoading to be set to false after loading.")
        
        // Clean up the cancellables
        isLoadingCancellable.cancel()
    }
    
    func testCategoryChange_UpdatesPointsAndTotalPoints() async {
        // Arrange
        let mockCategory1 = UserCategory.mock(id: "1", name: "Category1")
        let mockCategory2 = UserCategory.mock(id: "2", name: "Category2")
        
        // Mock initial points for category 1
        let mockPointsForCategory1 = [
            UserPoint.mock(id: "1", pointValue: 10, pointCategory: [mockCategory1.id]),
            UserPoint.mock(id: "2", pointValue: 20, pointCategory: [mockCategory1.id])
        ]
        
        // Mock points for category 2
        let mockPointsForCategory2 = [
            UserPoint.mock(id: "3", pointValue: 25, pointCategory: [mockCategory2.id]),
            UserPoint.mock(id: "4", pointValue: 30, pointCategory: [mockCategory2.id])
        ]
        
        // Set initial points in the userPointManager
        userPointManagerMock.points = mockPointsForCategory1

        // Expectations for `categoryPoints` and `totalPoints` property changes after category change
        let categoryPointsExpectation = XCTestExpectation(description: "Category points updated for new category")
        let totalPointsExpectation = XCTestExpectation(description: "Total points updated for new category")
        
        // Subscribe to changes on `categoryPoints`
        let categoryPointsCancellable = pointsViewModel.$categoryPoints
            .dropFirst()  // Drop the initial value
            .sink { categoryPoints in
                if categoryPoints.count == 2 {
                    categoryPointsExpectation.fulfill()
                }
            }
        
        // Subscribe to changes on `totalPoints`
        let totalPointsCancellable = pointsViewModel.$totalPoints
            .dropFirst()  // Drop the initial value
            .sink { totalPoints in
                if totalPoints == 55 {
                    totalPointsExpectation.fulfill()
                }
            }
        
        // Act: Simulate change in selectedCategory from Category 1 to Category 2
        userPointManagerMock.points = mockPointsForCategory2
        userCategoryManagerMock.selectedCategory = mockCategory2  // This should trigger the update via publisher

        // Wait for the expectations to fulfill or timeout
        await fulfillment(of: [categoryPointsExpectation, totalPointsExpectation], timeout: 5.0)
        
        // Assert
        XCTAssertEqual(pointsViewModel.categoryPoints.map { $0.value }, [25, 30], "Expected categoryPoints to update with the new category's points.")
        XCTAssertEqual(pointsViewModel.totalPoints, 55, "Expected totalPoints to update with the new category's total points.")
        
        // Clean up the cancellables
        categoryPointsCancellable.cancel()
        totalPointsCancellable.cancel()
    }
    
    func testMapButtonPressed_PopulatesPointsFromCategoryPoints() async {
        // Arrange
        let mockCategory = UserCategory.mock(id: "1", name: "Category1")
        
        // Set up mock points for the category (with duplicate point IDs)
        let mockPoints = [
            UserPoint.mock(id: "1", pointValue: 10, pointCategory: [mockCategory.id]),
            UserPoint.mock(id: "1", pointValue: 10, pointCategory: [mockCategory.id]),
            UserPoint.mock(id: "1", pointValue: 10, pointCategory: [mockCategory.id]),
            UserPoint.mock(id: "1", pointValue: 10, pointCategory: [mockCategory.id]),
            UserPoint.mock(id: "2", pointValue: 20, pointCategory: [mockCategory.id]),
            UserPoint.mock(id: "3", pointValue: 15, pointCategory: [mockCategory.id])
        ]
        let mockCategoryPoints = mockPoints.map { Point(from: $0)}
        userPointManagerMock.points = mockPoints
        pointsViewModel.categoryPoints = mockCategoryPoints
        pointsViewModel.isMapButtonPressed = false
        
        // Mock the corresponding GenericPoints
        let mockGenericPoints = [
            GenericPoint.mock(id: "1"),
            GenericPoint.mock(id: "2"),
            GenericPoint.mock(id: "3"),
            GenericPoint.mock(id: "4"),
            GenericPoint.mock(id: "5")
        ]
        genericPointManagerMock.points = mockGenericPoints
        
        // Expectations
        let isMapButtonPressedExpectation = XCTestExpectation(description: "isMapButtonPressed set to true")
        
        // Subscribe to changes on `isMapButtonPressed`
        let isMapButtonPressedCancellable = pointsViewModel.$isMapButtonPressed
            .dropFirst()
            .sink { isMapButtonPressed in
                if isMapButtonPressed {
                    isMapButtonPressedExpectation.fulfill()
                }
            }
        
        // Act
        pointsViewModel.mapButtonPressed()
        
        // Wait for the expectations to fulfill or timeout
        await fulfillment(of: [isMapButtonPressedExpectation], timeout: 2.0)
        
        // Assert
        XCTAssertEqual(pointsViewModel.points.count, 3, "Expected 3 unique generic points to be populated.")
        let expectedIds = ["1", "2", "3"]
        let actualIds = pointsViewModel.points.map { $0.id }
        
        XCTAssertTrue(expectedIds.allSatisfy(actualIds.contains), "Expected points array to contain GenericPoints with IDs \(expectedIds.joined(separator: ", ")). Actual: \(actualIds.joined(separator: ", "))")
        
        XCTAssertTrue(pointsViewModel.isMapButtonPressed, "Expected isMapButtonPressed to be set to true after pressing the map button.")
        
        // Clean up the cancellables
        isMapButtonPressedCancellable.cancel()
    }
    
    func testListButtonPressed_ResetsMapState() async {
        // Arrange
        pointsViewModel.isMapButtonPressed = true
        pointsViewModel.points = [
            GenericPoint.mock(id: "1"),
            GenericPoint.mock(id: "2")
        ]
        pointsViewModel.selectedPoint = GenericPoint.mock(id: "1")
        
        // Expectations for `isMapButtonPressed` and points clearing
        let isMapButtonPressedExpectation = XCTestExpectation(description: "isMapButtonPressed set to false")
        
        // Subscribe to `isMapButtonPressed`
        let isMapButtonPressedCancellable = pointsViewModel.$isMapButtonPressed
            .dropFirst()
            .sink { isMapButtonPressed in
                if !isMapButtonPressed {
                    isMapButtonPressedExpectation.fulfill()
                }
            }
        
        // Act
        pointsViewModel.listButtonPressed()
        
        // Wait for the expectations to fulfill
        await fulfillment(of: [isMapButtonPressedExpectation], timeout: 2.0)
        
        // Assert
        XCTAssertFalse(pointsViewModel.isMapButtonPressed, "Expected isMapButtonPressed to be set to false.")
        XCTAssertEqual(pointsViewModel.points.count, 0, "Expected points array to be cleared.")
        XCTAssertNil(pointsViewModel.selectedPoint, "Expected selectedPoint to be nil after pressing list button.")
        
        // Clean up the cancellable
        isMapButtonPressedCancellable.cancel()
    }
    
    func testShowPointOnMap_ShowsPointAndSetsMapButtonPressed() async {
        // Arrange
        let mockPoint = Point(from: UserPoint.mock(id: "1", pointValue: 10))
        let mockGenericPoints = [
            GenericPoint.mock(id: "1"),
            GenericPoint.mock(id: "2")
        ]
        genericPointManagerMock.points = mockGenericPoints
        
        // Expectations for `isMapButtonPressed`
        let isMapButtonPressedExpectation = XCTestExpectation(description: "isMapButtonPressed set to true")
        
        // Subscribe to `isMapButtonPressed`
        let isMapButtonPressedCancellable = pointsViewModel.$isMapButtonPressed
            .dropFirst()
            .sink { isMapButtonPressed in
                if isMapButtonPressed {
                    isMapButtonPressedExpectation.fulfill()
                }
            }

        // Act
        pointsViewModel.showPointOnMap(point: mockPoint)
        
        // Wait for the expectations to fulfill
        await fulfillment(of: [isMapButtonPressedExpectation], timeout: 2.0)
        
        // Assert
        XCTAssertTrue(pointsViewModel.isMapButtonPressed, "Expected isMapButtonPressed to be set to true.")
        XCTAssertEqual(pointsViewModel.points.count, 1, "Expected only one point to be shown on the map.")
        XCTAssertEqual(pointsViewModel.points.first?.id, mockPoint.pointId, "Expected the correct point to be shown on the map.")
        
        // Clean up the cancellable
        isMapButtonPressedCancellable.cancel()
    }
    
    func testMapButtonPressedThenOnAppear_ReloadsMapPoints() async {
        // Arrange
        let mockUser = LoggedInUser.mock(nick: "TestUser")
        userManagerMock.loggedInUser = mockUser
        let mockCategory = UserCategory.mock(id: "1", name: "Category1")
        let mockPoints = [
            UserPoint.mock(id: "1", pointValue: 10, pointCategory: [mockCategory.id]),
            UserPoint.mock(id: "2", pointValue: 20, pointCategory: [mockCategory.id])
        ]
        let mockCategoryPoints = mockPoints.map { Point(from: $0) }
        pointsViewModel.categoryPoints = mockCategoryPoints
        userPointManagerMock.points = mockPoints
        let mockGenericPoints = [
            GenericPoint.mock(id: "1"),
            GenericPoint.mock(id: "2")
        ]
        genericPointManagerMock.points = mockGenericPoints

        // SIMULATE MAP BUTTON PRESSED BEFORE ON APPEAR
        let isMapButtonPressedExpectation = XCTestExpectation(description: "isMapButtonPressed set to true")
        let isMapButtonPressedCancellable = pointsViewModel.$isMapButtonPressed
            .dropFirst()
            .sink { isMapButtonPressed in
                if isMapButtonPressed {
                    isMapButtonPressedExpectation.fulfill()
                }
            }
        pointsViewModel.mapButtonPressed()
        await fulfillment(of: [isMapButtonPressedExpectation], timeout: 2.0)
        XCTAssertEqual(pointsViewModel.points.count, 2, "Expected 2 unique generic points to be populated after mapButtonPressed.")
        
        
        
        // Act: Call `onAppear` again with isMapButtonPressed true
        let isLoadingExpectation = XCTestExpectation(description: "isLoading set to false")
        // Subscribe to changes on `isLoading`
        let isLoadingCancellable = pointsViewModel.$isLoading
            .dropFirst()  // Drop the initial value
            .sink { isLoading in
                if !isLoading {
                    isLoadingExpectation.fulfill()
                }
            }

        // Act
        pointsViewModel.onAppear()
        
        // Wait for the expectations to fulfill or timeout
        await fulfillment(of: [isLoadingExpectation], timeout: 2.0)

        // Assert that the map points remain the same after reappearing
        XCTAssertEqual(pointsViewModel.points.count, 2, "Expected the same 2 unique generic points to be populated after onAppear when isMapButtonPressed is true.")

        // Clean up the cancellables
        isMapButtonPressedCancellable.cancel()
        isLoadingCancellable.cancel()
    }
    
    func testShowPointOnMapThenOnAppear_ReloadsSinglePointMap() async {
        // Arrange
        let mockUser = LoggedInUser.mock(nick: "TestUser")
        userManagerMock.loggedInUser = mockUser
        let mockCategory = UserCategory.mock(id: "1", name: "Category1")
        let mockPoints = [
            UserPoint.mock(id: "1", pointValue: 10, pointCategory: [mockCategory.id]),
            UserPoint.mock(id: "2", pointValue: 20, pointCategory: [mockCategory.id])
        ]
        let mockCategoryPoints = mockPoints.map { Point(from: $0) }
        pointsViewModel.categoryPoints = mockCategoryPoints
        userPointManagerMock.points = mockPoints
        let mockGenericPoints = [
            GenericPoint.mock(id: "1"),
            GenericPoint.mock(id: "2")
        ]
        genericPointManagerMock.points = mockGenericPoints
        
        let selectedPoint = Point(from: mockPoints.first!)

        // SIMULATE SHOW POINT ON MAP BEFORE ON APPEAR
        let isMapButtonPressedExpectation = XCTestExpectation(description: "isMapButtonPressed set to true")
        let isMapButtonPressedCancellable = pointsViewModel.$isMapButtonPressed
            .dropFirst()
            .sink { isMapButtonPressed in
                if isMapButtonPressed {
                    isMapButtonPressedExpectation.fulfill()
                }
            }
        
        // Simulate showing a point on the map
        pointsViewModel.showPointOnMap(point: selectedPoint)
        
        // Wait for the expectation to fulfill
        await fulfillment(of: [isMapButtonPressedExpectation], timeout: 2.0)
        
        // Assert that map points are populated with a single point
        XCTAssertEqual(pointsViewModel.points.count, 1, "Expected 1 unique generic point to be populated after showPointOnMap.")
        
        // Act: Call `onAppear` again with `isMapButtonPressed` true
        let isLoadingExpectation = XCTestExpectation(description: "isLoading set to false")
        
        // Subscribe to changes on `isLoading`
        let isLoadingCancellable = pointsViewModel.$isLoading
            .dropFirst()  // Drop the initial value
            .sink { isLoading in
                if !isLoading {
                    isLoadingExpectation.fulfill()
                }
            }

        // Act
        pointsViewModel.onAppear()

        // Wait for the expectation to fulfill
        await fulfillment(of: [isLoadingExpectation], timeout: 2.0)

        // Assert that the single point remains on the map after reappearing
        XCTAssertEqual(pointsViewModel.points.count, 1, "Expected the same single generic point to be populated after onAppear when isMapButtonPressed is true.")
        XCTAssertEqual(pointsViewModel.points.first?.id, selectedPoint.pointId, "Expected the same single generic point to be populated after onAppear when isMapButtonPressed is true.")
        
        // Clean up the cancellables
        isMapButtonPressedCancellable.cancel()
        isLoadingCancellable.cancel()
    }
    
    func testOnAppear_WhenNoCategorySelected_ShowsNoDataAvailable() async {
        // Arrange: Simulate no category being selected
        let mockPoints = [
            UserPoint.mock()
        ]
        userPointManagerMock.points = mockPoints
        userCategoryManagerMock.selectedCategory = nil
        
        // Expectations for `isLoading` property change
        let isLoadingExpectation = XCTestExpectation(description: "isLoading set to false")
        
        // Subscribe to changes on `isLoading`
        let isLoadingCancellable = pointsViewModel.$isLoading
            .dropFirst()  // Drop the initial value
            .sink { isLoading in
                if !isLoading {
                    isLoadingExpectation.fulfill()
                }
            }
        
        // Act: Call `onAppear` which will internally call `fetchData`
        pointsViewModel.onAppear()
        
        // Wait for `isLoading` to be set to false
        await fulfillment(of: [isLoadingExpectation], timeout: 2.0)
        
        // Assert that the `onNoDataAvailable` delegate method was called
        XCTAssertTrue(pointsFlowDelegateMock.selectCategoryPromptCalled, "Expected selected category prompt to be called when no category is selected and there are points available.")
        
        // Clean up the cancellable
        isLoadingCancellable.cancel()
    }
    
    func testUserLocation_Availability() {
        // Arrange
        let mockLocation = UserLocation.mock()
        locationManagerMock.location = mockLocation
        
        // Act
        let location = pointsViewModel.userLocation
        
        // Assert
        XCTAssertEqual(location?.latitude, mockLocation.latitude, "Expected latitude to match the mock location.")
        XCTAssertEqual(location?.longitude, mockLocation.longitude, "Expected longitude to match the mock location.")
    }
    
    func testOnAppear_NoPointsInCategory_HandlesGracefully() async {
        // Arrange
        let mockCategory = UserCategory.mock(id: "1", name: "Category1")
        userCategoryManagerMock.selectedCategory = mockCategory
        userPointManagerMock.points = []

        // Act
        let isLoadingExpectation = XCTestExpectation(description: "isLoading set to false")
        
        // Subscribe to changes on `isLoading`
        let isLoadingCancellable = pointsViewModel.$isLoading
            .dropFirst()  // Drop the initial value
            .sink { isLoading in
                if !isLoading {
                    isLoadingExpectation.fulfill()
                }
            }
        
        // Act: Call `onAppear` which will internally call `fetchData`
        pointsViewModel.onAppear()
        
        // Wait for `isLoading` to be set to false
        await fulfillment(of: [isLoadingExpectation], timeout: 2.0)

        // Assert
        XCTAssertEqual(pointsViewModel.totalPoints, 0, "Expected total points to be zero when no points are available.")
        XCTAssertEqual(pointsViewModel.categoryPoints.count, 0, "Expected categoryPoints to be empty when no points are available.")
        XCTAssertTrue(pointsFlowDelegateMock.onNoDataAvailableCalled, "Expected onNoDataAvailable to be called when no category is selected.")
        
        isLoadingCancellable.cancel()
    }
}
