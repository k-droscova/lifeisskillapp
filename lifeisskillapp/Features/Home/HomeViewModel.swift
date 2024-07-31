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
}

/// The HomeViewModel class responsible for managing the home flow within the app.
final class HomeViewModel: BaseClass, ObservableObject, HomeViewModeling {
    typealias Dependencies = HasLoggerServicing & HasLocationManager & HasScanningManager
    struct HomeDependencies: Dependencies {
        let scanningManager: ScanningManaging
        let logger: LoggerServicing
        let locationManager: LocationManaging
    }
    
    // MARK: - Private Properties
    
    private weak var delegate: HomeFlowDelegate?
    private let dependencies: HomeDependencies
    private var nfcVM: NfcViewModeling?
    private var ocrVM: OcrViewModeling?
    private var qrVM: QRViewModeling?
    
    init(dependencies: Dependencies, delegate: HomeFlowDelegate? = nil) {
        self.dependencies = HomeDependencies(
            scanningManager: dependencies.scanningManager,
            logger: dependencies.logger,
            locationManager: dependencies.locationManager
        )
        self.delegate = delegate
    }
    
    // MARK: - NFC
    func loadWithNFC() {
        nfcVM = NfcViewModel(dependencies: self.dependencies, delegate: self.delegate)
        nfcVM?.startScanning()
    }
    
    // MARK: - QR
    func loadWithQRCode() {
        qrVM = QRViewModel(dependencies: self.dependencies, delegate: self.delegate)
        guard let qrVM else {
            dependencies.logger.log(message: "ERROR: QR ViewModel Init Failed")
            return
        }
        delegate?.loadFromQR(viewModel: qrVM)
    }
    
    // MARK: - Camera
    func loadFromCamera() {
        ocrVM = OcrViewModel(dependencies: self.dependencies, delegate: self.delegate)
        guard let ocrVM else {
            dependencies.logger.log(message: "ERROR: OCR ViewModel Init Failed")
            return
        }
        delegate?.loadFromCamera(viewModel: ocrVM)
    }
    
    func dismissCamera() {
        delegate?.dismissCamera()
    }
}
