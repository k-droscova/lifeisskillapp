//
//  HomeViewModel.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 24.07.2024.
//

import Foundation
import Observation

protocol HomeViewModeling: BaseClass, ObservableObject {
    var username: String { get }
    var isLoading: Bool { get }
    func onAppear()
    func loadWithNFC()
    func loadWithQRCode()
    func loadFromCamera()
    func dismissCamera()
    func showOnboarding()
}

/// The HomeViewModel class responsible for managing the home flow within the app.
final class HomeViewModel: BaseClass, ObservableObject, HomeViewModeling {
    struct Dependencies: HasLoggerServicing & HasLocationManager & HasScanningManager & HasUserLoginManager {
        let scanningManager: ScanningManaging
        let logger: LoggerServicing
        let locationManager: LocationManaging
        let userLoginManager: UserLoginDataManaging
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
    
    // MARK: - Published Properties
    
    @Published var username: String = ""
    @Published private(set) var isLoading: Bool = false
    
    init(dependencies: Dependencies, delegate: HomeFlowDelegate? = nil) {
        self.locationManager = dependencies.locationManager
        self.scanningManager = dependencies.scanningManager
        self.logger = dependencies.logger
        self.userDataManager = dependencies.userLoginManager
        self.delegate = delegate
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
                userLoginManager: self.userDataManager
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
                userLoginManager: self.userDataManager
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
                userLoginManager: self.userDataManager
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
