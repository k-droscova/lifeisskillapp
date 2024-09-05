//
//  PointsViewModel.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 05.08.2024.
//

import Foundation
import Combine
import MapKit

protocol PointsViewModeling: BaseClass, ObservableObject, MapViewModeling where settingBarVM: SettingsBarViewModeling {
    associatedtype CategorySelectorVM: CategorySelectorViewModeling
    
    var csViewModel: CategorySelectorVM { get }
    var settingsViewModel: settingBarVM { get }
    
    // Loading state
    var isLoading: Bool { get }
    
    // View state
    var isMapButtonPressed: Bool { get set }
    
    // User information
    var username: String { get }
    var totalPoints: Int { get }
    var userGender: UserGender { get }
    
    // Points information
    var categoryPoints: [Point] { get }
    
    // Actions
    func onAppear()
    func onDisappear()
    func mapButtonPressed()
    func listButtonPressed()
    func showPointOnMap(point: Point)
}

final class PointsViewModel<csVM: CategorySelectorViewModeling, settingBarVM: SettingsBarViewModeling>: BaseClass, ObservableObject, PointsViewModeling {
    typealias Dependencies = HasLoggerServicing & HasUserCategoryManager & HasUserPointManager & HasGameDataManager & SettingsBarViewModel.Dependencies & HasGenericPointManager & HasLocationManager
    
    // MARK: - Private Properties
    
    private weak var delegate: PointsFlowDelegate?
    private let logger: LoggerServicing
    private var gameDataManager: GameDataManaging
    private let userCategoryManager: any UserCategoryManaging
    private let userPointManager: any UserPointManaging
    private let userManager: UserManaging
    private let genericPointManager: any GenericPointManaging
    private var selectedCategory: UserCategory? {
        getSelectedCategory()
    }
    private var cancellables = Set<AnyCancellable>()
    private let locationStorage: LocationManaging
    private var mapPoints: [Point] = []
    
    // MARK: - Public Properties
    
    // generic
    var csViewModel: csVM
    var settingsViewModel: settingBarVM
    @Published var isLoading: Bool = false
    @Published var isMapButtonPressed: Bool = false
    // point list view
    @Published var username: String = ""
    @Published var userGender: UserGender
    @Published var totalPoints: Int = 0
    @Published var categoryPoints: [Point] = []
    // map view
    internal weak var mapDelegate: MapViewFlowDelegate?
    @Published var points: [GenericPoint] = []
    @Published var region: MKCoordinateRegion = MKCoordinateRegion()
    var selectedPoint: GenericPoint?
    var userLocation: UserLocation? { locationStorage.location }
    
    // MARK: - Initialization
    
    init(
        dependencies: Dependencies,
        categorySelectorVM: csVM,
        delegate: PointsFlowDelegate?,
        mapDelegate: MapViewFlowDelegate?,
        settingsDelegate: SettingsBarFlowDelegate?
    ) {
        self.logger = dependencies.logger
        self.userCategoryManager = dependencies.userCategoryManager
        self.userPointManager = dependencies.userPointManager
        self.gameDataManager = dependencies.gameDataManager
        self.userManager = dependencies.userManager
        self.genericPointManager = dependencies.genericPointManager
        self.locationStorage = dependencies.locationManager
        self.csViewModel = categorySelectorVM
        self.settingsViewModel = settingBarVM.init(
            dependencies: dependencies,
            delegate: settingsDelegate
        )
        self.userGender = userManager.loggedInUser?.sex ?? .male
        self.delegate = delegate
        self.mapDelegate = mapDelegate
        super.init()
        self.setupBindings()
    }
    
    // MARK: - Deinitialization
    
    deinit {
        cancellables.forEach { $0.cancel() }
    }
    
    // MARK: Public Interface
    
    func onAppear() {
        Task { @MainActor [weak self] in
            guard let self = self else { return }
            self.isLoading = true
            self.username = self.userManager.loggedInUser?.nick ?? ""
            await self.fetchData()
            if self.isMapButtonPressed {
                await self.setupMapPoints(self.mapPoints)
            }
            self.isLoading = false
        }
    }
    
    func onDisappear() {
        Task { @MainActor [weak self] in
            self?.totalPoints = 0
        }
    }
    
    func mapButtonPressed() {
        guard !self.isMapButtonPressed else { return }
        logger.log(message: "map button pressed")
        Task { @MainActor [weak self] in
            guard let self = self else { return }
            await self.setupMapPoints(self.categoryPoints)
            self.configureMapRegion(points: self.categoryPoints)
            self.isMapButtonPressed = true
        }
    }
    
    func listButtonPressed() {
        guard self.isMapButtonPressed else { return }
        logger.log(message: "list button pressed")
        Task { @MainActor [weak self] in
            self?.isMapButtonPressed = false
            self?.selectedPoint = nil
            self?.points = []
        }
    }
    
    func showPointOnMap(point: Point) {
        guard !self.isMapButtonPressed else { return }
        logger.log(message: "showing map for point: \(point.name)")
        Task { @MainActor [weak self] in
            await self?.setupMapPoints([point])
            self?.configureMapRegion(points: [point])
            self?.isMapButtonPressed = true
        }
    }
    
    // MARK: Private Helpers
    
    private func setupBindings() {
        print("BINDINGS: Setting up bindings in PointsViewModel")
        userCategoryManager.selectedCategoryPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] category in
                print("BINDINGS: Received new category in PointsViewModel: \(String(describing: category?.id))")
                Task { [weak self] in
                    guard let self = self else { return }
                    await self.getSelectedCategoryPoints()
                    if self.isMapButtonPressed {
                        await self.setupMapPoints(self.categoryPoints)
                    }
                }
            }
            .store(in: &cancellables)
    }
    
    private func getSelectedCategory() -> UserCategory? {
        userCategoryManager.selectedCategory
    }
    
    @MainActor
    private func getSelectedCategoryPoints() async {
        let data = userPointManager.getAll()
        guard data.isNotEmpty else {
            logger.log(message: "No user point data available")
            delegate?.onNoDataAvailable()
            return
        }
        
        guard let selectedCategory = selectedCategory else {
            logger.log(message: "No selected category found")
            delegate?.selectCategoryPrompt()
            return
        }
        
        let userPoints = userPointManager.getPoints(byCategory: selectedCategory.id)
        guard userPoints.isNotEmpty else {
            logger.log(message: "No point data found for the selected category")
            delegate?.onNoDataAvailable()
            self.categoryPoints = []
            self.totalPoints = 0
            return
        }
        
        self.categoryPoints = userPoints.map { Point(from: $0) }
        self.totalPoints = userPointManager.getTotalPoints(byCategory: selectedCategory.id)
    }
    
    @MainActor
    private func fetchData() async {
        await gameDataManager.loadData(for: .userPoints)
        await getSelectedCategoryPoints()
    }
    
    @MainActor
    private func setupMapPoints(_ points: [Point]) async {
        self.mapPoints = points
        self.points = points.compactMap { point in
            return genericPointManager.getById(id: point.pointId)
        }
        print("MAP: Populated with \(self.points.count) points")
    }
}
