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
    var csViewModel: CategorySelectorVM { get }
    
    // Loading state
    var isLoading: Bool { get }
    
    // View state
    var isMapShown: Bool { get set }
    
    // User information
    var username: String { get }
    var totalPoints: Int { get }
    var userGender: UserGender { get }
    
    // Points information
    var categoryPoints: [Point] { get }
    
    // Actions
    func onAppear()
    func mapButtonPressed()
    func listButtonPressed()
    func showPointOnMap(point: Point)
}

final class PointsViewModel<csVM: CategorySelectorViewModeling>: BaseClass, ObservableObject, PointsViewModeling {
    typealias Dependencies = HasLoggerServicing & HasUserCategoryManager & HasUserPointManager & HasGameDataManager & HasUserLoginManager
    
    // MARK: - Private Properties
    
    private weak var delegate: PointsFlowDelegate?
    private let logger: LoggerServicing
    private var gameDataManager: GameDataManaging
    private let userCategoryManager: any UserCategoryManaging
    private let userPointManager: any UserPointManaging
    private let userDataManager: any UserLoginDataManaging
    private var selectedCategory: UserCategory? {
        getSelectedCategory()
    }
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Public Properties
    
    @Published var isLoading: Bool = false
    @Published var isMapShown: Bool = false
    @Published var username: String = ""
    @Published var userGender: UserGender
    @Published var totalPoints: Int = 0
    @Published var categoryPoints: [Point] = []
    var csViewModel: csVM
    
    // MARK: - Initialization
    
    init(dependencies: Dependencies, categorySelectorVM: csVM, delegate: PointsFlowDelegate?) {
        self.logger = dependencies.logger
        self.userCategoryManager = dependencies.userCategoryManager
        self.userPointManager = dependencies.userPointManager
        self.gameDataManager = dependencies.gameDataManager
        self.userDataManager = dependencies.userLoginManager
        self.csViewModel = categorySelectorVM
        self.userGender = userDataManager.data?.user.sex ?? .male
        self.delegate = delegate
        super.init()
        self.setupBindings()
    }
    
    // MARK: Public Interface
    
    func onAppear() {
        Task { @MainActor [weak self] in
            self?.isLoading = true
            self?.username = self?.userDataManager.userName ?? ""
            await self?.fetchData()
            self?.isLoading = false
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
        
        // Find the user points for the selected category
        let userPoints = userPointManager.getPoints(byCategory: selectedCategory.id)
        
        guard userPoints.isNotEmpty else {
            logger.log(message: "No point data found for the selected category")
            delegate?.onNoDataAvailable()
            await MainActor.run {
                self.categoryPoints = []
                self.totalPoints = 0
            }
            return
        }
        await MainActor.run {
            self.categoryPoints = userPoints.map { Point(from: $0) }
            self.totalPoints = userPointManager.getTotalPoints(byCategory: selectedCategory.id)
        }
    }
    
    @MainActor
    private func fetchData() async {
        do {
            try await userCategoryManager.fetch()
            await gameDataManager.fetchNewDataIfNeccessary(endpoint: .userpoints)
            await getSelectedCategoryPoints()
        } catch {
            delegate?.onError(error)
        }
    }
    
    private func showCategoryPointsOnMap() {
        logger.log(message: "showing all category points on map")
    }
}
