//
//  CategoryRepositoryTests.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 01.10.2024.
//

import XCTest
import RealmSwift
@testable import lifeisskillapp

final class RealmUserCategoryRepositoryTests: XCTestCase {
    
    private struct Dependencies: RealmUserCategoryRepository.Dependencies {
        var realmStorage: RealmStoraging
        let logger: LoggerServicing
    }
    
    var realm: Realm!
    var realmStorage: RealmStorageMock!
    var categoryRepository: RealmUserCategoryRepository!
    var logger: LoggerServicing!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        realmStorage = RealmStorageMock()
        realm = realmStorage.getRealm()
        logger = LoggingServiceMock()

        let dependencies = Dependencies(
            realmStorage: realmStorage,
            logger: logger
        )
        categoryRepository = RealmUserCategoryRepository(dependencies: dependencies)
    }
    
    override func tearDownWithError() throws {
        realmStorage.clearRealm()
        realm = nil
        categoryRepository = nil
        try super.tearDownWithError()
    }
    
    func testSaveUserCategoryData_Success() throws {
        // Arrange
        let category = UserCategoryData.mock()
        let categoryData = RealmUserCategoryData(from: category)
        
        // Act
        try categoryRepository.save(categoryData)
        
        // Assert
        let savedCategoryData = realm.objects(RealmUserCategoryData.self).first
        XCTAssertNotNil(savedCategoryData, "Expected to find saved category data.")
        XCTAssertEqual(savedCategoryData?.mainCategory?.categoryID, category.main.id, "Expected main category ID to be saved correctly.")
        XCTAssertEqual(savedCategoryData?.allCategories.count, category.data.count, "Expected same number of categories.")
    }
    
    func testGetAllUserCategoryData_Success() throws {
        // Arrange
        let category1 = UserCategoryData.mock()
        let category2 = UserCategoryData.mock(main: .mock(id: "mockId"))
        let categoryData1 = RealmUserCategoryData(from: category1)
        let categoryData2 = RealmUserCategoryData(from: category2)
        
        try realm.write {
            realm.add([categoryData1, categoryData2], update: .modified)
        }
        
        // Act
        let allCategoryData = try categoryRepository.getAll()
        
        // Assert
        XCTAssertEqual(allCategoryData.count, 1, "Expected to retrieve only one category data.")
        XCTAssertEqual(allCategoryData.first?.mainCategory?.categoryID, "mockId", "Expected the main category ID to be 'mockId'.")
    }
    
    func testGetUserCategoryById_Success() throws {
        // Arrange
        let category = UserCategoryData.mock()
        let categoryData = RealmUserCategoryData(from: category)
        
        try realm.write {
            realm.add(categoryData, update: .modified)
        }
        
        // Act
        let fetchedCategory = try categoryRepository.getById(categoryData.dataID)
        
        // Assert
        XCTAssertNotNil(fetchedCategory, "Expected to retrieve the category by ID from Realm.")
        XCTAssertEqual(fetchedCategory?.mainCategory?.categoryID, category.main.id, "Expected the main category ID to match.")
    }
    
    func testGetUserCategoryById_NotFound_ShouldReturnNil() throws {
        // Act
        let fetchedCategory = try categoryRepository.getById("non-existing-id")
        
        // Assert
        XCTAssertNil(fetchedCategory, "Expected to return nil for a non-existing category ID.")
    }
    
    func testDeleteUserCategoryData_Success() throws {
        // Arrange
        let category = UserCategoryData.mock()
        let categoryData = RealmUserCategoryData(from: category)
        
        try realm.write {
            realm.add(categoryData, update: .modified)
        }
        
        // Act
        try categoryRepository.delete(categoryData)
        
        // Assert
        let deletedData = realm.objects(RealmUserCategoryData.self).first
        XCTAssertNil(deletedData, "Expected category data to be deleted from Realm.")
    }

    func testDeleteAllUserCategoryData_Success() throws {
        // Arrange
        let category1 = UserCategoryData.mock()
        let category2 = UserCategoryData.mock(main: .mock(id: "mockId"))
        let categoryData1 = RealmUserCategoryData(from: category1)
        let categoryData2 = RealmUserCategoryData(from: category2)
        
        try realm.write {
            realm.add([categoryData1, categoryData2], update: .modified)
        }
        
        // Act
        try categoryRepository.deleteAll()
        
        // Assert
        let allCategoryData = realm.objects(RealmUserCategoryData.self)
        XCTAssertEqual(allCategoryData.count, 0, "Expected all category data to be deleted from Realm.")
    }
    
    func testSaveUserCategoryData_RealmNotInitialized_ShouldThrowError() throws {
        // Arrange
        realmStorage.shouldThrowError = true
        
        let category = UserCategoryData.mock()
        let categoryData = RealmUserCategoryData(from: category)
        
        // Act & Assert
        XCTAssertThrowsError(try categoryRepository.save(categoryData)) { error in
            XCTAssertEqual((error as? BaseError)?.message, "Realm is not initialized")
        }
    }
    
    func testDeleteUserCategoryData_RealmNotInitialized_ShouldThrowError() throws {
        // Arrange
        realmStorage.shouldThrowError = true
        
        let category = UserCategoryData.mock()
        let categoryData = RealmUserCategoryData(from: category)
        
        // Act & Assert
        XCTAssertThrowsError(try categoryRepository.delete(categoryData)) { error in
            XCTAssertEqual((error as? BaseError)?.message, "Realm is not initialized")
        }
    }
}
