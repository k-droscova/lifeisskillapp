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
    var closestVirtualPoint: GenericPoint? { get }
    var closestVirtualPointPublisher: AnyPublisher<GenericPoint?, Never> { get }
    func sponsorImage(for sponsorId: String, width: Int, height: Int) async throws -> Data?
}

public final class GenericPointManager: BaseClass, GenericPointManaging {
    typealias Dependencies = HasLoggerServicing & HasUserDataAPIService & HasPersistentUserDataStoraging & HasNetworkMonitor & HasLocationManager
    
    // MARK: - Private Properties
    
    private var storage: PersistentUserDataStoraging
    private let logger: LoggerServicing
    private let userDataAPIService: UserDataAPIServicing
    private let locationManager: LocationManaging
    private var _data: GenericPointData?
    private var cancellables = Set<AnyCancellable>()
    private let closestVirtualPointSubject = CurrentValueSubject<GenericPoint?, Never>(nil)
    
    internal let networkMonitor: NetworkMonitoring
    
    // MARK: - Public Properties
    
    var token: String? { storage.token }
    var closestVirtualPoint: GenericPoint? { closestVirtualPointSubject.value }
    var closestVirtualPointPublisher: AnyPublisher<GenericPoint?, Never> {
        closestVirtualPointSubject.eraseToAnyPublisher()
    }
    
    // MARK: - Initialization
    
    init(dependencies: Dependencies) {
        self.storage = dependencies.storage
        self.logger = dependencies.logger
        self.userDataAPIService = dependencies.userDataAPI
        self.locationManager = dependencies.locationManager
        self.networkMonitor = dependencies.networkMonitor
        
        super.init()
        self.setupBindings()
    }
    
    // MARK: - deinit
    
    deinit {
        cancellables.forEach { $0.cancel() }
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
    
    // MARK: - Private Helpers
    
    private func setupBindings() {
        locationManager.locationPublisher
            .compactMap { $0 } // Filter out nil values
            .sink { [weak self] userLocation in
                self?.updateClosestVirtualPoint(for: userLocation)
            }
            .store(in: &cancellables)
    }
    
    private func updateClosestVirtualPoint(for userLocation: UserLocation) {
        guard let closestPoint = findClosestVirtualPoint(for: userLocation) else { return }
        print("DEBUG: closest virtual point is \(userLocation.distance(to: closestPoint.location))")
        // Check if it's within 100 meters
        guard userLocation.distance(to: closestPoint.location) < MapConstants.virtualPointDistance else {
            closestVirtualPointSubject.send(nil)
            return
        }
        closestVirtualPointSubject.send(closestPoint)
    }
    
    private func findClosestVirtualPoint(for userLocation: UserLocation) -> GenericPoint? {
        guard let points = _data?.data else { return nil }
        return points
            .filter { $0.pointType == .virtual }
            .min(by: { userLocation.distance(to: $0.location) < userLocation.distance(to: $1.location) })
    }
}
