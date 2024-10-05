//
//  SponsorRepositoryTests.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 01.10.2024.
//

import XCTest
import RealmSwift
@testable import lifeisskillapp

final class RealmSponsorRepositoryTests: XCTestCase {
    
    private struct Dependencies: RealmSponsorRepository.Dependencies {
        var realmStorage: RealmStoraging
        let logger: LoggerServicing
    }
    
    var realm: Realm!
    var realmStorage: RealmStorageMock!
    var sponsorRepository: RealmSponsorRepository!
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
        sponsorRepository = RealmSponsorRepository(dependencies: dependencies)
    }
    
    override func tearDownWithError() throws {
        realmStorage.clearRealm()
        realm = nil
        sponsorRepository = nil
        try super.tearDownWithError()
    }
    
    // MARK: - Test Methods
    
    func testSaveSponsorData_Success() throws {
        // Arrange
        let sponsorID = "sponsor123"
        let imageData = Data([0x00, 0x01, 0x02])
        let sponsorData = RealmSponsorData(sponsorID: sponsorID, imageData: imageData)
        
        // Act
        try sponsorRepository.save(sponsorData)
        
        // Assert
        let savedSponsorData = realm.objects(RealmSponsorData.self).first
        XCTAssertNotNil(savedSponsorData, "Expected to find saved sponsor data.")
        XCTAssertEqual(savedSponsorData?.sponsorID, sponsorID, "Expected sponsorID to be saved correctly.")
        XCTAssertEqual(savedSponsorData?.imageData, imageData, "Expected imageData to be saved correctly.")
    }
    
    func testGetAllSponsorData_Success() throws {
        // Arrange
        let sponsorData1 = RealmSponsorData(sponsorID: "sponsor123", imageData: Data([0x00, 0x01, 0x02]))
        let sponsorData2 = RealmSponsorData(sponsorID: "sponsor456", imageData: Data([0x03, 0x04, 0x05]))
        
        try realm.write {
            realm.add([sponsorData1, sponsorData2], update: .modified)
        }
        
        // Act
        let allSponsorData = try sponsorRepository.getAll()
        
        // Assert
        XCTAssertEqual(allSponsorData.count, 2, "Expected two sponsor data.")
        XCTAssertEqual(allSponsorData.first?.sponsorID, "sponsor123", "Expected to retrieve the first sponsor data.")
    }
    
    func testGetSponsorById_Success() throws {
        // Arrange
        let sponsorID = "sponsor123"
        let imageData = Data([0x00, 0x01, 0x02])
        let sponsorData = RealmSponsorData(sponsorID: sponsorID, imageData: imageData)
        
        try realm.write {
            realm.add(sponsorData, update: .modified)
        }
        
        // Act
        let fetchedSponsor = try sponsorRepository.getById(sponsorID)
        
        // Assert
        XCTAssertNotNil(fetchedSponsor, "Expected to retrieve the sponsor by ID from Realm.")
        XCTAssertEqual(fetchedSponsor?.sponsorID, sponsorID, "Expected the sponsorID to match.")
        XCTAssertEqual(fetchedSponsor?.imageData, imageData, "Expected the imageData to match.")
    }
    
    func testGetSponsorById_NotFound_ShouldReturnNil() throws {
        // Act
        let fetchedSponsor = try sponsorRepository.getById("non-existing-id")
        
        // Assert
        XCTAssertNil(fetchedSponsor, "Expected nil for a non-existing sponsor ID.")
    }
    
    func testDeleteSponsorData_Success() throws {
        // Arrange
        let sponsorID = "sponsor123"
        let imageData = Data([0x00, 0x01, 0x02])
        let sponsorData = RealmSponsorData(sponsorID: sponsorID, imageData: imageData)
        
        try realm.write {
            realm.add(sponsorData, update: .modified)
        }
        
        // Act
        try sponsorRepository.delete(sponsorData)
        
        // Assert
        let deletedSponsorData = realm.objects(RealmSponsorData.self).first
        XCTAssertNil(deletedSponsorData, "Expected the sponsor data to be deleted from Realm.")
    }

    func testDeleteAllSponsorData_Success() throws {
        // Arrange
        let sponsorData1 = RealmSponsorData(sponsorID: "sponsor123", imageData: Data([0x00, 0x01, 0x02]))
        let sponsorData2 = RealmSponsorData(sponsorID: "sponsor456", imageData: Data([0x03, 0x04, 0x05]))
        
        try realm.write {
            realm.add([sponsorData1, sponsorData2], update: .modified)
        }
        
        // Act
        try sponsorRepository.deleteAll()
        
        // Assert
        let allSponsorData = realm.objects(RealmSponsorData.self)
        XCTAssertEqual(allSponsorData.count, 0, "Expected all sponsor data to be deleted from Realm.")
    }
    
    func testSaveSponsorData_RealmNotInitialized_ShouldThrowError() throws {
        // Arrange
        realmStorage.shouldThrowError = true
        
        let sponsorData = RealmSponsorData(sponsorID: "sponsor123", imageData: Data([0x00, 0x01, 0x02]))
        
        // Act & Assert
        XCTAssertThrowsError(try sponsorRepository.save(sponsorData)) { error in
            XCTAssertEqual((error as? BaseError)?.message, "Realm is not initialized", "Expected Realm initialization error message.")
        }
    }
    
    func testDeleteSponsorData_RealmNotInitialized_ShouldThrowError() throws {
        // Arrange
        realmStorage.shouldThrowError = true
        
        let sponsorData = RealmSponsorData(sponsorID: "sponsor123", imageData: Data([0x00, 0x01, 0x02]))
        
        // Act & Assert
        XCTAssertThrowsError(try sponsorRepository.delete(sponsorData)) { error in
            XCTAssertEqual((error as? BaseError)?.message, "Realm is not initialized", "Expected Realm initialization error message.")
        }
    }
}
