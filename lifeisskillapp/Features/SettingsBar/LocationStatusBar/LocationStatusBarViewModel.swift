//
//  LocationStatusBarViewModel.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 06.08.2024.
//

import Foundation
import Combine

protocol LocationStatusBarViewModeling: BaseClass, ObservableObject {
    init(dependencies: HasLoggers & HasLocationManager & HasNetworkMonitor)
    var userLocation: UserLocation? { get }
    var appVersion: String { get }
    var isOnline: Bool { get set }
    var isGpsOk: Bool { get set }
}

final class LocationStatusBarViewModel: BaseClass, ObservableObject, LocationStatusBarViewModeling {
    typealias Dependencies = HasLoggers & HasLocationManager & HasNetworkMonitor
    
    // MARK: - Private properties
    
    private let logger: LoggerServicing
    private let locationManager: LocationManaging
    private let networkMonitor: NetworkMonitoring
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Public Properties
    
    @Published var appVersion: String = "DEBUG" // TODO: fetch from environment
    @Published var isOnline: Bool = true
    @Published var isGpsOk: Bool = true
    @Published var userLocation: UserLocation? = nil
    
    // MARK: - Initialization
    
    required init(dependencies: Dependencies) {
        logger = dependencies.logger
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
        locationManager.gpsStatusPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isGpsOk in
                self?.updateGpsStatus(status: isGpsOk)
            }
            .store(in: &cancellables)
        
        // Location Binding
        locationManager.locationPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] location in
                self?.updateLocation(location)
            }
            .store(in: &cancellables)
        
        // Network Status Binding
        networkMonitor.onlineStatusPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isOnline in
                self?.updateOnlineStatus(status: isOnline)
            }
            .store(in: &cancellables)
    }
    
    private func updateGpsStatus(status: Bool) {
        Task { @MainActor [weak self] in
            self?.isGpsOk = status
        }
    }
    
    private func updateLocation(_ location: UserLocation?) {
        Task { @MainActor [weak self] in
            self?.userLocation = location
        }
    }
    
    private func updateOnlineStatus(status: Bool) {
        Task { @MainActor [weak self] in
            self?.isOnline = status
        }
    }
}
