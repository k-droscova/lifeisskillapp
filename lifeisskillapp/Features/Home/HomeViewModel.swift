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
    struct Dependencies: HasLoggerServicing & HasLocationManager & HasScanningManager & HasUserLoginManager & SettingsBarViewModel.Dependencies {
        let scanningManager: ScanningManaging
        let logger: LoggerServicing
        let locationManager: LocationManaging
        let userLoginManager: UserLoginDataManaging
        var userDefaultsStorage: UserDefaultsStoraging
        let userManager: UserManaging
        let networkMonitor: NetworkMonitoring
    }
    
    // MARK: - Private Properties
    
    private weak var delegate: HomeFlowDelegate?
    private var nfcVM: NfcViewModeling?
    private var ocrVM: OcrViewModeling?
    private var qrVM: QRViewModeling?
    
    private let scanningManager: ScanningManaging
    private let logger: LoggerServicing
    private let locationManager: LocationManaging
    private let userDataManager: UserLoginDataManaging
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
        self.scanningManager = dependencies.scanningManager
        self.logger = dependencies.logger
        self.userDataManager = dependencies.userLoginManager
        self.userDefaultsStorage = dependencies.userDefaultsStorage
        self.userManager = dependencies.userManager
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
            self?.username = self?.userDataManager.userName ?? ""
            self?.isLoading = false
        }
    }
    
    func loadWithNFC() {
        nfcVM = NfcViewModel(
            dependencies: Dependencies(
                scanningManager: self.scanningManager,
                logger: self.logger,
                locationManager: self.locationManager,
                userLoginManager: self.userDataManager,
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
                scanningManager: self.scanningManager,
                logger: self.logger,
                locationManager: self.locationManager,
                userLoginManager: self.userDataManager,
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
                scanningManager: self.scanningManager,
                logger: self.logger,
                locationManager: self.locationManager,
                userLoginManager: self.userDataManager,
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
