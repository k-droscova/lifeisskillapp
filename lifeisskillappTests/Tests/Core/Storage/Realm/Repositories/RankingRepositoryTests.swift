//
//  RankingRepositoryTests.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 01.10.2024.
//

import XCTest
import RealmSwift
@testable import lifeisskillapp

final class RealmUserRankRepositoryTests: XCTestCase {
    
    private struct Dependencies: RealmUserRankRepository.Dependencies {
        var realmStorage: RealmStoraging
        let logger: LoggerServicing
    }
    
    var realm: Realm!
    var realmStorage: RealmStorageMock!
    var userRankRepository: RealmUserRankRepository!
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
        userRankRepository = RealmUserRankRepository(dependencies: dependencies)
    }
    
    override func tearDownWithError() throws {
        try realmStorage.clearRealm()
        realm = nil
        userRankRepository = nil
        try super.tearDownWithError()
    }
    
    // MARK: - Test Methods
    
    func testSaveUserRankData_Success() throws {
        // Arrange
        let userRankData = UserRankData.mock()
        let realmUserRankData = RealmUserRankData(from: userRankData)
        
        // Act
        try userRankRepository.save(realmUserRankData)
        
        // Assert
        let savedUserRankData = realm.objects(RealmUserRankData.self).first
        XCTAssertNotNil(savedUserRankData, "Expected to find saved user rank data.")
        XCTAssertEqual(savedUserRankData?.checkSum, userRankData.checkSum, "Expected checksum to be saved correctly.")
        XCTAssertEqual(savedUserRankData?.data.count, userRankData.data.count, "Expected the same number of user ranks.")
    }
    
    func testGetAllUserRankData_Success() throws {
        // Arrange
        let userRankData1 = UserRankData.mock()
        let userRankData2 = UserRankData.mock(checkSum: "mockCheckSum2")
        let realmUserRankData1 = RealmUserRankData(from: userRankData1)
        let realmUserRankData2 = RealmUserRankData(from: userRankData2)
        
        try realm.write {
            realm.add([realmUserRankData1, realmUserRankData2], update: .modified)
        }
        
        // Act
        let allUserRankData = try userRankRepository.getAll()
        
        // Assert
        XCTAssertEqual(allUserRankData.count, 1, "Expected to retrieve only one user rank data.")
        XCTAssertEqual(allUserRankData.first?.checkSum, "mockCheckSum2", "Expected the latest saved checksum to be 'mockCheckSum2'.")
    }
    
    func testGetUserRankById_Success() throws {
        // Arrange
        let userRankData = UserRankData.mock()
        let realmUserRankData = RealmUserRankData(from: userRankData)
        
        try realm.write {
            realm.add(realmUserRankData, update: .modified)
        }
        
        // Act
        let fetchedUserRankData = try userRankRepository.getById(realmUserRankData.dataID)
        
        // Assert
        XCTAssertNotNil(fetchedUserRankData, "Expected to retrieve the user rank by ID from Realm.")
        XCTAssertEqual(fetchedUserRankData?.checkSum, userRankData.checkSum, "Expected the checksum to match.")
    }
    
    func testGetUserRankById_NotFound_ShouldReturnNil() throws {
        // Act
        let fetchedUserRankData = try userRankRepository.getById("non-existing-id")
        
        // Assert
        XCTAssertNil(fetchedUserRankData, "Expected to return nil for a non-existing user rank ID.")
    }
    
    func testDeleteUserRankData_Success() throws {
        // Arrange
        let userRankData = UserRankData.mock()
        let realmUserRankData = RealmUserRankData(from: userRankData)
        
        try realm.write {
            realm.add(realmUserRankData, update: .modified)
        }
        
        // Act
        try userRankRepository.delete(realmUserRankData)
        
        // Assert
        let deletedData = realm.objects(RealmUserRankData.self).first
        XCTAssertNil(deletedData, "Expected user rank data to be deleted from Realm.")
    }

    func testDeleteAllUserRankData_Success() throws {
        // Arrange
        let userRankData1 = UserRankData.mock()
        let userRankData2 = UserRankData.mock(checkSum: "mockCheckSum2")
        let realmUserRankData1 = RealmUserRankData(from: userRankData1)
        let realmUserRankData2 = RealmUserRankData(from: userRankData2)
        
        try realm.write {
            realm.add([realmUserRankData1, realmUserRankData2], update: .modified)
        }
        
        // Act
        try userRankRepository.deleteAll()
        
        // Assert
        let allUserRankData = realm.objects(RealmUserRankData.self)
        XCTAssertEqual(allUserRankData.count, 0, "Expected all user rank data to be deleted from Realm.")
    }
    
    func testSaveUserRankData_RealmNotInitialized_ShouldThrowError() throws {
        // Arrange
        realmStorage.shouldThrowError = true
        
        let userRankData = UserRankData.mock()
        let realmUserRankData = RealmUserRankData(from: userRankData)
        
        // Act & Assert
        XCTAssertThrowsError(try userRankRepository.save(realmUserRankData)) { error in
            XCTAssertEqual((error as? BaseError)?.message, "Realm is not initialized")
        }
    }
    
    func testDeleteUserRankData_RealmNotInitialized_ShouldThrowError() throws {
        // Arrange
        realmStorage.shouldThrowError = true
        
        let userRankData = UserRankData.mock()
        let realmUserRankData = RealmUserRankData(from: userRankData)
        
        // Act & Assert
        XCTAssertThrowsError(try userRankRepository.delete(realmUserRankData)) { error in
            XCTAssertEqual((error as? BaseError)?.message, "Realm is not initialized")
        }
    }
}
