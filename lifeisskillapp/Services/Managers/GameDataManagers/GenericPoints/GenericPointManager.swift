//
//  GenericPointDataManager.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 18.07.2024.
//

import Foundation
import Combine

protocol HasGenericPointManager {
    var genericPointManager: any GenericPointManaging { get }
}

protocol GenericPointManaging: UserDataManaging where DataType == GenericPoint, DataContainer == GenericPointData {
    func sponsorImage(for sponsorId: String, width: Int, height: Int) async throws -> Data?
}

public final class GenericPointManager: BaseClass, GenericPointManaging {
    typealias Dependencies = HasLoggerServicing & HasUserDataAPIService & HasPersistentUserDataStoraging & HasNetworkMonitor
    
    // MARK: - Private Properties
    
    private var storage: PersistentUserDataStoraging
    private let logger: LoggerServicing
    private let userDataAPIService: UserDataAPIServicing
    private var _data: GenericPointData?
    
    internal let networkMonitor: NetworkMonitoring
    
    // MARK: - Public Properties
    
    var token: String? { storage.token }
    
    // MARK: - Initialization
    
    init(dependencies: Dependencies) {
        self.storage = dependencies.storage
        self.logger = dependencies.logger
        self.userDataAPIService = dependencies.userDataAPI
        self.networkMonitor = dependencies.networkMonitor
    }
    
    // MARK: - Public Interface
    
    func loadFromRepository() {
        Task { @MainActor [weak self] in
            do {
                try await self?.storage.loadFromRepository(for: .genericPoints)
                self?._data = try await self?.storage.genericPointData()
            } catch {
                self?.logger.log(message: "Unable to load generic points from storage")
            }
        }
    }
    
    func fetch(withToken token: String) async throws {
        logger.log(message: "Fetching generic points")
        let response = try await userDataAPIService.getPoints(baseURL: APIUrl.baseURL, userToken: token)
        try await storage.saveGenericPointData(response.data)
        _data = response.data
    }
    
    func getById(id: String) -> GenericPoint? {
        _data?.data.first { $0.id == id }
    }
    
    func getAll() -> [GenericPoint] {
        _data?.data ?? []
    }
    
    func onLogout() {
        _data = nil
    }
    
    func checkSum() -> String? {
        _data?.checkSum
    }
    
    // MARK: - Sponsor Image Management
    
    func sponsorImage(for sponsorId: String, width: Int, height: Int) async throws -> Data? {
        // First, try to retrieve the image from the storage
        if let existingImage = try await storage.sponsorImage(for: sponsorId) {
            return existingImage
        }
        // Fetch image from the remote API using the UserDataAPIService
        guard let token = token else {
            throw BaseError(
                context: .api,
                message: "No valid user token found",
                code: .general(.missingConfigItem),
                logger: logger
            )
        }
        let imageData = try await userDataAPIService.getSponsorImage(
            baseURL: APIUrl.baseURL,
            userToken: token,
            sponsorId: sponsorId,
            width: width,
            height: height
        )
        try await storage.saveSponsorImage(for: sponsorId, imageData: imageData)
        return imageData
    }
}
