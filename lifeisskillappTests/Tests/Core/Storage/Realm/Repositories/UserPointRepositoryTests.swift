//
//  UserPointRepositoryTests.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 01.10.2024.
//

import XCTest
import RealmSwift
@testable import lifeisskillapp

final class RealmUserPointRepositoryTests: XCTestCase {
    
    private struct Dependencies: RealmUserPointRepository.Dependencies {
        var realmStorage: RealmStoraging
        let logger: LoggerServicing
    }
    
    var realm: Realm!
    var realmStorage: RealmStorageMock!
    var userPointRepository: RealmUserPointRepository!
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
        userPointRepository = RealmUserPointRepository(dependencies: dependencies)
    }
    
    override func tearDownWithError() throws {
        try realmStorage.clearRealm()
        realm = nil
        userPointRepository = nil
        try super.tearDownWithError()
    }
    
    // MARK: - Test Methods
    
    func testSaveUserPointData_Success() throws {
        // Arrange
        let data = UserPointData.mock()
        let userPointData = RealmUserPointData(from: data) 
        
        // Act
        try userPointRepository.save(userPointData)
        
        // Assert
        let savedUserPointData = realm.objects(RealmUserPointData.self).first
        XCTAssertNotNil(savedUserPointData, "Expected user point data to be saved in Realm.")
        XCTAssertEqual(savedUserPointData?.checkSum, data.checkSum, "Checksum should match the saved data.")
        XCTAssertEqual(savedUserPointData?.data.count, data.data.count, "The number of user points saved should match the original data.")
    }
    
    func testGetAllUserPointData_Success() throws {
        // Arrange
        let data1 = UserPointData.mock()
        let data2 = UserPointData.mock(checkSum: "mockCheckSum2")
        let userPointData1 = RealmUserPointData(from: data1)
        let userPointData2 = RealmUserPointData(from: data2)
        
        try realm.write {
            realm.add([userPointData1, userPointData2], update: .modified)
        }
        
        // Act
        let allUserPointData = try userPointRepository.getAll()
        
        // Assert
        XCTAssertEqual(allUserPointData.count, 1, "Only one user point data object should exist due to the update policy.")
        XCTAssertEqual(allUserPointData.first?.checkSum, "mockCheckSum2", "Expected to retrieve the most recently saved user point data with 'mockCheckSum2'.")
    }
    
    func testGetUserPointById_Success() throws {
        // Arrange
        let data = UserPointData.mock() // Mock object
        let userPointData = RealmUserPointData(from: data)
        
        try realm.write {
            realm.add(userPointData, update: .modified)
        }
        
        // Act
        let fetchedUserPointData = try userPointRepository.getById(userPointData.dataID)
        
        // Assert
        XCTAssertNotNil(fetchedUserPointData, "User point data should be fetched from Realm by ID.")
        XCTAssertEqual(fetchedUserPointData?.checkSum, data.checkSum, "Fetched checksum should match the saved data.")
    }
    
    func testGetUserPointById_NotFound_ShouldReturnNil() throws {
        // Act
        let fetchedUserPointData = try userPointRepository.getById("non-existing-id")
        
        // Assert
        XCTAssertNil(fetchedUserPointData, "Fetching a non-existing user point ID should return nil.")
    }
    
    func testDeleteUserPointData_Success() throws {
        // Arrange
        let data = UserPointData.mock() // Mock object
        let userPointData = RealmUserPointData(from: data)
        
        try realm.write {
            realm.add(userPointData, update: .modified)
        }
        
        // Act
        try userPointRepository.delete(userPointData)
        
        // Assert
        let deletedData = realm.objects(RealmUserPointData.self).first
        XCTAssertNil(deletedData, "User point data should be deleted from Realm.")
    }
    
    func testDeleteAllUserPointData_Success() throws {
        // Arrange
        let data1 = UserPointData.mock()
        let data2 = UserPointData.mock(checkSum: "mockCheckSum2")
        let userPointData1 = RealmUserPointData(from: data1)
        let userPointData2 = RealmUserPointData(from: data2)
        
        try realm.write {
            realm.add([userPointData1, userPointData2], update: .modified)
        }
        
        // Act
        try userPointRepository.deleteAll()
        
        // Assert
        let allUserPointData = realm.objects(RealmUserPointData.self)
        XCTAssertEqual(allUserPointData.count, 0, "All user point data should be deleted from Realm.")
    }
    
    func testSaveUserPointData_RealmNotInitialized_ShouldThrowError() throws {
        // Arrange
        realmStorage.shouldThrowError = true
        
        let data = UserPointData.mock() // Mock object
        let userPointData = RealmUserPointData(from: data)
        
        // Act & Assert
        XCTAssertThrowsError(try userPointRepository.save(userPointData)) { error in
            XCTAssertEqual((error as? BaseError)?.message, "Realm is not initialized", "Error message should indicate that Realm is not initialized.")
        }
    }
    
    func testDeleteUserPointData_RealmNotInitialized_ShouldThrowError() throws {
        // Arrange
        realmStorage.shouldThrowError = true
        
        let data = UserPointData.mock() // Mock object
        let userPointData = RealmUserPointData(from: data)
        
        // Act & Assert
        XCTAssertThrowsError(try userPointRepository.delete(userPointData)) { error in
            XCTAssertEqual((error as? BaseError)?.message, "Realm is not initialized", "Error message should indicate that Realm is not initialized.")
        }
    }
}
