//
//  HomeViewModel.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 24.07.2024.
//

import Foundation
import Observation

/// A protocol that defines the required methods for the HomeViewModel.
protocol HomeViewModeling: NSObject {
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
final class HomeViewModel: NSObject, ObservableObject, HomeViewModeling {
    typealias Dependencies = HasLoggerServicing
    
    private weak var delegate: HomeFlowDelegate?
    private let logger: LoggerServicing
    
    /// Initializes the HomeViewModel.
    /// - Parameters:
    ///   - dependencies: The dependencies required by the view model.
    ///   - delegate: The delegate to notify about events.
    init(dependencies: Dependencies, delegate: HomeFlowDelegate? = nil) {
        self.logger = dependencies.logger
        self.delegate = delegate
    }
    
    // MARK: - NFC
    func loadWithNFC() {
        delegate?.loadFromNFC()
    }
    
    // MARK: - QR
    func loadWithQRCode() {
        delegate?.loadFromQR()
    }
    
    // MARK: - Camera
    func loadFromCamera() {
        delegate?.loadFromCamera()
    }
    
    func dismissCamera() {
        delegate?.dismissCamera()
    }
}
