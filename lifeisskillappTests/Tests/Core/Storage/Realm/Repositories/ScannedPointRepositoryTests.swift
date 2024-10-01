//
//  ScannedPointRepositoryTests.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 01.10.2024.
//

import XCTest
import RealmSwift
@testable import lifeisskillapp

final class RealmScannedPointRepositoryTests: XCTestCase {
    
    private struct Dependencies: RealmScannedPointRepository.Dependencies {
        var realmStorage: RealmStoraging
        let logger: LoggerServicing
    }
    
    var realm: Realm!
    var realmStorage: RealmStorageMock!
    var scannedPointRepository: RealmScannedPointRepository!
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
        scannedPointRepository = RealmScannedPointRepository(dependencies: dependencies)
    }
    
    override func tearDownWithError() throws {
        realmStorage.clearRealm()
        realm = nil
        scannedPointRepository = nil
        try super.tearDownWithError()
    }
    
    // MARK: - Test Methods
    
    func testSaveScannedPoint_Success() throws {
        // Arrange
        let point = ScannedPoint.mock()
        let scannedPointData = RealmScannedPoint(from: point)
        
        // Act
        try scannedPointRepository.save(scannedPointData)
        
        // Assert
        let savedScannedPoint = realm.objects(RealmScannedPoint.self).first
        XCTAssertNotNil(savedScannedPoint, "Expected to find saved scanned point data.")
        XCTAssertEqual(savedScannedPoint?.code, point.code, "Expected point code to be saved correctly.")
        XCTAssertEqual(savedScannedPoint?.location?.timestamp, point.location?.timestamp, "Expected timestamp to be saved correctly.")
    }
    
    func testGetScannedPoints_Success() throws {
        // Arrange
        let point1 = ScannedPoint.mock()
        let point2 = ScannedPoint.mock(code: "mockCode2")
        let scannedPointData1 = RealmScannedPoint(from: point1)
        let scannedPointData2 = RealmScannedPoint(from: point2)
        
        try realm.write {
            realm.add([scannedPointData1, scannedPointData2], update: .modified)
        }
        
        // Act
        let fetchedPoints = try scannedPointRepository.getScannedPoints()
        
        // Assert
        XCTAssertEqual(fetchedPoints.count, 2, "Expected two scanned points to be retrieved.")
        XCTAssertEqual(fetchedPoints.first?.id, point1.id, "Expected to retrieve the first scanned point.")
        XCTAssertEqual(fetchedPoints.last?.id, point2.id, "Expected to retrieve the second scanned point.")
    }
    
    func testGetScannedPoints_Empty_ShouldReturnEmptyArray() throws {
        // Act
        let fetchedPoints = try scannedPointRepository.getScannedPoints()
        
        // Assert
        XCTAssertTrue(fetchedPoints.isEmpty, "Expected no scanned points to be returned.")
    }
    
    func testDeleteScannedPoint_Success() throws {
        // Arrange
        let point = ScannedPoint.mock()
        let scannedPointData = RealmScannedPoint(from: point)
        
        try realm.write {
            realm.add(scannedPointData, update: .modified)
        }
        
        // Act
        try scannedPointRepository.delete(scannedPointData)
        
        // Assert
        let deletedScannedPoint = realm.objects(RealmScannedPoint.self).first
        XCTAssertNil(deletedScannedPoint, "Expected the scanned point to be deleted from Realm.")
    }
    
    func testDeleteAllScannedPoints_Success() throws {
        // Arrange
        let point1 = ScannedPoint.mock()
        let point2 = ScannedPoint.mock(code: "mockPoint2")
        let scannedPointData1 = RealmScannedPoint(from: point1)
        let scannedPointData2 = RealmScannedPoint(from: point2)
        
        try realm.write {
            realm.add([scannedPointData1, scannedPointData2], update: .modified)
        }
        
        // Act
        try scannedPointRepository.deleteAll()
        
        // Assert
        let allScannedPoints = realm.objects(RealmScannedPoint.self)
        XCTAssertEqual(allScannedPoints.count, 0, "Expected all scanned points to be deleted from Realm.")
    }
    
    func testSaveScannedPoint_RealmNotInitialized_ShouldThrowError() throws {
        // Arrange
        realmStorage.shouldThrowError = true
        
        let scannedPointData = RealmScannedPoint(from: ScannedPoint.mock())
        
        // Act & Assert
        XCTAssertThrowsError(try scannedPointRepository.save(scannedPointData)) { error in
            XCTAssertEqual((error as? BaseError)?.message, "Realm is not initialized", "Expected Realm initialization error message.")
        }
    }
    
    func testDeleteScannedPoint_RealmNotInitialized_ShouldThrowError() throws {
        // Arrange
        realmStorage.shouldThrowError = true
        
        let scannedPointData = RealmScannedPoint(from: ScannedPoint.mock())
        
        // Act & Assert
        XCTAssertThrowsError(try scannedPointRepository.delete(scannedPointData)) { error in
            XCTAssertEqual((error as? BaseError)?.message, "Realm is not initialized", "Expected Realm initialization error message.")
        }
    }
}
