//
//  OCRViewModel.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 26.07.2024.
//

import Foundation
import AVFoundation

protocol OcrViewModeling: CameraViewModeling {
    var captureSession: AVCaptureSession? { get }
    var previewLayer: AVCaptureVideoPreviewLayer? { get set }
    func dismissCamera()
    func scanningFailed()
    func handleProcessedCode(_ code: String)
    func extractCode(from text: String) -> String?
}

final class OcrViewModel: BaseClass, OcrViewModeling {
    typealias Dependencies = HasLoggerServicing & HasGameDataManager & HasLocationManager
    
    private weak var delegate: HomeFlowDelegate?
    private let logger: LoggerServicing
    private let gameDataManager: GameDataManaging
    private let locationManager: LocationManaging
    
    // MARK: - Public Properties
    
    private(set) var captureSession: AVCaptureSession?
    var previewLayer: AVCaptureVideoPreviewLayer?
    @Published var isFlashOn: Bool = false
    
    init(dependencies: Dependencies, delegate: HomeFlowDelegate?) {
        self.delegate = delegate
        self.logger = dependencies.logger
        self.locationManager = dependencies.locationManager
        self.gameDataManager = dependencies.gameDataManager
    }
    
    // MARK: - Public Interface
    
    func dismissCamera() {
        delegate?.dismissCamera()
    }
    
    func scanningFailed() {
        logger.log(message: "ERROR: OCR Scanning Failure")
        delegate?.onFailure(source: .text)
    }
    
    func handleProcessedCode(_ code: String) {
        locationManager.checkLocationAuthorization()
        delegatePointScanningToGameDataManager(code)
        dismissCamera()
    }
    
    func extractCode(from text: String) -> String? {
        guard let newCode = extractNewCode(from: text) else {
            return nil
        }
        return newCode
    }
    
    private func delegatePointScanningToGameDataManager(_ code: String) {
        Task { [weak self] in
            let point = ScannedPoint(code: code, codeSource: .text, location: self?.locationManager.location)
            await self?.gameDataManager.onPointScanned(point)
        }
    }
    
    private func extractNewCode(from text: String) -> String? {
        let newCodeRegex = "\\b[A-Z]{2}\\d{3}[a-z]?\\b"
        guard let range = text.range(of: newCodeRegex, options: .regularExpression) else {
            return nil
        }
        let code = String(text[range])
        return String(code.prefix(5))
    }
    
    // MARK: - Old Codes are not supported
    private func extractOldCode(from text: String) -> String? {
        let oldCodeRegex = "\\b\\d{4}/\\d+[a-z]*\\b"
        guard let range = text.range(of: oldCodeRegex, options: .regularExpression) else {
            return nil
        }
        return String(text[range])
    }
}
