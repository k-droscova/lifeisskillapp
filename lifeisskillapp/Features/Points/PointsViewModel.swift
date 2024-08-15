//
//  PointsViewModel.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 05.08.2024.
//

import Foundation
import Combine

protocol PointsViewModeling: BaseClass, ObservableObject {
    associatedtype CategorySelectorVM: CategorySelectorViewModeling
    associatedtype settingBarVM: SettingsBarViewModeling
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
    typealias Dependencies = HasLoggerServicing & HasUserCategoryManager & HasUserPointManager & HasGameDataManager & HasUserManager & SettingsBarViewModel.Dependencies
    
    // MARK: - Private Properties
    
    private weak var delegate: PointsFlowDelegate?
    private let logger: LoggerServicing
    private var gameDataManager: GameDataManaging
    private let userCategoryManager: any UserCategoryManaging
    private let userPointManager: any UserPointManaging
    private let userManager: UserManaging
    private var selectedCategory: UserCategory? {
        getSelectedCategory()
    }
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Public Properties
    
    @Published var isLoading: Bool = false
    @Published var isMapButtonPressed: Bool = false
    @Published var username: String = ""
    @Published var userGender: UserGender
    @Published var totalPoints: Int = 0
    @Published var categoryPoints: [Point] = []
    var csViewModel: csVM
    var settingsViewModel: settingBarVM
    
    // MARK: - Initialization
    
    init(
        dependencies: Dependencies,
        categorySelectorVM: csVM,
        delegate: PointsFlowDelegate?,
        settingsDelegate: SettingsBarFlowDelegate?
    ) {
        self.logger = dependencies.logger
        self.userCategoryManager = dependencies.userCategoryManager
        self.userPointManager = dependencies.userPointManager
        self.gameDataManager = dependencies.gameDataManager
        self.userManager = dependencies.userManager
        self.csViewModel = categorySelectorVM
        self.settingsViewModel = settingBarVM.init(
            dependencies: dependencies,
            delegate: settingsDelegate
        )
        self.userGender = userManager.userGender ?? .male
        self.delegate = delegate
        super.init()
        self.setupBindings()
    }
    
    // MARK: - Deinitialization
    
    deinit {
        cancellables.forEach { $0.cancel() }
        logger.log(message: "PointsViewModel deinitialized and cancellables invalidated")
    }
    
    // MARK: Public Interface
    
    func onAppear() {
        Task { @MainActor [weak self] in
            self?.isLoading = true
            self?.username = self?.userManager.userName ?? ""
            await self?.fetchData()
            self?.isLoading = false
        }
    }
    
    func onDisappear() {
        Task { @MainActor [weak self] in
            self?.totalPoints = 0
        }
    }
    
    func mapButtonPressed() {
        logger.log(message: "map button pressed")
        self.showCategoryPointsOnMap()
    }
    
    func listButtonPressed() {
        logger.log(message: "list button pressed")
    }
    
    func showPointOnMap(point: Point) {
        logger.log(message: "showing map for point: \(point.name)")
    }
    
    // MARK: Private Helpers
    
    private func setupBindings() {
        print("BINDINGS: Setting up bindings in PointsViewModel")
        userCategoryManager.selectedCategoryPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] category in
                print("BINDINGS: Received new category in PointsViewModel: \(String(describing: category?.id))")
                Task { [weak self] in
                    await self?.getSelectedCategoryPoints()
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
        await gameDataManager.loadData(for: .userpoints)
        await getSelectedCategoryPoints()
    }
    
    private func showCategoryPointsOnMap() {
        logger.log(message: "showing all category points on map")
    }
}
