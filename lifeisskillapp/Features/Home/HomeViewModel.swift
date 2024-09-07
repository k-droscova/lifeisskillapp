//
//  HomeViewModel.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 24.07.2024.
//

import Foundation
import Observation
import Combine

protocol HomeViewModeling: BaseClass, ObservableObject {
    associatedtype categorySelectorVM: CategorySelectorViewModeling
    associatedtype settingBarVM: SettingsBarViewModeling
    var username: String { get }
    var isLoading: Bool { get }
    var isVirtualAvailable: Bool { get }
    var csViewModel: categorySelectorVM { get }
    var settingsViewModel: settingBarVM { get }
    func onAppear()
    func loadWithNFC()
    func loadWithQRCode()
    func loadFromCamera()
    func dismissCamera()
    func loadVirtual()
    func showOnboarding()
}

/// The HomeViewModel class responsible for managing the home flow within the app.
final class HomeViewModel<csVM: CategorySelectorViewModeling, settingBarVM: SettingsBarViewModeling>: BaseClass, ObservableObject, HomeViewModeling {
    struct Dependencies: HasLoggerServicing & HasLocationManager & HasGameDataManager & HasUserManager & SettingsBarViewModel.Dependencies {
        let gameDataManager: GameDataManaging
        let logger: LoggerServicing
        let locationManager: LocationManaging
        let userManager: UserManaging
        let networkMonitor: NetworkMonitoring
    }
    
    // MARK: - Private Properties
    
    private weak var delegate: HomeFlowDelegate?
    private var nfcVM: NfcViewModeling?
    private var ocrVM: OcrViewModeling?
    private var qrVM: QRViewModeling?
    private var cancellables = Set<AnyCancellable>()
    
    private let gameDataManager: GameDataManaging
    private let logger: LoggerServicing
    private let locationManager: LocationManaging
    private let userManager: UserManaging
    private let networkMonitor: NetworkMonitoring
    
    // MARK: - Public Properties
    
    @Published var username: String = ""
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var isVirtualAvailable: Bool = false
    var csViewModel: csVM
    var settingsViewModel: settingBarVM
    
    // MARK: - Initialization
    
    init(
        dependencies: Dependencies,
        categorySelectorVM: csVM,
        delegate: HomeFlowDelegate? = nil,
        settingsDelegate: SettingsBarFlowDelegate?
    ) {
        self.locationManager = dependencies.locationManager
        self.gameDataManager = dependencies.gameDataManager
        self.logger = dependencies.logger
        self.userManager = dependencies.userManager
        self.networkMonitor = dependencies.networkMonitor
        self.delegate = delegate
        self.csViewModel = categorySelectorVM
        self.settingsViewModel = settingBarVM.init(
            dependencies: dependencies,
            delegate: settingsDelegate
        )
        
        super.init()
        setupBindings()
    }
    
    // MARK: - Public Interface
    
    func onAppear() {
        Task { @MainActor [weak self] in
            self?.isLoading = true
            self?.username = self?.userManager.loggedInUser?.nick ?? ""
            self?.isLoading = false
        }
    }
    
    func loadWithNFC() {
        nfcVM = NfcViewModel(
            dependencies: Dependencies(
                gameDataManager: self.gameDataManager,
                logger: self.logger,
                locationManager: self.locationManager,
                userManager: self.userManager,
                networkMonitor: self.networkMonitor
            ),
            delegate: self.delegate
        )
        nfcVM?.startScanning()
    }
    
    func loadWithQRCode() {
        qrVM = QRViewModel(
            dependencies: Dependencies(
                gameDataManager: self.gameDataManager,
                logger: self.logger,
                locationManager: self.locationManager,
                userManager: self.userManager,
                networkMonitor: self.networkMonitor
            ),
            delegate: self.delegate
        )
        guard let qrVM else {
            logger.log(message: "ERROR: QR ViewModel Init Failed")
            return
        }
        delegate?.loadFromQR(viewModel: qrVM)
    }
    
    func loadFromCamera() {
        ocrVM = OcrViewModel(
            dependencies: Dependencies(
                gameDataManager: self.gameDataManager,
                logger: self.logger,
                locationManager: self.locationManager,
                userManager: self.userManager,
                networkMonitor: self.networkMonitor
            ),
            delegate: self.delegate
        )
        guard let ocrVM else {
            logger.log(message: "ERROR: OCR ViewModel Init Failed")
            return
        }
        delegate?.loadFromCamera(viewModel: ocrVM)
    }
    
    func dismissCamera() {
        delegate?.dismissCamera()
    }
    
    func showOnboarding() {
        delegate?.showOnboarding()
    }
    
    func loadVirtual() {
        Task { @MainActor [weak self] in
            await self?.gameDataManager.processVirtual(location: self?.locationManager.location)
        }
    }
    
    // MARK: - Private Helpers
    
    private func setupBindings() {
        gameDataManager.isVirtualAvailablePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isAvailable in
                self?.isVirtualAvailable = isAvailable
            }
            .store(in: &cancellables)
    }
}
