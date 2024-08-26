//
//  MapViewModel.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 17.08.2024.
//

import Foundation
import Combine
import MapKit

protocol MapViewModeling: BaseClass, ObservableObject {
    associatedtype settingBarVM: SettingsBarViewModeling
    var settingsViewModel: settingBarVM { get }
    var mapDelegate: MapViewFlowDelegate? { get set }
    var isLoading: Bool { get }
    var points: [GenericPoint] { get }
    var region: MKCoordinateRegion { get set }
    var selectedPoint: GenericPoint? { get set }
    var userLocation: UserLocation? { get }
    
    func onAppear()
    func onPointTapped(_ point: GenericPoint)
    func onMapTapped()
}

final class MapViewModel<settingBarVM: SettingsBarViewModeling>
: BaseClass, ObservableObject, MapViewModeling {
    typealias Dependencies = HasLoggerServicing & HasGameDataManager & HasGenericPointManager & SettingsBarViewModel.Dependencies & HasLocationManager
    
    // MARK: - Private Properties
    
    private let logger: LoggerServicing
    private var gameDataManager: GameDataManaging
    private let genericPointManager: any GenericPointManaging
    private let locationStorage: LocationManaging
    
    // MARK: - Public Properties

    internal weak var mapDelegate: MapViewFlowDelegate?
    var settingsViewModel: settingBarVM
    @Published var isLoading: Bool = false
    @Published var points: [GenericPoint] = []
    @Published var region: MKCoordinateRegion = MKCoordinateRegion()
    var selectedPoint: GenericPoint?
    var userLocation: UserLocation? { locationStorage.location }
    
    init(
        dependencies: Dependencies,
        mapDelegate: MapViewFlowDelegate?,
        settingsDelegate: SettingsBarFlowDelegate?
    ) {
        self.logger = dependencies.logger
        self.gameDataManager = dependencies.gameDataManager
        self.genericPointManager = dependencies.genericPointManager
        self.locationStorage = dependencies.locationManager
        self.settingsViewModel = settingBarVM.init(
            dependencies: dependencies,
            delegate: settingsDelegate
        )
        self.mapDelegate = mapDelegate
    }
    
    func onAppear() {
        Task { @MainActor [weak self] in
            guard let self = self else { return }
            self.isLoading = true
            await self.fetchData()
            configureMapRegion(location: self.userLocation)
            self.isLoading = false
        }
    }
    
    // MARK: - Private Helpers
    
    @MainActor
    private func fetchData() async {
        await gameDataManager.loadData(for: .genericPoints)
        await setupMapPoints()
    }
    
    @MainActor
    private func setupMapPoints() async {
        self.points = genericPointManager.getAll()
        print("MAP: Populated with \(self.points.count) points")
    }
}

/// Default implementation for map region configuration
extension MapViewModeling {
    
    func configureMapRegion(points: [GenericPoint]) {
        guard let point = points.first else {
            self.configureMapRegion(location: userLocation)
            return
        }
        self.region = MKCoordinateRegion(
            center: point.location.toCLLocation().coordinate,
            span: MKCoordinateSpan(
                latitudeDelta: MapConstants.latitudeDelta,
                longitudeDelta: MapConstants.longitudeDelta
            )
        )
    }
    
    func configureMapRegion(points: [Point]) {
        guard let point = points.first else {
            self.configureMapRegion(location: userLocation)
            return
        }
        self.region = MKCoordinateRegion(
            center: point.location.toCLLocation().coordinate,
            span: MKCoordinateSpan(
                latitudeDelta: MapConstants.latitudeDelta,
                longitudeDelta: MapConstants.longitudeDelta
            )
        )
    }
    
    func configureMapRegion(location: UserLocation? = nil) {
        guard let location else {
            self.configureDefaultMapRegion()
            return
        }
        self.region = MKCoordinateRegion(
            center: location.toCLLocation().coordinate,
            span: MKCoordinateSpan(
                latitudeDelta: MapConstants.latitudeDelta,
                longitudeDelta: MapConstants.longitudeDelta
            )
        )
    }
    
    private func configureDefaultMapRegion() {
        self.region = MKCoordinateRegion(
            center: MapConstants.defaultCoordinate.coordinate,
            span: MKCoordinateSpan(
                latitudeDelta: MapConstants.latitudeDelta,
                longitudeDelta: MapConstants.longitudeDelta
            )
        )
    }
}

extension MapViewModeling {
    func onPointTapped(_ point: GenericPoint) {
        print("DEBUG: onPointTapped called with point: \(point.pointName)")
        self.selectedPoint = point
        mapDelegate?.onPointTapped(for: point)
    }
    
    func onMapTapped() {
        print("DEBUG: onMapTapped called")
        self.selectedPoint = nil
        mapDelegate?.onMapTapped()
    }
}
