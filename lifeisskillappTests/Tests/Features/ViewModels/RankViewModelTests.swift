//
//  RankViewModelTests.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 19.10.2024.
//

import XCTest
import Combine
@testable import lifeisskillapp

final class RankViewModelTests: XCTestCase {
    
    // MARK: - Mocks and Dependencies
    typealias CategorySelectorVM = CategorySelectorViewModelMock
    typealias SettingsBarVM = SettingsBarViewModelMock<LocationStatusBarViewModelMock>
    
    struct Dependencies: HasLoggerServicing & HasUserCategoryManager & HasUserRankManager & HasGameDataManager & HasUserManager & HasLocationManager & HasNetworkMonitor {
        var logger: LoggerServicing
        var locationManager: LocationManaging
        var gameDataManager: GameDataManaging
        var userManager: UserManaging
        var userCategoryManager: any UserCategoryManaging
        var userRankManager: any UserRankManaging
        var networkMonitor: NetworkMonitoring
    }
    
    // Mocked dependencies
    var loggerMock: LoggingServiceMock!
    var locationManagerMock: LocationManagerMock!
    var gameDataManagerMock: GameDataManagerMock!
    var userManagerMock: UserManagerMock!
    var userCategoryManagerMock: UserCategoryManagerMock!
    var userRankManagerMock: UserRankManagerMock!
    var networkMonitorMock: NetworkMonitorMock!
    var categorySelectorViewModelMock: CategorySelectorVM!
    var settingsBarViewModelMock: SettingsBarVM!
    var rankFlowDelegateMock: RankFlowDelegateMock!
    
    // ViewModel to test
    var rankViewModel: RankViewModel<CategorySelectorVM, SettingsBarVM>!
    
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
        userRankManagerMock = UserRankManagerMock()
        networkMonitorMock = NetworkMonitorMock()
        
        // Initialize CategorySelectorViewModel mock
        categorySelectorViewModelMock = CategorySelectorViewModelMock()
        
        let dependencies = Dependencies(
            logger: loggerMock,
            locationManager: locationManagerMock,
            gameDataManager: gameDataManagerMock,
            userManager: userManagerMock,
            userCategoryManager: userCategoryManagerMock,
            userRankManager: userRankManagerMock,
            networkMonitor: networkMonitorMock
        )
        
        // Initialize SettingsBarViewModel mock
        settingsBarViewModelMock = SettingsBarViewModelMock(
            dependencies: dependencies,
            delegate: nil
        )
        
        // Initialize RankFlowDelegate mock
        rankFlowDelegateMock = RankFlowDelegateMock()
        
        // Initialize RankViewModel
        rankViewModel = RankViewModel(
            dependencies: dependencies,
            categorySelectorVM: categorySelectorViewModelMock,
            delegate: rankFlowDelegateMock,
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
        userRankManagerMock = nil
        networkMonitorMock = nil
        categorySelectorViewModelMock = nil
        settingsBarViewModelMock = nil
        rankFlowDelegateMock = nil
        rankViewModel = nil
        cancellables = nil
        
        try super.tearDownWithError()
    }
    
    func testOnAppear_LoadsUsername() async {
        // Arrange
        let mockUser = LoggedInUser.mock(nick: "TestUser")
        userManagerMock.loggedInUser = mockUser
        userManagerMock.loadLoggedInUserDataCalled = false
        
        // Expectations for `isLoading` property changes
        let isLoadingExpectation = XCTestExpectation(description: "isLoading set to false")
        
        // Subscribe to changes on `isLoading`
        let isLoadingCancellable = rankViewModel.$isLoading
            .dropFirst()  // Drop the initial value
            .sink { isLoading in
                if !isLoading {
                    isLoadingExpectation.fulfill()
                }
            }
        
        // Act
        rankViewModel.onAppear()
        
        // Wait for the expectations to fulfill or timeout
        await fulfillment(of: [isLoadingExpectation], timeout: 3.0)
        
        // Assert
        XCTAssertEqual(rankViewModel.username, "TestUser", "Expected username to be updated from loggedInUser.")
        XCTAssertFalse(rankViewModel.isLoading, "Expected isLoading to be set to false after loading.")
        
        // Clean up the cancellables
        isLoadingCancellable.cancel()
    }
    
    func testIsSeparationModeEnabled_WhenMoreThanFiftyRankings() async {
        // Arrange
        let mockCategory = UserCategory.mock(id: "1", name: "Category1")
        userCategoryManagerMock.selectedCategory = mockCategory
        let rankCount = 51
        let mockRankedUsers = MockData.generateRankedUsers(count: rankCount)
        let expectedRankings = mockRankedUsers.map { Ranking(from: $0) }
        let mockRankings = UserRank.mock(catId: mockCategory.id, catUserRank: 1, listUserRank: mockRankedUsers)
        userRankManagerMock.ranks = [mockRankings]
        let mockRankedUser = mockRankedUsers.first!
        let mockUser = LoggedInUser.mock(userId: mockRankedUser.userId, nick: mockRankedUser.nick, sex: mockRankedUser.sex, userRank: Int(mockRankedUser.order) ?? 1, userPoints: Int(mockRankedUser.points) ?? 0, mainCategory: mockCategory.id
        )
        userManagerMock.loggedInUser = mockUser
        // Expectations for `isLoading` property changes
        let isLoadingExpectation = XCTestExpectation(description: "isLoading set to false")
        
        // Subscribe to changes on `isLoading`
        let isLoadingCancellable = rankViewModel.$isLoading
            .dropFirst()  // Drop the initial value
            .sink { isLoading in
                if !isLoading {
                    isLoadingExpectation.fulfill()
                }
            }
        
        // Act
        rankViewModel.onAppear()
        
        // Wait for the expectations to fulfill or timeout
        await fulfillment(of: [isLoadingExpectation], timeout: 3.0)
        
        // Assert
        XCTAssertTrue(rankViewModel.isSeparationModeEnabled, "Expected isSeparationModeEnabled to be true when there are more than 50 rankings.")
        XCTAssertFalse(rankViewModel.isListComplete, "List should be incomplete by default when separation mode is enabled.")
        XCTAssertEqual(rankViewModel.totalRankings, rankCount, "Expected totalRankings to be \(rankCount)")
        assertRankingsEqual(rankViewModel.categoryRankings, expectedRankings)
        // Clean up the cancellables
        isLoadingCancellable.cancel()
    }
    
    func testIsSeparationModeDisabled_WhenFiftyRankings() async {
        // Arrange
        let mockCategory = UserCategory.mock(id: "1", name: "Category1")
        userCategoryManagerMock.selectedCategory = mockCategory
        let rankCount = 50
        let mockRankedUsers = MockData.generateRankedUsers(count: rankCount)
        let expectedRankings = mockRankedUsers.map { Ranking(from: $0) }
        let mockRankings = UserRank.mock(catId: mockCategory.id, catUserRank: 1, listUserRank: mockRankedUsers)
        userRankManagerMock.ranks = [mockRankings]
        let mockRankedUser = mockRankedUsers.first!
        let mockUser = LoggedInUser.mock(
            userId: mockRankedUser.userId,
            nick: mockRankedUser.nick,
            sex: mockRankedUser.sex,
            userRank: Int(mockRankedUser.order) ?? 1,
            userPoints: Int(mockRankedUser.points) ?? 0,
            mainCategory: mockCategory.id
        )
        userManagerMock.loggedInUser = mockUser
        
        // Expectations for `isLoading` property changes
        let isLoadingExpectation = XCTestExpectation(description: "isLoading set to false")
        
        // Subscribe to changes on `isLoading`
        let isLoadingCancellable = rankViewModel.$isLoading
            .dropFirst()  // Drop the initial value
            .sink { isLoading in
                if !isLoading {
                    isLoadingExpectation.fulfill()
                }
            }
        
        // Act
        rankViewModel.onAppear()
        
        // Wait for the expectations to fulfill or timeout
        await fulfillment(of: [isLoadingExpectation], timeout: 3.0)
        
        // Assert
        XCTAssertFalse(rankViewModel.isSeparationModeEnabled, "Expected isSeparationModeEnabled to be false when there are 50 or fewer rankings.")
        XCTAssertEqual(rankViewModel.totalRankings, rankCount, "Expected totalRankings to be \(rankCount).")
        assertRankingsEqual(rankViewModel.categoryRankings, expectedRankings)
        
        // Clean up the cancellables
        isLoadingCancellable.cancel()
    }
    
    func testIsSeparationModeDisabled_WhenBelowFiftyRankings() async {
        // Arrange
        let mockCategory = UserCategory.mock(id: "1", name: "Category1")
        userCategoryManagerMock.selectedCategory = mockCategory
        let rankCount = 49
        let mockRankedUsers = MockData.generateRankedUsers(count: rankCount)
        let expectedRankings = mockRankedUsers.map { Ranking(from: $0) }
        let mockRankings = UserRank.mock(catId: mockCategory.id, catUserRank: 1, listUserRank: mockRankedUsers)
        userRankManagerMock.ranks = [mockRankings]
        let mockRankedUser = mockRankedUsers.first!
        let mockUser = LoggedInUser.mock(
            userId: mockRankedUser.userId,
            nick: mockRankedUser.nick,
            sex: mockRankedUser.sex,
            userRank: Int(mockRankedUser.order) ?? 1,
            userPoints: Int(mockRankedUser.points) ?? 0,
            mainCategory: mockCategory.id
        )
        userManagerMock.loggedInUser = mockUser
        
        // Expectations for `isLoading` property changes
        let isLoadingExpectation = XCTestExpectation(description: "isLoading set to false")
        
        // Subscribe to changes on `isLoading`
        let isLoadingCancellable = rankViewModel.$isLoading
            .dropFirst()  // Drop the initial value
            .sink { isLoading in
                if !isLoading {
                    isLoadingExpectation.fulfill()
                }
            }
        
        // Act
        rankViewModel.onAppear()
        
        // Wait for the expectations to fulfill or timeout
        await fulfillment(of: [isLoadingExpectation], timeout: 3.0)
        
        // Assert
        XCTAssertFalse(rankViewModel.isSeparationModeEnabled, "Expected isSeparationModeEnabled to be false when there are 50 or fewer rankings.")
        XCTAssertEqual(rankViewModel.totalRankings, rankCount, "Expected totalRankings to be \(rankCount).")
        XCTAssertEqual(rankViewModel.categoryRankings.count, expectedRankings.count, "Expected categoryRankings count to match the mockRankings count.")
        assertRankingsEqual(rankViewModel.categoryRankings, expectedRankings)
            
        // Clean up the cancellables
        isLoadingCancellable.cancel()
    }
    
    func testSeparation_UserInTop20_NoMiddleSection() async {
        // Arrange
        let mockCategory = UserCategory.mock(id: "1", name: "Category1")
        userCategoryManagerMock.selectedCategory = mockCategory
        
        let rankCount = 51
        let userRank = 19
        let mockRankedUsers = MockData.generateRankedUsers(count: rankCount)
        let mockRankings = UserRank.mock(catId: mockCategory.id, catUserRank: userRank, listUserRank: mockRankedUsers)
        userRankManagerMock.ranks = [mockRankings]
        
        let mockRankedUser = mockRankedUsers[userRank] // User is at the top 20
        let mockUser = LoggedInUser.mock(
            userId: mockRankedUser.userId,
            nick: mockRankedUser.nick,
            sex: mockRankedUser.sex,
            userRank: userRank,
            userPoints: Int(mockRankedUser.points) ?? 0,
            mainCategory: mockCategory.id
        )
        userManagerMock.loggedInUser = mockUser
        
        // Expectations for `isLoading` property changes
        let isLoadingExpectation = XCTestExpectation(description: "isLoading set to false")
        let isLoadingCancellable = rankViewModel.$isLoading
            .dropFirst()
            .sink { isLoading in
                if !isLoading {
                    isLoadingExpectation.fulfill()
                }
            }

        // Act
        rankViewModel.onAppear()
        
        // Wait for expectations to fulfill
        await fulfillment(of: [isLoadingExpectation], timeout: 3.0)

        // Assert
        XCTAssertEqual(rankViewModel.topRankings.count, 20, "Expected topRankings to have 20 users.")
        XCTAssertNil(rankViewModel.middleRankings, "Expected middleRankings to be nil for a user in the top 20.")
        XCTAssertEqual(rankViewModel.bottomRankings.count, 10, "Expected bottomRankings to have 10 users.")
        
        // Clean up
        isLoadingCancellable.cancel()
    }
    
    func testSeparation_UserInBottom10_NoMiddleSection() async {
        // Arrange
        let mockCategory = UserCategory.mock(id: "1", name: "Category1")
        userCategoryManagerMock.selectedCategory = mockCategory
        
        let rankCount = 51
        let userRank = 45
        let mockRankedUsers = MockData.generateRankedUsers(count: rankCount)
        let mockRankings = UserRank.mock(catId: mockCategory.id, catUserRank: userRank, listUserRank: mockRankedUsers)
        userRankManagerMock.ranks = [mockRankings]
        
        let mockRankedUser = mockRankedUsers[userRank] // User is at the top 20
        let mockUser = LoggedInUser.mock(
            userId: mockRankedUser.userId,
            nick: mockRankedUser.nick,
            sex: mockRankedUser.sex,
            userRank: userRank,
            userPoints: Int(mockRankedUser.points) ?? 0,
            mainCategory: mockCategory.id
        )
        userManagerMock.loggedInUser = mockUser
        
        // Expectations for `isLoading` property changes
        let isLoadingExpectation = XCTestExpectation(description: "isLoading set to false")
        let isLoadingCancellable = rankViewModel.$isLoading
            .dropFirst()
            .sink { isLoading in
                if !isLoading {
                    isLoadingExpectation.fulfill()
                }
            }

        // Act
        rankViewModel.onAppear()
        
        // Wait for expectations to fulfill
        await fulfillment(of: [isLoadingExpectation], timeout: 3.0)

        // Assert
        XCTAssertEqual(rankViewModel.topRankings.count, 20, "Expected topRankings to have 20 users.")
        XCTAssertNil(rankViewModel.middleRankings, "Expected middleRankings to be nil for a user in the bottom 10.")
        XCTAssertEqual(rankViewModel.bottomRankings.count, 10, "Expected bottomRankings to have 10 users.")
        
        // Clean up
        isLoadingCancellable.cancel()
    }
    
    func testSeparation_UserInMiddleNotNearTopOrBottom_AllThreeSections() async {
        // Arrange
        let mockCategory = UserCategory.mock(id: "1", name: "Category1")
        userCategoryManagerMock.selectedCategory = mockCategory
        
        let rankCount = 51
        let userRank = 30
        let mockRankedUsers = MockData.generateRankedUsers(count: rankCount)
        let mockRankings = UserRank.mock(catId: mockCategory.id, catUserRank: userRank, listUserRank: mockRankedUsers)
        userRankManagerMock.ranks = [mockRankings]
        
        let mockRankedUser = mockRankedUsers[userRank] // User is at the top 20
        let mockUser = LoggedInUser.mock(
            userId: mockRankedUser.userId,
            nick: mockRankedUser.nick,
            sex: mockRankedUser.sex,
            userRank: userRank,
            userPoints: Int(mockRankedUser.points) ?? 0,
            mainCategory: mockCategory.id
        )
        userManagerMock.loggedInUser = mockUser
        
        // Expectations for `isLoading` property changes
        let isLoadingExpectation = XCTestExpectation(description: "isLoading set to false")
        let isLoadingCancellable = rankViewModel.$isLoading
            .dropFirst()
            .sink { isLoading in
                if !isLoading {
                    isLoadingExpectation.fulfill()
                }
            }

        // Act
        rankViewModel.onAppear()
        
        // Wait for expectations to fulfill
        await fulfillment(of: [isLoadingExpectation], timeout: 3.0)

        // Assert
        XCTAssertEqual(rankViewModel.topRankings.count, 20, "Expected topRankings to have 20 users.")
        XCTAssertEqual(rankViewModel.middleRankings?.count, 5, "Expected middleRankings to have 5 users.")
        XCTAssertEqual(rankViewModel.bottomRankings.count, 10, "Expected bottomRankings to have 10 users.")
        
        // Clean up
        isLoadingCancellable.cancel()
    }
    
    func testSeparation_UserInMiddleNearTop_MergeMiddleSectionIntoTop() async {
        // Arrange
        let mockCategory = UserCategory.mock(id: "1", name: "Category1")
        userCategoryManagerMock.selectedCategory = mockCategory
        
        let rankCount = 51
        let userRank = 23
        let mockRankedUsers = MockData.generateRankedUsers(count: rankCount)
        let mockRankings = UserRank.mock(catId: mockCategory.id, catUserRank: userRank, listUserRank: mockRankedUsers)
        userRankManagerMock.ranks = [mockRankings]
        
        let mockRankedUser = mockRankedUsers[userRank] // User is at the top 20
        let mockUser = LoggedInUser.mock(
            userId: mockRankedUser.userId,
            nick: mockRankedUser.nick,
            sex: mockRankedUser.sex,
            userRank: userRank,
            userPoints: Int(mockRankedUser.points) ?? 0,
            mainCategory: mockCategory.id
        )
        userManagerMock.loggedInUser = mockUser
        
        // Expectations for `isLoading` property changes
        let isLoadingExpectation = XCTestExpectation(description: "isLoading set to false")
        let isLoadingCancellable = rankViewModel.$isLoading
            .dropFirst()
            .sink { isLoading in
                if !isLoading {
                    isLoadingExpectation.fulfill()
                }
            }

        // Act
        rankViewModel.onAppear()
        
        // Wait for expectations to fulfill
        await fulfillment(of: [isLoadingExpectation], timeout: 3.0)

        // Assert
        XCTAssertEqual(rankViewModel.topRankings.count, userRank + 2, "Expected topRankings to have more than 20 users.")
        XCTAssertNil(rankViewModel.middleRankings, "Expected middleRankings to be nil since they should merge with top 20.")
        XCTAssertEqual(rankViewModel.bottomRankings.count, 10, "Expected bottomRankings to have 10 users.")
        
        // Clean up
        isLoadingCancellable.cancel()
    }
    
    func testSeparation_UserInMiddleNearTop_MergeMiddleSectionIntoTop_EdgeCase_1() async {
        // Arrange
        let mockCategory = UserCategory.mock(id: "1", name: "Category1")
        userCategoryManagerMock.selectedCategory = mockCategory
        
        let rankCount = 51
        let userRank = 24
        let mockRankedUsers = MockData.generateRankedUsers(count: rankCount)
        let mockRankings = UserRank.mock(catId: mockCategory.id, catUserRank: userRank, listUserRank: mockRankedUsers)
        userRankManagerMock.ranks = [mockRankings]
        
        let mockRankedUser = mockRankedUsers[userRank] // User is at the top 20
        let mockUser = LoggedInUser.mock(
            userId: mockRankedUser.userId,
            nick: mockRankedUser.nick,
            sex: mockRankedUser.sex,
            userRank: userRank,
            userPoints: Int(mockRankedUser.points) ?? 0,
            mainCategory: mockCategory.id
        )
        userManagerMock.loggedInUser = mockUser
        
        // Expectations for `isLoading` property changes
        let isLoadingExpectation = XCTestExpectation(description: "isLoading set to false")
        let isLoadingCancellable = rankViewModel.$isLoading
            .dropFirst()
            .sink { isLoading in
                if !isLoading {
                    isLoadingExpectation.fulfill()
                }
            }

        // Act
        rankViewModel.onAppear()
        
        // Wait for expectations to fulfill
        await fulfillment(of: [isLoadingExpectation], timeout: 3.0)

        // Assert
        XCTAssertEqual(rankViewModel.topRankings.count, userRank + 2, "Expected topRankings to have more than 20 users.")
        XCTAssertNil(rankViewModel.middleRankings, "Expected middleRankings to be nil since they should merge with top 20.")
        XCTAssertEqual(rankViewModel.bottomRankings.count, 10, "Expected bottomRankings to have 10 users.")
        
        // Clean up
        isLoadingCancellable.cancel()
    }
    
    func testSeparation_UserInMiddleNearBottom_MergeMiddleSectionIntoBottom() async {
        // Arrange
        let mockCategory = UserCategory.mock(id: "1", name: "Category1")
        userCategoryManagerMock.selectedCategory = mockCategory
        
        let rankCount = 51
        let userRank = 38
        let mockRankedUsers = MockData.generateRankedUsers(count: rankCount)
        let mockRankings = UserRank.mock(catId: mockCategory.id, catUserRank: userRank, listUserRank: mockRankedUsers)
        userRankManagerMock.ranks = [mockRankings]
        
        let mockRankedUser = mockRankedUsers[userRank] // User is at the top 20
        let mockUser = LoggedInUser.mock(
            userId: mockRankedUser.userId,
            nick: mockRankedUser.nick,
            sex: mockRankedUser.sex,
            userRank: userRank,
            userPoints: Int(mockRankedUser.points) ?? 0,
            mainCategory: mockCategory.id
        )
        userManagerMock.loggedInUser = mockUser
        
        // Expectations for `isLoading` property changes
        let isLoadingExpectation = XCTestExpectation(description: "isLoading set to false")
        let isLoadingCancellable = rankViewModel.$isLoading
            .dropFirst()
            .sink { isLoading in
                if !isLoading {
                    isLoadingExpectation.fulfill()
                }
            }

        // Act
        rankViewModel.onAppear()
        
        // Wait for expectations to fulfill
        await fulfillment(of: [isLoadingExpectation], timeout: 3.0)

        // Assert
        XCTAssertEqual(rankViewModel.topRankings.count, 20, "Expected topRankings to have 20 users.")
        XCTAssertNil(rankViewModel.middleRankings, "Expected middleRankings to be nil since they should merge with bottom 10.")
        XCTAssertEqual(rankViewModel.bottomRankings.count, 51-userRank+2, "Expected bottomRankings to have more than 10 users.")
        
        // Clean up
        isLoadingCancellable.cancel()
    }
    
    func testSeparation_UserInMiddleNearBottom_MergeMiddleSectionIntoBottom_EdgeCase() async {
        // Arrange
        let mockCategory = UserCategory.mock(id: "1", name: "Category1")
        userCategoryManagerMock.selectedCategory = mockCategory
        
        let rankCount = 51
        let userRank = 36
        let mockRankedUsers = MockData.generateRankedUsers(count: rankCount)
        let mockRankings = UserRank.mock(catId: mockCategory.id, catUserRank: userRank, listUserRank: mockRankedUsers)
        userRankManagerMock.ranks = [mockRankings]
        
        let mockRankedUser = mockRankedUsers[userRank] // User is at the top 20
        let mockUser = LoggedInUser.mock(
            userId: mockRankedUser.userId,
            nick: mockRankedUser.nick,
            sex: mockRankedUser.sex,
            userRank: userRank,
            userPoints: Int(mockRankedUser.points) ?? 0,
            mainCategory: mockCategory.id
        )
        userManagerMock.loggedInUser = mockUser
        
        // Expectations for `isLoading` property changes
        let isLoadingExpectation = XCTestExpectation(description: "isLoading set to false")
        let isLoadingCancellable = rankViewModel.$isLoading
            .dropFirst()
            .sink { isLoading in
                if !isLoading {
                    isLoadingExpectation.fulfill()
                }
            }

        // Act
        rankViewModel.onAppear()
        
        // Wait for expectations to fulfill
        await fulfillment(of: [isLoadingExpectation], timeout: 3.0)

        // Assert
        XCTAssertEqual(rankViewModel.topRankings.count, 20, "Expected topRankings to have 20 users.")
        XCTAssertNil(rankViewModel.middleRankings, "Expected middleRankings to be nil since they should merge with bottom 10.")
        XCTAssertEqual(rankViewModel.bottomRankings.count, 51-userRank+2, "Expected bottomRankings to have more than 10 users.")
        
        // Clean up
        isLoadingCancellable.cancel()
    }
    
}

// MARK: - Private Helpers
extension RankViewModelTests {
    func assertRankingsEqual(_ actualRankings: [Ranking], _ expectedRankings: [Ranking], file: StaticString = #file, line: UInt = #line) {
        XCTAssertEqual(actualRankings.count, expectedRankings.count, "Ranking count mismatch", file: file, line: line)
        
        for (index, ranking) in actualRankings.enumerated() {
            let expectedRanking = expectedRankings[index]
            XCTAssertEqual(ranking.id, expectedRanking.id, "Ranking ID mismatch at index \(index)", file: file, line: line)
            XCTAssertEqual(ranking.rank, expectedRanking.rank, "Ranking rank mismatch at index \(index)", file: file, line: line)
            XCTAssertEqual(ranking.username, expectedRanking.username, "Ranking username mismatch at index \(index)", file: file, line: line)
            XCTAssertEqual(ranking.points, expectedRanking.points, "Ranking points mismatch at index \(index)", file: file, line: line)
            XCTAssertEqual(ranking.gender, expectedRanking.gender, "Ranking gender mismatch at index \(index)", file: file, line: line)
            XCTAssertEqual(ranking.trophyImage, expectedRanking.trophyImage, "Ranking trophyImage mismatch at index \(index)", file: file, line: line)
        }
    }
    
    func testOnAppear_NoUserRankData_ShowsNoDataAvailable() async {
        // Arrange: Simulate no user rank data available
        userRankManagerMock.ranks = []

        // Expectations for `isLoading` property change
        let isLoadingExpectation = XCTestExpectation(description: "isLoading set to false")

        // Subscribe to changes on `isLoading`
        let isLoadingCancellable = rankViewModel.$isLoading
            .dropFirst()  // Drop the initial value
            .sink { isLoading in
                if !isLoading {
                    isLoadingExpectation.fulfill()
                }
            }

        // Act: Call `onAppear` which will internally call `getSelectedCategoryRanking`
        rankViewModel.onAppear()

        // Wait for `isLoading` to be set to false
        await fulfillment(of: [isLoadingExpectation], timeout: 2.0)

        // Assert that the `onNoDataAvailable` delegate method was called
        XCTAssertTrue(rankFlowDelegateMock.onNoDataAvailableCalled, "Expected onNoDataAvailable to be called when no user rank data is available.")
        
        // Clean up the cancellable
        isLoadingCancellable.cancel()
    }
    
    func testOnAppear_NoCategorySelected_ShowsSelectCategoryPrompt() async {
        // Arrange: Simulate no category being selected
        let mockCategory = UserCategory.mock(id: "1", name: "Category1")
        userCategoryManagerMock.selectedCategory = mockCategory
        
        let rankCount = 51
        let userRank = 36
        let mockRankedUsers = MockData.generateRankedUsers(count: rankCount)
        let mockRankings = UserRank.mock(catId: mockCategory.id, catUserRank: userRank, listUserRank: mockRankedUsers)
        userRankManagerMock.ranks = [mockRankings]
        userCategoryManagerMock.selectedCategory = nil

        // Expectations for `isLoading` property change
        let isLoadingExpectation = XCTestExpectation(description: "isLoading set to false")

        // Subscribe to changes on `isLoading`
        let isLoadingCancellable = rankViewModel.$isLoading
            .dropFirst()  // Drop the initial value
            .sink { isLoading in
                if !isLoading {
                    isLoadingExpectation.fulfill()
                }
            }

        // Act: Call `onAppear` which will internally call `getSelectedCategoryRanking`
        rankViewModel.onAppear()

        // Wait for `isLoading` to be set to false
        await fulfillment(of: [isLoadingExpectation], timeout: 2.0)

        // Assert that the `selectCategoryPrompt` delegate method was called
        XCTAssertTrue(rankFlowDelegateMock.selectCategoryPromptCalled, "Expected selectCategoryPrompt to be called when no category is selected.")
        
        // Clean up the cancellable
        isLoadingCancellable.cancel()
    }
    
    func testOnAppear_NoRankingDataForCategory_ShowsNoDataAvailable() async {
        // Arrange: Simulate a category being selected but no ranking data for the category
        let mockCategory = UserCategory.mock(id: "1", name: "Category1")
        userCategoryManagerMock.selectedCategory = mockCategory
        
        let rankCount = 51
        let userRank = 36
        let mockRankedUsers = MockData.generateRankedUsers(count: rankCount)
        let mockRankings = UserRank.mock(catId: "2", catUserRank: userRank, listUserRank: mockRankedUsers)
        userRankManagerMock.ranks = [mockRankings]
        userCategoryManagerMock.selectedCategory = mockCategory
        userRankManagerMock.ranks = [mockRankings]

        // Expectations for `isLoading` property change
        let isLoadingExpectation = XCTestExpectation(description: "isLoading set to false")

        // Subscribe to changes on `isLoading`
        let isLoadingCancellable = rankViewModel.$isLoading
            .dropFirst()  // Drop the initial value
            .sink { isLoading in
                if !isLoading {
                    isLoadingExpectation.fulfill()
                }
            }

        // Act: Call `onAppear` which will internally call `getSelectedCategoryRanking`
        rankViewModel.onAppear()

        // Wait for `isLoading` to be set to false
        await fulfillment(of: [isLoadingExpectation], timeout: 2.0)

        // Assert that the `onNoDataAvailable` delegate method was called
        XCTAssertTrue(rankFlowDelegateMock.onNoDataAvailableCalled, "Expected onNoDataAvailable to be called when no ranking data is found for the selected category.")
        
        // Clean up the cancellable
        isLoadingCancellable.cancel()
    }
}
