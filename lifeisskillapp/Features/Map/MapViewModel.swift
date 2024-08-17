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
    var points: [Point] { get }
    var region: MKCoordinateRegion { get }
    
    func onAppear()
}

final class MapViewModel: BaseClass, ObservableObject, MapViewModeling {
    
    typealias Dependencies = HasLoggerServicing & HasGameDataManager
    
    // MARK: - Private Properties
    
    private let logger: LoggerServicing
    private let gameDataManager: GameDataManaging
    private var shouldListenToGameDataChanges: Bool = false
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Public Properties
    
    @Published var points: [Point] = []
    @Published var region: MKCoordinateRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 0, longitude: 0),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    
    // MARK: - Initialization
    
    init(dependencies: Dependencies, points: [Point]? = nil) {
        self.logger = dependencies.logger
        self.gameDataManager = dependencies.gameDataManager
        
        super.init()
        guard let points else {
            self.shouldListenToGameDataChanges = true
            self.setupBindings()
            return
        }
        self.setPoints(points)
    }
    
    // MARK: - deinit
    
    deinit {
        cancellables.forEach { $0.cancel() }
    }
    
    // MARK: - Public Interface
    
    func onAppear() {
        Task {
            guard shouldListenToGameDataChanges else { return }
            await gameDataManager.fetchNewDataIfNeccessary(endpoint: .points)
        }
    }
    
    // MARK: - Private Helpers
    
    private func setPoints(_ points: [Point]) {
        Task { @MainActor [weak self] in
            self?.points = points
            if let firstPoint = points.first {
                self?.region = MKCoordinateRegion(
                    center: CLLocationCoordinate2D(latitude: firstPoint.location.latitude, longitude: firstPoint.location.longitude),
                    span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                )
            }
        }
    }
    
    private func setupBindings() {
        // TODO: implement subscribtion to generic point data changes
        /*
            .receive(on: DispatchQueue.main)
            .sink { [weak self] points in
                Task { [weak self] in
                    await self?.setPoints(points)
                }
            }
            .store(in: &cancellables)
         */
    }
}
