//
//  CheckSumRepositoryTests.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 30.09.2024.
//

import XCTest
import RealmSwift
@testable import lifeisskillapp

final class RealmCheckSumRepositoryTests: XCTestCase {
    
    private struct Dependencies: RealmCheckSumRepository.Dependencies {
        var realmStorage: RealmStoraging
        let logger: LoggerServicing
    }
    
    var realm: Realm!
    var realmStorage: RealmStorageMock!
    var checkSumRepository: RealmCheckSumRepository!
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
        checkSumRepository = RealmCheckSumRepository(dependencies: dependencies)
    }
    
    override func tearDownWithError() throws {
        try realmStorage.clearRealm()
        realm = nil
        checkSumRepository = nil
        try super.tearDownWithError()
    }
    
    // MARK: - Test Methods
    
    func testDeleteUserSpecificCheckSums_Success() throws {
        // Arrange
        let checkSumData = RealmCheckSumData()
        checkSumData.userPoints = "500"
        checkSumData.rank = "Top 10"
        checkSumData.messages = "5 unread"
        checkSumData.events = "3 upcoming events"
        checkSumData.points = "1000"
        
        try realm.write {
            realm.add(checkSumData, update: .modified)
        }
        
        // Act
        try checkSumRepository.deleteUserSpecificCheckSums()
        
        // Assert
        let updatedCheckSumData = realm.objects(RealmCheckSumData.self).first
        XCTAssertNotNil(updatedCheckSumData, "Expected to find CheckSum data in the database.")
        XCTAssertEqual(updatedCheckSumData?.userPoints, "", "Expected userPoints to be reset to an empty string.")
        XCTAssertEqual(updatedCheckSumData?.rank, "", "Expected rank to be reset to an empty string.")
        XCTAssertEqual(updatedCheckSumData?.messages, "", "Expected messages to be reset to an empty string.")
        XCTAssertEqual(updatedCheckSumData?.events, "", "Expected events to be reset to an empty string.")
        XCTAssertEqual(updatedCheckSumData?.points, "1000", "Expected points to remain unchanged.")
    }

    func testDeleteUserSpecificCheckSums_NoData_ShouldLogMessage() throws {
        // Arrange
        
        // Act
        try checkSumRepository.deleteUserSpecificCheckSums()
        
        // Assert
        let checkSumData = realm.objects(RealmCheckSumData.self).first
        XCTAssertNil(checkSumData, "Expected no CheckSum data in the database.")
    }
    
    func testSaveCheckSumData_Success() throws {
        // Arrange
        let checkSumData = RealmCheckSumData()
        checkSumData.userPoints = "1000"
        checkSumData.rank = "Top 5"
        checkSumData.messages = "10 unread"
        checkSumData.events = "2 upcoming events"
        
        // Act
        try checkSumRepository.save(checkSumData)
        
        // Assert
        let savedCheckSumData = realm.objects(RealmCheckSumData.self).first
        XCTAssertNotNil(savedCheckSumData, "Expected to find saved CheckSum data.")
        XCTAssertEqual(savedCheckSumData?.userPoints, "1000", "Expected userPoints to be saved correctly.")
        XCTAssertEqual(savedCheckSumData?.rank, "Top 5", "Expected rank to be saved correctly.")
        XCTAssertEqual(savedCheckSumData?.messages, "10 unread", "Expected messages to be saved correctly.")
        XCTAssertEqual(savedCheckSumData?.events, "2 upcoming events", "Expected events to be saved correctly.")
    }
    
    func testDeleteCheckSumData_Success() throws {
        // Arrange
        let checkSumData = RealmCheckSumData()
        checkSumData.userPoints = "1000"
        checkSumData.rank = "Top 5"
        
        try realm.write {
            realm.add(checkSumData, update: .modified)
        }
        
        // Act
        try checkSumRepository.deleteAll()
        
        // Assert
        let deletedData = realm.objects(RealmCheckSumData.self).first
        XCTAssertNil(deletedData, "Expected CheckSum data to be deleted from Realm.")
    }
    
    func testGetAllCheckSumData_Success() throws {
        // Arrange
        let checkSumData1 = RealmCheckSumData()
        checkSumData1.userPoints = "500"
        checkSumData1.rank = "Top 10"
        
        let checkSumData2 = RealmCheckSumData()
        checkSumData2.userPoints = "1000"
        checkSumData2.rank = "Top 5"
        
        try realm.write {
            realm.add([checkSumData1, checkSumData2], update: .modified)
        }
        
        // Act
        let allCheckSumData = realm.objects(RealmCheckSumData.self)
        
        // Assert
        XCTAssertEqual(allCheckSumData.count, 1, "Expected to retrieve only one checksum data.")
        XCTAssertEqual(allCheckSumData.first?.userPoints, "1000", "Expected the userPoints to be 1000.")
    }
    
    func testDeleteUserSpecificCheckSums_RealmNotInitialized_ShouldThrowError() throws {
        // Arrange
        realmStorage.shouldThrowError = true
        
        // Act & Assert
        XCTAssertThrowsError(try checkSumRepository.deleteUserSpecificCheckSums()) { error in
            XCTAssertEqual((error as? BaseError)?.message, "Realm is not initialized")
        }
    }
    
    func testSaveCheckSumData_RealmNotInitialized_ShouldThrowError() throws {
        // Arrange
        realmStorage.shouldThrowError = true
        
        let checkSumData = RealmCheckSumData()
        checkSumData.userPoints = "1000"
        checkSumData.rank = "Top 5"
        
        // Act & Assert
        XCTAssertThrowsError(try checkSumRepository.save(checkSumData)) { error in
            XCTAssertEqual((error as? BaseError)?.message, "Realm is not initialized")
        }
    }
}
