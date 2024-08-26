//
//  HomeViewModel.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 24.07.2024.
//

import Foundation
import Observation

protocol HomeViewModeling: BaseClass, ObservableObject {
    associatedtype categorySelectorVM: CategorySelectorViewModeling
    associatedtype settingBarVM: SettingsBarViewModeling
    var username: String { get }
    var isLoading: Bool { get }
    var csViewModel: categorySelectorVM { get }
    var settingsViewModel: settingBarVM { get }
    func onAppear()
    func loadWithNFC()
    func loadWithQRCode()
    func loadFromCamera()
    func dismissCamera()
    func showOnboarding()
}

/// The HomeViewModel class responsible for managing the home flow within the app.
final class HomeViewModel<csVM: CategorySelectorViewModeling, settingBarVM: SettingsBarViewModeling>: BaseClass, ObservableObject, HomeViewModeling {
    struct Dependencies: HasLoggerServicing & HasLocationManager & HasGameDataManager & HasUserManager & SettingsBarViewModel.Dependencies {
        let gameDataManager: GameDataManaging
        let logger: LoggerServicing
        let locationManager: LocationManaging
        var userDefaultsStorage: UserDefaultsStoraging
        let userManager: UserManaging
        let networkMonitor: NetworkMonitoring
    }
    
    // MARK: - Private Properties
    
    private weak var delegate: HomeFlowDelegate?
    private var nfcVM: NfcViewModeling?
    private var ocrVM: OcrViewModeling?
    private var qrVM: QRViewModeling?
    
    private let gameDataManager: GameDataManaging
    private let logger: LoggerServicing
    private let locationManager: LocationManaging
    private var userDefaultsStorage: UserDefaultsStoraging
    private let userManager: UserManaging
    private let networkMonitor: NetworkMonitoring
    
    // MARK: - Public Properties
    
    @Published var username: String = ""
    @Published private(set) var isLoading: Bool = false
    var csViewModel: csVM
    var settingsViewModel: settingBarVM
    
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
        self.userDefaultsStorage = dependencies.userDefaultsStorage
        self.networkMonitor = dependencies.networkMonitor
        self.delegate = delegate
        self.csViewModel = categorySelectorVM
        self.settingsViewModel = settingBarVM.init(
            dependencies: dependencies,
            delegate: settingsDelegate
        )
    }
    
    // MARK: - Public Interface
    
    func onAppear() {
        Task { @MainActor [weak self] in
            self?.isLoading = true
            self?.username = self?.userManager.userName ?? ""
            self?.isLoading = false
        }
    }
    
    func loadWithNFC() {
        nfcVM = NfcViewModel(
            dependencies: Dependencies(
                gameDataManager: self.gameDataManager,
                logger: self.logger,
                locationManager: self.locationManager,
                userDefaultsStorage: self.userDefaultsStorage,
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
                userDefaultsStorage: self.userDefaultsStorage,
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
                userDefaultsStorage: self.userDefaultsStorage,
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
}
