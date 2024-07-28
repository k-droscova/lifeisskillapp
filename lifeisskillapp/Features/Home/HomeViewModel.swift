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
    
    private weak var delegate: HomeFlowDelegate?
    private let logger: LoggerServicing
    private let nfcVM: NfcViewModeling
    private let ocrVM: OcrViewModeling
    
    /// Initializes the HomeViewModel.
    /// - Parameters:
    ///   - dependencies: The dependencies required by the view model.
    ///   - delegate: The delegate to notify about events.
    init(dependencies: Dependencies, delegate: HomeFlowDelegate? = nil) {
        self.logger = dependencies.logger
        self.delegate = delegate
        self.nfcVM = NfcViewModel(dependencies: dependencies, delegate: delegate)
        self.ocrVM = OcrViewModel(dependencies: dependencies, delegate: delegate)
    }
    
    // MARK: - NFC
    func loadWithNFC() {
        nfcVM.startScanning()
    }
    
    // MARK: - QR
    func loadWithQRCode() {
        delegate?.loadFromQR()
    }
    
    // MARK: - Camera
    func loadFromCamera() {
        delegate?.loadFromCamera(viewModel: self.ocrVM)
    }
    
    func dismissCamera() {
        delegate?.dismissCamera()
    }
}
