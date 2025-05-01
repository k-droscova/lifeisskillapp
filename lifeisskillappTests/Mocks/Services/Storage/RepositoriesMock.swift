//
//  RepositoriesMock.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 02.10.2024.
//

@testable import lifeisskillapp
import Foundation
import RealmSwift

final class RealmLoginRepositoryMock: RealmLoginRepositoring {
    
    var mockLoginDetails: RealmLoginDetails? = nil
    var mockErrorToThrow: Error? = nil
    
    // MARK: - RealmLoginRepositoring Conformance
    
    func getSavedLoginDetails() throws -> RealmLoginDetails? {
        guard let error = mockErrorToThrow else {
            return mockLoginDetails
        }
        throw error
    }
    
    func getLoggedInUser() throws -> RealmLoginDetails? {
        guard let error = mockErrorToThrow else {
            return mockLoginDetails?.isLoggedIn == true ? mockLoginDetails : nil
        }
        throw error
    }
    
    func saveLoginUser(_ user: LoggedInUser) throws {
        guard let error = mockErrorToThrow else {
            let loginDetails = RealmLoginDetails(from: user)
            mockLoginDetails = loginDetails
            return
        }
        throw error
    }
    
    func markUserAsLoggedOut() throws {
        guard let error = mockErrorToThrow else {
            guard let loginDetails = mockLoginDetails else {
                throw BaseError(
                    context: .database,
                    message: "No user is currently logged in.",
                    logger: LoggingServiceMock()
                )
            }
            loginDetails.isLoggedIn = false
            mockLoginDetails = loginDetails
            return
        }
        throw error
    }
    
    func markUserAsLoggedIn() throws {
        guard let error = mockErrorToThrow else {
            guard let loginDetails = mockLoginDetails else {
                throw BaseError(
                    context: .database,
                    message: "No user is currently logged in.",
                    logger: LoggingServiceMock()
                )
            }
            loginDetails.isLoggedIn = true
            mockLoginDetails = loginDetails
            return
        }
        throw error
    }

    // MARK: - RealmRepositoring Conformance

    func save(_ entity: RealmLoginDetails) throws {
        guard let error = mockErrorToThrow else {
            mockLoginDetails = entity
            return
        }
        throw error
    }
    
    func save(_ entities: [RealmLoginDetails]) throws {
        guard let error = mockErrorToThrow else {
            if let lastEntity = entities.last {
                mockLoginDetails = lastEntity
            }
            return
        }
        throw error
    }
    
    func delete(_ entity: RealmLoginDetails) throws {
        guard let error = mockErrorToThrow else {
            mockLoginDetails = nil
            return
        }
        throw error
    }
    
    func delete(_ entities: [RealmLoginDetails]) throws {
        guard let error = mockErrorToThrow else {
            mockLoginDetails = nil
            return
        }
        throw error
    }
    
    func deleteAll() throws {
        guard let error = mockErrorToThrow else {
            mockLoginDetails = nil
            return
        }
        throw error
    }
    
    func getAll() throws -> [RealmLoginDetails] {
        guard let error = mockErrorToThrow else {
            if let details = mockLoginDetails {
                return [details]
            }
            return []
        }
        throw error
    }
    
    func getById(_ id: String) throws -> RealmLoginDetails? {
        guard let error = mockErrorToThrow else {
            return mockLoginDetails?.loginID == id ? mockLoginDetails : nil
        }
        throw error
    }
}

final class RealmCheckSumRepositoryMock: RealmCheckSumRepositoring {
    
    var mockCheckSumData: RealmCheckSumData? = nil
    var mockErrorToThrow: Error? = nil

    // MARK: - RealmCheckSumRepositoring Conformance

    func deleteUserSpecificCheckSums() throws {
        guard let error = mockErrorToThrow else {
            guard let checkSumData = mockCheckSumData else {
                print("No CheckSum data found to clear.")
                return
            }
            checkSumData.userPoints = ""
            checkSumData.rank = ""
            checkSumData.messages = ""
            checkSumData.events = ""
            print("User-specific checksums cleared, generic points checksum retained.")
            return
        }
        throw error
    }

    // MARK: - RealmRepositoring Conformance

    func save(_ entity: RealmCheckSumData) throws {
        guard let error = mockErrorToThrow else {
            mockCheckSumData = entity
            return
        }
        throw error
    }
    
    func save(_ entities: [RealmCheckSumData]) throws {
        guard let error = mockErrorToThrow else {
            if let lastEntity = entities.last {
                mockCheckSumData = lastEntity
            }
            return
        }
        throw error
    }
    
    func delete(_ entity: RealmCheckSumData) throws {
        guard let error = mockErrorToThrow else {
            mockCheckSumData = nil
            return
        }
        throw error
    }
    
    func delete(_ entities: [RealmCheckSumData]) throws {
        guard let error = mockErrorToThrow else {
            mockCheckSumData = nil
            return
        }
        throw error
    }
    
    func deleteAll() throws {
        guard let error = mockErrorToThrow else {
            mockCheckSumData = nil
            return
        }
        throw error
    }
    
    func getAll() throws -> [RealmCheckSumData] {
        guard let error = mockErrorToThrow else {
            if let data = mockCheckSumData {
                return [data]
            }
            return []
        }
        throw error
    }
    
    func getById(_ id: String) throws -> RealmCheckSumData? {
        guard let error = mockErrorToThrow else {
            return mockCheckSumData?.checkSumID == id ? mockCheckSumData : nil
        }
        throw error
    }
}

final class RealmUserCategoryRepositoryMock: RealmUserCategoryRepositoring {
    
    var mockCategoryData: RealmUserCategoryData? = nil
    var mockErrorToThrow: Error? = nil

    // MARK: - RealmRepositoring Conformance

    func save(_ entity: RealmUserCategoryData) throws {
        guard let error = mockErrorToThrow else {
            mockCategoryData = entity
            return
        }
        throw error
    }
    
    func save(_ entities: [RealmUserCategoryData]) throws {
        guard let error = mockErrorToThrow else {
            if let lastEntity = entities.last {
                mockCategoryData = lastEntity
            }
            return
        }
        throw error
    }
    
    func delete(_ entity: RealmUserCategoryData) throws {
        guard let error = mockErrorToThrow else {
            mockCategoryData = nil
            return
        }
        throw error
    }
    
    func delete(_ entities: [RealmUserCategoryData]) throws {
        guard let error = mockErrorToThrow else {
            mockCategoryData = nil
            return
        }
        throw error
    }
    
    func deleteAll() throws {
        guard let error = mockErrorToThrow else {
            mockCategoryData = nil
            return
        }
        throw error
    }
    
    func getAll() throws -> [RealmUserCategoryData] {
        guard let error = mockErrorToThrow else {
            if let data = mockCategoryData {
                return [data]
            }
            return []
        }
        throw error
    }
    
    func getById(_ id: String) throws -> RealmUserCategoryData? {
        guard let error = mockErrorToThrow else {
            return mockCategoryData?.dataID == id ? mockCategoryData : nil
        }
        throw error
    }
}

final class RealmUserRankRepositoryMock: RealmUserRankRepositoring {

    var mockRankData: RealmUserRankData? = nil
    var mockErrorToThrow: Error? = nil

    // MARK: - RealmRepositoring Conformance

    func save(_ entity: RealmUserRankData) throws {
        guard let error = mockErrorToThrow else {
            mockRankData = entity
            return
        }
        throw error
    }
    
    func save(_ entities: [RealmUserRankData]) throws {
        guard let error = mockErrorToThrow else {
            if let lastEntity = entities.last {
                mockRankData = lastEntity
            }
            return
        }
        throw error
    }
    
    func delete(_ entity: RealmUserRankData) throws {
        guard let error = mockErrorToThrow else {
            mockRankData = nil
            return
        }
        throw error
    }
    
    func delete(_ entities: [RealmUserRankData]) throws {
        guard let error = mockErrorToThrow else {
            mockRankData = nil
            return
        }
        throw error
    }
    
    func deleteAll() throws {
        guard let error = mockErrorToThrow else {
            mockRankData = nil
            return
        }
        throw error
    }
    
    func getAll() throws -> [RealmUserRankData] {
        guard let error = mockErrorToThrow else {
            if let data = mockRankData {
                return [data]
            }
            return []
        }
        throw error
    }
    
    func getById(_ id: String) throws -> RealmUserRankData? {
        guard let error = mockErrorToThrow else {
            return mockRankData?.dataID == id ? mockRankData : nil
        }
        throw error
    }
}

final class RealmUserPointRepositoryMock: RealmUserPointRepositoring {

    var mockUserPointData: RealmUserPointData? = nil
    var mockErrorToThrow: Error? = nil

    // MARK: - RealmRepositoring Conformance

    func save(_ entity: RealmUserPointData) throws {
        guard let error = mockErrorToThrow else {
            mockUserPointData = entity
            return
        }
        throw error
    }
    
    func save(_ entities: [RealmUserPointData]) throws {
        guard let error = mockErrorToThrow else {
            if let lastEntity = entities.last {
                mockUserPointData = lastEntity
            }
            return
        }
        throw error
    }
    
    func delete(_ entity: RealmUserPointData) throws {
        guard let error = mockErrorToThrow else {
            mockUserPointData = nil
            return
        }
        throw error
    }
    
    func delete(_ entities: [RealmUserPointData]) throws {
        guard let error = mockErrorToThrow else {
            mockUserPointData = nil
            return
        }
        throw error
    }
    
    func deleteAll() throws {
        guard let error = mockErrorToThrow else {
            mockUserPointData = nil
            return
        }
        throw error
    }
    
    func getAll() throws -> [RealmUserPointData] {
        guard let error = mockErrorToThrow else {
            if let data = mockUserPointData {
                return [data]
            }
            return []
        }
        throw error
    }
    
    func getById(_ id: String) throws -> RealmUserPointData? {
        guard let error = mockErrorToThrow else {
            return mockUserPointData?.dataID == id ? mockUserPointData : nil
        }
        throw error
    }
}

final class RealmGenericPointRepositoryMock: RealmGenericPointRepositoring {

    var mockGenericPointData: RealmGenericPointData? = nil
    var mockErrorToThrow: Error? = nil

    // MARK: - RealmRepositoring Conformance

    func save(_ entity: RealmGenericPointData) throws {
        guard let error = mockErrorToThrow else {
            mockGenericPointData = entity
            return
        }
        throw error
    }
    
    func save(_ entities: [RealmGenericPointData]) throws {
        guard let error = mockErrorToThrow else {
            if let lastEntity = entities.last {
                mockGenericPointData = lastEntity
            }
            return
        }
        throw error
    }
    
    func delete(_ entity: RealmGenericPointData) throws {
        guard let error = mockErrorToThrow else {
            mockGenericPointData = nil
            return
        }
        throw error
    }
    
    func delete(_ entities: [RealmGenericPointData]) throws {
        guard let error = mockErrorToThrow else {
            mockGenericPointData = nil
            return
        }
        throw error
    }
    
    func deleteAll() throws {
        guard let error = mockErrorToThrow else {
            mockGenericPointData = nil
            return
        }
        throw error
    }
    
    func getAll() throws -> [RealmGenericPointData] {
        guard let error = mockErrorToThrow else {
            if let data = mockGenericPointData {
                return [data]
            }
            return []
        }
        throw error
    }
    
    func getById(_ id: String) throws -> RealmGenericPointData? {
        guard let error = mockErrorToThrow else {
            return mockGenericPointData?.dataID == id ? mockGenericPointData : nil
        }
        throw error
    }
}

final class RealmScannedPointRepositoryMock: RealmScannedPointRepositoring {

    var mockScannedPoints: [RealmScannedPoint] = []
    var mockErrorToThrow: Error? = nil

    // MARK: - RealmScannedPointRepositoring Conformance

    func getScannedPoints() throws -> [ScannedPoint] {
        guard let error = mockErrorToThrow else {
            return mockScannedPoints.map { $0.scannedPoint() }
        }
        throw error
    }

    // MARK: - RealmRepositoring Conformance

    func save(_ entity: RealmScannedPoint) throws {
        guard let error = mockErrorToThrow else {
            mockScannedPoints.append(entity)
            return
        }
        throw error
    }
    
    func save(_ entities: [RealmScannedPoint]) throws {
        guard let error = mockErrorToThrow else {
            mockScannedPoints.append(contentsOf: entities)
            return
        }
        throw error
    }
    
    func delete(_ entity: RealmScannedPoint) throws {
        guard let error = mockErrorToThrow else {
            mockScannedPoints.removeAll { $0 == entity }
            return
        }
        throw error
    }
    
    func delete(_ entities: [RealmScannedPoint]) throws {
        guard let error = mockErrorToThrow else {
            mockScannedPoints.removeAll { entities.contains($0) }
            return
        }
        throw error
    }
    
    func deleteAll() throws {
        guard let error = mockErrorToThrow else {
            mockScannedPoints.removeAll()
            return
        }
        throw error
    }
    
    func getAll() throws -> [RealmScannedPoint] {
        guard let error = mockErrorToThrow else {
            return mockScannedPoints
        }
        throw error
    }
    
    func getById(_ id: String) throws -> RealmScannedPoint? {
        guard let error = mockErrorToThrow else {
            return mockScannedPoints.first { $0.pointID == id }
        }
        throw error
    }
}

final class RealmSponsorRepositoryMock: RealmSponsorRepositoring {

    var mockSponsorData: RealmSponsorData? = nil
    var mockErrorToThrow: Error? = nil

    // MARK: - RealmRepositoring Conformance

    func save(_ entity: RealmSponsorData) throws {
        guard let error = mockErrorToThrow else {
            mockSponsorData = entity
            return
        }
        throw error
    }
    
    func save(_ entities: [RealmSponsorData]) throws {
        guard let error = mockErrorToThrow else {
            if let lastEntity = entities.last {
                mockSponsorData = lastEntity
            }
            return
        }
        throw error
    }
    
    func delete(_ entity: RealmSponsorData) throws {
        guard let error = mockErrorToThrow else {
            mockSponsorData = nil
            return
        }
        throw error
    }
    
    func delete(_ entities: [RealmSponsorData]) throws {
        guard let error = mockErrorToThrow else {
            mockSponsorData = nil
            return
        }
        throw error
    }
    
    func deleteAll() throws {
        guard let error = mockErrorToThrow else {
            mockSponsorData = nil
            return
        }
        throw error
    }
    
    func getAll() throws -> [RealmSponsorData] {
        guard let error = mockErrorToThrow else {
            if let data = mockSponsorData {
                return [data]
            }
            return []
        }
        throw error
    }
    
    func getById(_ id: String) throws -> RealmSponsorData? {
        guard let error = mockErrorToThrow else {
            return mockSponsorData?.sponsorID == id ? mockSponsorData : nil
        }
        throw error
    }
}
