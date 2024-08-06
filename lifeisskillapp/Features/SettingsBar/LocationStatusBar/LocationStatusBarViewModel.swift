//
//  LocationStatusBarViewModel.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 06.08.2024.
//

import Foundation
import Combine

protocol LocationStatusBarViewModeling: BaseClass, ObservableObject {
    init(dependencies: HasUserDefaultsStorage & HasLoggers & HasLocationManager)
    var userLocation: UserLocation? { get }
    var appVersion: String { get }
    var isOnline: Bool { get set }
    var isGpsOk: Bool { get set }
}

final class LocationStatusBarViewModel: BaseClass, ObservableObject, LocationStatusBarViewModeling {
    typealias Dependencies = HasUserDefaultsStorage & HasLoggers & HasLocationManager
    
    // MARK: - Private properties
    
    private let userDefaultsStorage: UserDefaultsStoraging
    private let logger: LoggerServicing
    private let locationManager: LocationManaging
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Public Properties
    
    @Published var appVersion: String = "DEBUG"
    @Published var isOnline: Bool = true // TODO: implement networkManager to gather info whether I am online
    @Published var isGpsOk: Bool = true
    @Published var userLocation: UserLocation?
    
    // MARK: - Initialization
    
    required init(dependencies: Dependencies) {
        logger = dependencies.logger
        userDefaultsStorage = dependencies.userDefaultsStorage
        locationManager = dependencies.locationManager
        
        super.init()
        self.setupBindings()
    }
    
    // MARK: - Private Helpers
    
    private func setupBindings() {
        Task { [weak self] in
            guard let stream = self?.locationManager.gpsStream else { return }
            for await _ in stream {
                guard let self = self else { return }
                await self.getGpsStatus()
            }
        }
        
        Task { [weak self] in
            guard let self = self else { return }
            for await location in self.userDefaultsStorage.locationStream {
                await self.updateLocation(location)
            }
        }
    }
    
    private func getGpsStatus() async {
        await MainActor.run {
            self.isGpsOk = locationManager.gpsStatus
        }
    }
    
    private func updateLocation(_ location: UserLocation?) async {
        await MainActor.run {
            self.userLocation = location
        }
    }
}
