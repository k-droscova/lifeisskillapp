//
//  PointRepositoryTests.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 01.10.2024.
//

import XCTest
import RealmSwift
@testable import lifeisskillapp

final class RealmGenericPointRepositoryTests: XCTestCase {
    
    private struct Dependencies: RealmGenericPointRepository.Dependencies {
        var realmStorage: RealmStoraging
        let logger: LoggerServicing
    }
    
    var realm: Realm!
    var realmStorage: RealmStorageMock!
    var pointRepository: RealmGenericPointRepository!
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
        pointRepository = RealmGenericPointRepository(dependencies: dependencies)
    }
    
    override func tearDownWithError() throws {
        try realmStorage.clearRealm()
        realm = nil
        pointRepository = nil
        try super.tearDownWithError()
    }
    
    // MARK: - Test Methods
    
    func testSaveGenericPointData_Success() throws {
        // Arrange
        let point = GenericPointData.mock()
        let pointData = RealmGenericPointData(from: point)
        
        // Act
        try pointRepository.save(pointData)
        
        // Assert
        let savedPointData = realm.objects(RealmGenericPointData.self).first
        XCTAssertNotNil(savedPointData, "Expected to find saved point data.")
        XCTAssertEqual(savedPointData?.checkSum, point.checkSum, "Expected checkSum to be saved correctly.")
        XCTAssertEqual(savedPointData?.data.count, point.data.count, "Expected the correct number of point data items to be saved.")
    }
    
    func testGetAllGenericPointData_Success() throws {
        // Arrange
        let point1 = GenericPointData.mock(checkSum: "checkSum1")
        let point2 = GenericPointData.mock(checkSum: "checkSum2")
        let pointData1 = RealmGenericPointData(from: point1)
        let pointData2 = RealmGenericPointData(from: point2)
        
        try realm.write {
            realm.add([pointData1, pointData2], update: .modified)
        }
        
        // Act
        let allPointData = try pointRepository.getAll()
        
        // Assert
        XCTAssertEqual(allPointData.count, 1, "Expected only one point data due to update policy.")
        XCTAssertEqual(allPointData.first?.checkSum, "checkSum2", "Expected the latest saved checkSum to be 'checkSum2'.")
    }
    
    func testGetGenericPointById_Success() throws {
        // Arrange
        let point = GenericPointData.mock(checkSum: "checkSum1")
        let pointData = RealmGenericPointData(from: point)
        
        try realm.write {
            realm.add(pointData, update: .modified)
        }
        
        // Act
        let fetchedPoint = try pointRepository.getById(pointData.dataID)
        
        // Assert
        XCTAssertNotNil(fetchedPoint, "Expected to retrieve the point by ID from Realm.")
        XCTAssertEqual(fetchedPoint?.checkSum, point.checkSum, "Expected the checkSum to match.")
    }
    
    func testGetGenericPointById_NotFound_ShouldReturnNil() throws {
        // Act
        let fetchedPoint = try pointRepository.getById("non-existing-id")
        
        // Assert
        XCTAssertNil(fetchedPoint, "Expected nil for a non-existing point ID.")
    }
    
    func testDeleteGenericPointData_Success() throws {
        // Arrange
        let point = GenericPointData.mock()
        let pointData = RealmGenericPointData(from: point)
        
        try realm.write {
            realm.add(pointData, update: .modified)
        }
        
        // Act
        try pointRepository.delete(pointData)
        
        // Assert
        let deletedData = realm.objects(RealmGenericPointData.self).first
        XCTAssertNil(deletedData, "Expected the point data to be deleted from Realm.")
    }

    func testDeleteAllGenericPointData_Success() throws {
        // Arrange
        let point1 = GenericPointData.mock(checkSum: "checkSum1")
        let point2 = GenericPointData.mock(checkSum: "checkSum2")
        let pointData1 = RealmGenericPointData(from: point1)
        let pointData2 = RealmGenericPointData(from: point2)
        
        try realm.write {
            realm.add([pointData1, pointData2], update: .modified)
        }
        
        // Act
        try pointRepository.deleteAll()
        
        // Assert
        let allPointData = realm.objects(RealmGenericPointData.self)
        XCTAssertEqual(allPointData.count, 0, "Expected all point data to be deleted from Realm.")
    }
    
    func testSaveGenericPointData_RealmNotInitialized_ShouldThrowError() throws {
        // Arrange
        realmStorage.shouldThrowError = true
        
        let point = GenericPointData.mock()
        let pointData = RealmGenericPointData(from: point)
        
        // Act & Assert
        XCTAssertThrowsError(try pointRepository.save(pointData)) { error in
            XCTAssertEqual((error as? BaseError)?.message, "Realm is not initialized", "Expected Realm initialization error message.")
        }
    }
    
    func testDeleteGenericPointData_RealmNotInitialized_ShouldThrowError() throws {
        // Arrange
        realmStorage.shouldThrowError = true
        
        let point = GenericPointData.mock()
        let pointData = RealmGenericPointData(from: point)
        
        // Act & Assert
        XCTAssertThrowsError(try pointRepository.delete(pointData)) { error in
            XCTAssertEqual((error as? BaseError)?.message, "Realm is not initialized", "Expected Realm initialization error message.")
        }
    }
}
