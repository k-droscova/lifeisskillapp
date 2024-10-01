//
//  RepositoryMocks.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 01.10.2024.
//

import Foundation
@testable import lifeisskillapp
import RealmSwift

// MARK: - Base Error Mock Class

enum MockRepositoryError: Error {
    case forcedError
}

// MARK: - Mock Repositories

class MockRealmLoginRepository: RealmLoginRepositoring {
    var shouldThrowError = false
    
    var savedLoginDetails: RealmLoginDetails?
    
    func save(_ entity: RealmLoginDetails) throws {
        if shouldThrowError {
            throw MockRepositoryError.forcedError
        }
        savedLoginDetails = entity
    }
    
    func save(_ entities: [RealmLoginDetails]) throws {
        if shouldThrowError {
            throw MockRepositoryError.forcedError
        }
        if let firstEntity = entities.last {
            savedLoginDetails = firstEntity
        }
    }
    
    func delete(_ entity: RealmLoginDetails) throws {
        if shouldThrowError {
            throw MockRepositoryError.forcedError
        }
        if savedLoginDetails?.userID == entity.userID {
            savedLoginDetails = nil
        }
    }
    
    func delete(_ entities: [RealmLoginDetails]) throws {
        if shouldThrowError {
            throw MockRepositoryError.forcedError
        }
        if savedLoginDetails?.userID == entities.first?.userID {
            savedLoginDetails = nil
        }
    }
    
    func deleteAll() throws {
        if shouldThrowError {
            throw MockRepositoryError.forcedError
        }
        savedLoginDetails = nil
    }
    
    func getAll() throws -> [RealmLoginDetails] {
        if shouldThrowError {
            throw MockRepositoryError.forcedError
        }
        if let savedDetails = savedLoginDetails {
            return [savedDetails]
        }
        return []
    }
    
    func getById(_ id: String) throws -> RealmLoginDetails? {
        if shouldThrowError {
            throw MockRepositoryError.forcedError
        }
        return savedLoginDetails?.userID == id ? savedLoginDetails : nil
    }
    
    func getSavedLoginDetails() throws -> RealmLoginDetails? {
        if shouldThrowError {
            throw MockRepositoryError.forcedError
        }
        return savedLoginDetails
    }
    
    func getLoggedInUser() throws -> RealmLoginDetails? {
        if shouldThrowError {
            throw MockRepositoryError.forcedError
        }
        return savedLoginDetails?.isLoggedIn == true ? savedLoginDetails : nil
    }
    
    func saveLoginUser(_ user: LoggedInUser) throws {
        if shouldThrowError {
            throw MockRepositoryError.forcedError
        }
        let loginDetails = RealmLoginDetails(from: user)
        savedLoginDetails = loginDetails
    }
    
    func markUserAsLoggedOut() throws {
        if shouldThrowError {
            throw MockRepositoryError.forcedError
        }
        guard let loggedInUser = savedLoginDetails, loggedInUser.isLoggedIn else {
            throw BaseError(
                context: .database,
                message: "No user is currently logged in.",
                logger: LoggingServiceMock()
            )
        }
        loggedInUser.isLoggedIn = false
    }
    
    func markUserAsLoggedIn() throws {
        if shouldThrowError {
            throw MockRepositoryError.forcedError
        }
        guard let loggedInUser = savedLoginDetails else {
            throw BaseError(
                context: .database,
                message: "No user is currently logged in.",
                logger: LoggingServiceMock()
            )
        }
        loggedInUser.isLoggedIn = true
    }
}

class MockRealmCheckSumRepository: RealmCheckSumRepositoring {
    var shouldThrowError = false
    var savedCheckSumData: RealmCheckSumData?
    
    // MARK: - CRUD Methods
    
    func save(_ entity: RealmCheckSumData) throws {
        if shouldThrowError {
            throw MockRepositoryError.forcedError
        }
        savedCheckSumData = entity
    }
    
    func save(_ entities: [RealmCheckSumData]) throws {
        if shouldThrowError {
            throw MockRepositoryError.forcedError
        }
        if let firstEntity = entities.last {
            savedCheckSumData = firstEntity
        }
    }
    
    func delete(_ entity: RealmCheckSumData) throws {
        if shouldThrowError {
            throw MockRepositoryError.forcedError
        }
        if savedCheckSumData?.checkSumID == entity.checkSumID {
            savedCheckSumData = nil
        }
    }
    
    func delete(_ entities: [RealmCheckSumData]) throws {
        if shouldThrowError {
            throw MockRepositoryError.forcedError
        }
        if savedCheckSumData?.checkSumID == entities.first?.checkSumID {
            savedCheckSumData = nil
        }
    }
    
    func deleteAll() throws {
        if shouldThrowError {
            throw MockRepositoryError.forcedError
        }
        savedCheckSumData = nil
    }
    
    func getAll() throws -> [RealmCheckSumData] {
        if shouldThrowError {
            throw MockRepositoryError.forcedError
        }
        if let savedData = savedCheckSumData {
            return [savedData]
        }
        return []
    }
    
    func getById(_ id: String) throws -> RealmCheckSumData? {
        if shouldThrowError {
            throw MockRepositoryError.forcedError
        }
        return savedCheckSumData?.checkSumID == id ? savedCheckSumData : nil
    }
    
    // MARK: - Custom Methods
    
    func deleteUserSpecificCheckSums() throws {
        if shouldThrowError {
            throw MockRepositoryError.forcedError
        }
        guard let checkSumData = savedCheckSumData else {
            print("No CheckSum data found to clear.")
            return
        }
        
        checkSumData.userPoints = ""
        checkSumData.rank = ""
        checkSumData.messages = ""
        checkSumData.events = ""
        print("User-specific checksums cleared, generic points checksum retained.")
    }
}

class MockRealmUserCategoryRepository: RealmUserCategoryRepositoring {
    var shouldThrowError = false
    var savedCategoryData: RealmUserCategoryData?
    
    // MARK: - CRUD Methods
    
    func save(_ entity: RealmUserCategoryData) throws {
        if shouldThrowError {
            throw MockRepositoryError.forcedError
        }
        savedCategoryData = entity
    }
    
    func save(_ entities: [RealmUserCategoryData]) throws {
        if shouldThrowError {
            throw MockRepositoryError.forcedError
        }
        if let firstEntity = entities.last {
            savedCategoryData = firstEntity
        }
    }
    
    func delete(_ entity: RealmUserCategoryData) throws {
        if shouldThrowError {
            throw MockRepositoryError.forcedError
        }
        if savedCategoryData?.dataID == entity.dataID {
            savedCategoryData = nil
        }
    }
    
    func delete(_ entities: [RealmUserCategoryData]) throws {
        if shouldThrowError {
            throw MockRepositoryError.forcedError
        }
        if savedCategoryData?.dataID == entities.first?.dataID {
            savedCategoryData = nil
        }
    }
    
    func deleteAll() throws {
        if shouldThrowError {
            throw MockRepositoryError.forcedError
        }
        savedCategoryData = nil
    }
    
    func getAll() throws -> [RealmUserCategoryData] {
        if shouldThrowError {
            throw MockRepositoryError.forcedError
        }
        if let savedData = savedCategoryData {
            return [savedData]
        }
        return []
    }
    
    func getById(_ id: String) throws -> RealmUserCategoryData? {
        if shouldThrowError {
            throw MockRepositoryError.forcedError
        }
        return savedCategoryData?.dataID == id ? savedCategoryData : nil
    }
}

class MockRealmUserRankRepository: RealmUserRankRepositoring {
    var shouldThrowError = false
    var savedRankData: RealmUserRankData?
    
    // MARK: - CRUD Methods
    
    func save(_ entity: RealmUserRankData) throws {
        if shouldThrowError {
            throw MockRepositoryError.forcedError
        }
        savedRankData = entity
    }
    
    func save(_ entities: [RealmUserRankData]) throws {
        if shouldThrowError {
            throw MockRepositoryError.forcedError
        }
        if let firstEntity = entities.last {
            savedRankData = firstEntity
        }
    }
    
    func delete(_ entity: RealmUserRankData) throws {
        if shouldThrowError {
            throw MockRepositoryError.forcedError
        }
        if savedRankData?.dataID == entity.dataID {
            savedRankData = nil
        }
    }
    
    func delete(_ entities: [RealmUserRankData]) throws {
        if shouldThrowError {
            throw MockRepositoryError.forcedError
        }
        if savedRankData?.dataID == entities.first?.dataID {
            savedRankData = nil
        }
    }
    
    func deleteAll() throws {
        if shouldThrowError {
            throw MockRepositoryError.forcedError
        }
        savedRankData = nil
    }
    
    func getAll() throws -> [RealmUserRankData] {
        if shouldThrowError {
            throw MockRepositoryError.forcedError
        }
        if let savedData = savedRankData {
            return [savedData]
        }
        return []
    }
    
    func getById(_ id: String) throws -> RealmUserRankData? {
        if shouldThrowError {
            throw MockRepositoryError.forcedError
        }
        return savedRankData?.dataID == id ? savedRankData : nil
    }
}

class MockRealmUserPointRepository: RealmUserPointRepositoring {
    var shouldThrowError = false
    var savedUserPointData: RealmUserPointData?
    
    // MARK: - CRUD Methods
    
    func save(_ entity: RealmUserPointData) throws {
        if shouldThrowError {
            throw MockRepositoryError.forcedError
        }
        savedUserPointData = entity
    }
    
    func save(_ entities: [RealmUserPointData]) throws {
        if shouldThrowError {
            throw MockRepositoryError.forcedError
        }
        if let firstEntity = entities.last {
            savedUserPointData = firstEntity
        }
    }
    
    func delete(_ entity: RealmUserPointData) throws {
        if shouldThrowError {
            throw MockRepositoryError.forcedError
        }
        if savedUserPointData?.dataID == entity.dataID {
            savedUserPointData = nil
        }
    }
    
    func delete(_ entities: [RealmUserPointData]) throws {
        if shouldThrowError {
            throw MockRepositoryError.forcedError
        }
        if savedUserPointData?.dataID == entities.first?.dataID {
            savedUserPointData = nil
        }
    }
    
    func deleteAll() throws {
        if shouldThrowError {
            throw MockRepositoryError.forcedError
        }
        savedUserPointData = nil
    }
    
    func getAll() throws -> [RealmUserPointData] {
        if shouldThrowError {
            throw MockRepositoryError.forcedError
        }
        if let savedData = savedUserPointData {
            return [savedData]
        }
        return []
    }
    
    func getById(_ id: String) throws -> RealmUserPointData? {
        if shouldThrowError {
            throw MockRepositoryError.forcedError
        }
        return savedUserPointData?.dataID == id ? savedUserPointData : nil
    }
}

class MockRealmGenericPointRepository: RealmGenericPointRepositoring {
    var shouldThrowError = false
    var savedGenericPointData: RealmGenericPointData?
    
    // MARK: - CRUD Methods
    
    func save(_ entity: RealmGenericPointData) throws {
        if shouldThrowError {
            throw MockRepositoryError.forcedError
        }
        savedGenericPointData = entity
    }
    
    func save(_ entities: [RealmGenericPointData]) throws {
        if shouldThrowError {
            throw MockRepositoryError.forcedError
        }
        if let firstEntity = entities.last {
            savedGenericPointData = firstEntity
        }
    }
    
    func delete(_ entity: RealmGenericPointData) throws {
        if shouldThrowError {
            throw MockRepositoryError.forcedError
        }
        if savedGenericPointData?.dataID == entity.dataID {
            savedGenericPointData = nil
        }
    }
    
    func delete(_ entities: [RealmGenericPointData]) throws {
        if shouldThrowError {
            throw MockRepositoryError.forcedError
        }
        if savedGenericPointData?.dataID == entities.first?.dataID {
            savedGenericPointData = nil
        }
    }
    
    func deleteAll() throws {
        if shouldThrowError {
            throw MockRepositoryError.forcedError
        }
        savedGenericPointData = nil
    }
    
    func getAll() throws -> [RealmGenericPointData] {
        if shouldThrowError {
            throw MockRepositoryError.forcedError
        }
        if let savedData = savedGenericPointData {
            return [savedData]
        }
        return []
    }
    
    func getById(_ id: String) throws -> RealmGenericPointData? {
        if shouldThrowError {
            throw MockRepositoryError.forcedError
        }
        return savedGenericPointData?.dataID == id ? savedGenericPointData : nil
    }
}

class MockRealmScannedPointRepository: RealmScannedPointRepositoring {
    var shouldThrowError = false
    var savedScannedPoints: [RealmScannedPoint] = []
    
    // MARK: - CRUD Methods
    
    func save(_ entity: RealmScannedPoint) throws {
        if shouldThrowError {
            throw MockRepositoryError.forcedError
        }
        savedScannedPoints = [entity]  // Save only the latest scanned point
    }
    
    func save(_ entities: [RealmScannedPoint]) throws {
        if shouldThrowError {
            throw MockRepositoryError.forcedError
        }
        if let lastEntity = entities.last {
            savedScannedPoints = [lastEntity]  // Save only the latest scanned point from the list
        }
    }
    
    func delete(_ entity: RealmScannedPoint) throws {
        if shouldThrowError {
            throw MockRepositoryError.forcedError
        }
        savedScannedPoints.removeAll { $0.pointID == entity.pointID }
    }
    
    func delete(_ entities: [RealmScannedPoint]) throws {
        if shouldThrowError {
            throw MockRepositoryError.forcedError
        }
        let idsToDelete = entities.map { $0.pointID }
        savedScannedPoints.removeAll { idsToDelete.contains($0.pointID) }
    }
    
    func deleteAll() throws {
        if shouldThrowError {
            throw MockRepositoryError.forcedError
        }
        savedScannedPoints.removeAll()
    }
    
    func getAll() throws -> [RealmScannedPoint] {
        if shouldThrowError {
            throw MockRepositoryError.forcedError
        }
        return savedScannedPoints
    }
    
    func getById(_ id: String) throws -> RealmScannedPoint? {
        if shouldThrowError {
            throw MockRepositoryError.forcedError
        }
        return savedScannedPoints.first { $0.pointID == id }
    }
    
    // MARK: - Specific Methods
    
    func getScannedPoints() throws -> [ScannedPoint] {
        if shouldThrowError {
            throw MockRepositoryError.forcedError
        }
        return savedScannedPoints.map { $0.scannedPoint() }
    }
}

class MockRealmSponsorRepository: RealmSponsorRepositoring {
    var shouldThrowError = false
    var savedSponsorData: [RealmSponsorData] = []
    
    // MARK: - CRUD Methods
    
    func save(_ entity: RealmSponsorData) throws {
        if shouldThrowError {
            throw MockRepositoryError.forcedError
        }
        savedSponsorData.append(entity) // Save the sponsor data
    }
    
    func save(_ entities: [RealmSponsorData]) throws {
        if shouldThrowError {
            throw MockRepositoryError.forcedError
        }
        savedSponsorData.append(contentsOf: entities)
    }
    
    func delete(_ entity: RealmSponsorData) throws {
        if shouldThrowError {
            throw MockRepositoryError.forcedError
        }
        savedSponsorData.removeAll { $0.sponsorID == entity.sponsorID }
    }
    
    func delete(_ entities: [RealmSponsorData]) throws {
        if shouldThrowError {
            throw MockRepositoryError.forcedError
        }
        let idsToDelete = entities.map { $0.sponsorID }
        savedSponsorData.removeAll { idsToDelete.contains($0.sponsorID) }
    }
    
    func deleteAll() throws {
        if shouldThrowError {
            throw MockRepositoryError.forcedError
        }
        savedSponsorData.removeAll()
    }
    
    func getAll() throws -> [RealmSponsorData] {
        if shouldThrowError {
            throw MockRepositoryError.forcedError
        }
        return savedSponsorData
    }
    
    func getById(_ id: String) throws -> RealmSponsorData? {
        if shouldThrowError {
            throw MockRepositoryError.forcedError
        }
        return savedSponsorData.first { $0.sponsorID == id }
    }
}
