//
//  UserCategoryManagerTests.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 18.10.2024.
//

import XCTest
import Combine
@testable import lifeisskillapp

final class UserCategoryManagerTests: XCTestCase {
    
    // MARK: - Mocks and Dependencies

    private struct Dependencies: UserCategoryManager.Dependencies {
        var userDefaultsStorage: UserDefaultsStoraging
        var logger: LoggerServicing
        var userDataAPI: UserDataAPIServicing
        var storage: PersistentUserDataStoraging
        var networkMonitor: NetworkMonitoring
    }
    
    var logger: LoggerServicing!
    var userDefaultStorageMock: UserDefaultsStorageMock!
    var userDataAPIMock: UserDataAPIServiceMock!
    var persistentStorageMock: PersistentUserDataStorageMock!
    var networkMonitorMock: NetworkMonitorMock!
    var userCategoryManager: UserCategoryManager!
    var cancellables: Set<AnyCancellable>!

    // MARK: - Setup and Teardown

    override func setUpWithError() throws {
        try super.setUpWithError()

        logger = LoggingServiceMock()
        userDefaultStorageMock = UserDefaultsStorageMock()
        userDataAPIMock = UserDataAPIServiceMock()
        persistentStorageMock = PersistentUserDataStorageMock()
        networkMonitorMock = NetworkMonitorMock()

        let dependencies = Dependencies(
            userDefaultsStorage: userDefaultStorageMock,
            logger: logger,
            userDataAPI: userDataAPIMock,
            storage: persistentStorageMock,
            networkMonitor: networkMonitorMock
        )

        userCategoryManager = UserCategoryManager(dependencies: dependencies)
        cancellables = []
    }

    override func tearDownWithError() throws {
        logger = nil
        userDefaultStorageMock = nil
        userDataAPIMock = nil
        persistentStorageMock = nil
        networkMonitorMock = nil
        userCategoryManager = nil
        cancellables = nil

        try super.tearDownWithError()
    }

    // MARK: - Test Cases
    
    func testFetch_CallsAPIAndSavesToStorage() async throws {
        // Arrange
        let mockToken = "mockToken"
        userDefaultStorageMock.mockToken = mockToken
        let mockResponseData = UserCategoryData.mock()
        
        // Set up mock API response
        userDataAPIMock.userCategoriesResponseToReturn = APIResponse(data: mockResponseData)

        // Act
        try await userCategoryManager.fetch()

        // Assert
        // Check that userDataAPIService was called with the correct token
        XCTAssertTrue(userDataAPIMock.userCategoriesCalled, "userCategories API should be called")
        XCTAssertEqual(userDataAPIMock.userTokenArgument, mockToken, "Correct token should be passed to userCategories API")

        // Check that storage.saveUserCategoryData was called with the data returned by userDataAPIService
        XCTAssertTrue(persistentStorageMock.saveUserCategoryDataCalled, "saveUserCategoryData should be called on the storage")
        XCTAssertEqual(persistentStorageMock.userCategoryDataArgument?.main.id, mockResponseData.main.id, "The same data returned by the API should be passed to saveUserCategoryData")
        XCTAssertEqual(persistentStorageMock.userCategoryDataArgument?.data.count, mockResponseData.data.count, "The same data returned by the API should be passed to saveUserCategoryData")
        
        // Check that the selectedCategory is updated correctly
        XCTAssertEqual(userCategoryManager.selectedCategory?.id, mockResponseData.main.id, "The selectedCategory should be updated to the main category from the API response")
    }
    
    func testFetch_TokenIsMissing_ThrowsError() async throws {
        // Arrange
        userDefaultStorageMock.token = nil
        
        // Act & Assert
        do {
            try await userCategoryManager.fetch()
            XCTFail("fetch() should throw an error when token is missing")
        } catch let error as BaseError {
            XCTAssertEqual(error.code, ErrorCodes.general(.missingToken).code, "Expected missing token error")
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }
    
    func testFetch_ApiFailure_ThrowsError() async throws {
        // Arrange
        let mockToken = "mockToken"
        userDefaultStorageMock.token = mockToken
        let mockApiError = BaseError(context: .api, message: "API Failure", logger: logger)
        userDataAPIMock.errorToThrow = mockApiError
        
        // Act & Assert
        do {
            try await userCategoryManager.fetch()
            XCTFail("fetch() should throw an API error")
        } catch let error as BaseError {
            XCTAssertEqual(error.code, mockApiError.code, "Expected API error")
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }

    func testGetById_ReturnsCorrectCategory() async {
        // Arrange
        let mockCategory = UserCategory.mock(id: "testCategory")
        persistentStorageMock.mockUserCategoryData = UserCategoryData.mock(data: [mockCategory])
        await userCategoryManager.loadFromRepository()
        
        // Act
        let retrievedCategory = userCategoryManager.getById(id: "testCategory")
        
        // Assert
        XCTAssertEqual(retrievedCategory?.id, mockCategory.id, "getById should return the correct category by ID")
    }

    func testGetById_ReturnsNilForInvalidId() async {
        // Arrange
        let mockCategory = UserCategory.mock(id: "testCategory")
        persistentStorageMock.mockUserCategoryData = UserCategoryData.mock(data: [mockCategory])
        await userCategoryManager.loadFromRepository()

        // Act
        let retrievedCategory = userCategoryManager.getById(id: "invalidId")

        // Assert
        XCTAssertNil(retrievedCategory, "getById should return nil for an invalid ID")
    }

    func testGetAll_ReturnsAllCategories() async {
        // Arrange
        let mockCategories = [UserCategory.mock(id: "category1"), UserCategory.mock(id: "category2")]
        persistentStorageMock.mockUserCategoryData = UserCategoryData.mock(data: mockCategories)
        await userCategoryManager.loadFromRepository()

        // Act
        let categories = userCategoryManager.getAll()

        // Assert
        XCTAssertEqual(categories.count, mockCategories.count, "getAll should return all categories stored")
    }

    func testGetMainCategory_ReturnsMainCategory() async {
        // Arrange
        let mockMainCategory = UserCategory.mock(id: "mainCategory")
        let otherCategory = UserCategory.mock(id: "otherCategory")
        persistentStorageMock.mockUserCategoryData = UserCategoryData.mock(main: mockMainCategory, data: [otherCategory, mockMainCategory])
        await userCategoryManager.loadFromRepository()

        // Act
        let mainCategory = userCategoryManager.getMainCategory()

        // Assert
        XCTAssertEqual(mainCategory?.id, mockMainCategory.id, "getMainCategory should return the main category")
    }

    func testOnLogout_ClearsCategoryData() async {
        // Arrange
        persistentStorageMock.mockUserCategoryData = UserCategoryData.mock()
        await userCategoryManager.loadFromRepository()

        // Act
        userCategoryManager.onLogout()

        // Assert
        XCTAssertEqual(userCategoryManager.getAll().count, 0, "All categories should be cleared on logout")
    }

    func testSelectedCategoryPublisher_PublishesChanges() async {
        // Arrange
        let mockCategory1 = UserCategory.mock(id: "category2")
        let mockCategory2 = UserCategory.mock(id: "category3")
        
        // Two expectations: one for each change
        let expectation1 = XCTestExpectation(description: "First selected category should be published")
        let expectation2 = XCTestExpectation(description: "Second selected category should be published")

        var publishedCategories: [UserCategory] = []

        // Observe the selectedCategoryPublisher
        userCategoryManager.selectedCategoryPublisher
            .sink { category in
                if let category = category {
                    publishedCategories.append(category)
                    if publishedCategories.count == 1 {
                        expectation1.fulfill() // First change
                    } else if publishedCategories.count == 2 {
                        expectation2.fulfill() // Second change
                    }
                }
            }
            .store(in: &cancellables)

        // Act
        userCategoryManager.selectedCategory = mockCategory1
        userCategoryManager.selectedCategory = mockCategory2

        // Assert
        await fulfillment(of: [expectation1, expectation2], timeout: 1)

        XCTAssertEqual(publishedCategories.count, 2, "The selectedCategoryPublisher should publish changes twice")
        XCTAssertEqual(publishedCategories[0].id, mockCategory1.id, "The first published category should be mockCategory1")
        XCTAssertEqual(publishedCategories[1].id, mockCategory2.id, "The second published category should be mockCategory2")
    }
    
    func testCheckSum_ReturnsNil() {
        // Act
        let checkSum = userCategoryManager.checkSum()

        // Assert
        XCTAssertNil(checkSum, "checkSum() should return nil for UserCategoryManager")
    }
}
