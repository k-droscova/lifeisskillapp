//
//  HomeViewModel.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 24.07.2024.
//

import Foundation
import Observation

/// A protocol that defines the required methods for the HomeViewModel.
protocol HomeViewModeling: BaseClass {
    /// Initiates the process of loading with NFC.
    func loadWithNFC()
    
    /// Initiates the process of loading with QR code.
    func loadWithQRCode()
    
    /// Initiates the process of loading with the camera.
    func loadFromCamera()
    
    /// Dismisses the camera view.
    func dismissCamera()
    
    func showOnboarding()
}

/// The HomeViewModel class responsible for managing the home flow within the app.
final class HomeViewModel: BaseClass, ObservableObject, HomeViewModeling {
    struct Dependencies: HasLoggerServicing & HasLocationManager & HasScanningManager {
        let scanningManager: ScanningManaging
        let logger: LoggerServicing
        let locationManager: LocationManaging
    }
    
    // MARK: - Private Properties
    
    private weak var delegate: HomeFlowDelegate?
    private var nfcVM: NfcViewModeling?
    private var ocrVM: OcrViewModeling?
    private var qrVM: QRViewModeling?
    
    private let scanningManager: ScanningManaging
    private let logger: LoggerServicing
    private let locationManager: LocationManaging
    
    init(dependencies: Dependencies, delegate: HomeFlowDelegate? = nil) {
        self.locationManager = dependencies.locationManager
        self.scanningManager = dependencies.scanningManager
        self.logger = dependencies.logger
        self.delegate = delegate
    }
    
    // MARK: - NFC
    func loadWithNFC() {
        nfcVM = NfcViewModel(
            dependencies: Dependencies(
                scanningManager: self.scanningManager,
                logger: self.logger,
                locationManager: self.locationManager
            ),
            delegate: self.delegate
        )
        nfcVM?.startScanning()
    }
    
    // MARK: - QR
    func loadWithQRCode() {
        qrVM = QRViewModel(
            dependencies: Dependencies(
                scanningManager: self.scanningManager,
                logger: self.logger,
                locationManager: self.locationManager
            ),
            delegate: self.delegate
        )
        guard let qrVM else {
            logger.log(message: "ERROR: QR ViewModel Init Failed")
            return
        }
        delegate?.loadFromQR(viewModel: qrVM)
    }
    
    // MARK: - Camera
    func loadFromCamera() {
        ocrVM = OcrViewModel(
            dependencies: Dependencies(
                scanningManager: self.scanningManager,
                logger: self.logger,
                locationManager: self.locationManager
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
        logger.log(message: "Onboarding tapped")
    }
}
