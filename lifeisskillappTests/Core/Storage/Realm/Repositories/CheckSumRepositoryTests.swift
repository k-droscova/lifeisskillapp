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
        
        // Set up an in-memory Realm instance for testing
        realmStorage = RealmStorageMock()
        realm = realmStorage.getRealm() // Get the in-memory Realm instance
        logger = LoggingServiceMock()
        
        // Initialize the repository with the mocked storage
        let dependencies = Dependencies(
            realmStorage: realmStorage,
            logger: logger
        )
        checkSumRepository = RealmCheckSumRepository(dependencies: dependencies)
    }
    
    override func tearDownWithError() throws {
        // Clear Realm data after each test
        realmStorage.clearRealm()
        realm = nil
        checkSumRepository = nil
        try super.tearDownWithError()
    }
    
    // MARK: - Test Methods
    
    // Test deleting user-specific checksums while preserving generic points
    func testDeleteUserSpecificCheckSums() throws {
        // Arrange: Set up a RealmCheckSumData object with sample data
        let checkSumData = RealmCheckSumData()
        checkSumData.userPoints = "500"
        checkSumData.rank = "Top 10"
        checkSumData.messages = "5 unread"
        checkSumData.events = "3 upcoming events"
        checkSumData.points = "1000"  // This should remain unchanged
        
        try realm.write {
            realm.add(checkSumData, update: .modified)
        }
        
        // Act: Call deleteUserSpecificCheckSums on the repository
        try checkSumRepository.deleteUserSpecificCheckSums()
        
        // Assert: Fetch the updated object and check the fields
        let updatedCheckSumData = realm.objects(RealmCheckSumData.self).first
        
        XCTAssertNotNil(updatedCheckSumData, "Expected to find CheckSum data in the database.")
        XCTAssertEqual(updatedCheckSumData?.userPoints, "", "Expected userPoints to be reset to an empty string.")
        XCTAssertEqual(updatedCheckSumData?.rank, "", "Expected rank to be reset to an empty string.")
        XCTAssertEqual(updatedCheckSumData?.messages, "", "Expected messages to be reset to an empty string.")
        XCTAssertEqual(updatedCheckSumData?.events, "", "Expected events to be reset to an empty string.")
        XCTAssertEqual(updatedCheckSumData?.points, "1000", "Expected points to remain unchanged.")
    }
}
