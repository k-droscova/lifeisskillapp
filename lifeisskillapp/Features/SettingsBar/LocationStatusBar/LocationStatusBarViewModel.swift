//
//  LocationStatusBarViewModel.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 06.08.2024.
//

import Foundation
import Combine

protocol LocationStatusBarViewModeling: BaseClass, ObservableObject {
    init(dependencies: HasUserDefaultsStorage & HasLoggers & HasLocationManager & HasNetworkMonitor)
    var userLocation: UserLocation? { get }
    var appVersion: String { get }
    var isOnline: Bool { get set }
    var isGpsOk: Bool { get set }
}

final class LocationStatusBarViewModel: BaseClass, ObservableObject, LocationStatusBarViewModeling {
    typealias Dependencies = HasUserDefaultsStorage & HasLoggers & HasLocationManager & HasNetworkMonitor
    
    // MARK: - Private properties
    
    private let userDefaultsStorage: UserDefaultsStoraging
    private let logger: LoggerServicing
    private let locationManager: LocationManaging
    private let networkMonitor: NetworkMonitoring
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Public Properties
    
    @Published var appVersion: String = "DEBUG" // TODO: store real up version in user defaults
    @Published var isOnline: Bool = true
    @Published var isGpsOk: Bool = true
    @Published var userLocation: UserLocation?
    
    // MARK: - Initialization
    
    required init(dependencies: Dependencies) {
        logger = dependencies.logger
        userDefaultsStorage = dependencies.userDefaultsStorage
        locationManager = dependencies.locationManager
        networkMonitor = dependencies.networkMonitor
        
        super.init()
        self.setupBindings()
    }
    
    // MARK: - deinit
    
    deinit {
        cancellables.forEach { $0.cancel() }
    }
    
    // MARK: - Private Helpers
    
    private func setupBindings() {
        // GPS Status Binding
        Task { [weak self] in
            guard let stream = self?.locationManager.gpsStream else { return }
            for await _ in stream {
                guard let self = self else { return }
                self.getGpsStatus()
            }
        }
        
        // Location Binding
        Task { [weak self] in
            guard let self = self else { return }
            for await location in self.userDefaultsStorage.locationStream {
                self.updateLocation(location)
            }
        }
        
        // Network Status Binding
        networkMonitor.onlineStatusPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isOnline in
                self?.updateOnlineStatus(status: isOnline)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Private Helpers
    
    private func getGpsStatus() {
        Task { @MainActor in
            self.isGpsOk = locationManager.gpsStatus
        }
    }
    
    private func updateLocation(_ location: UserLocation?) {
        Task { @MainActor in
            self.userLocation = location
        }
    }
    
    private func updateOnlineStatus(status: Bool) {
        Task { @MainActor in
            self.isOnline = status
        }
    }
}
