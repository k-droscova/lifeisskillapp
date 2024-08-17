//
//  OCRViewModel.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 26.07.2024.
//

import Foundation
import AVFoundation

protocol OcrViewModeling: CameraViewModeling {
    var captureSession: AVCaptureSession? { get set }
    var previewLayer: AVCaptureVideoPreviewLayer? { get set }
    func dismissCamera()
    func scanningFailed()
    func handleProcessedCode(_ code: String)
    func extractCode(from text: String) -> String?
}

final class OcrViewModel: BaseClass, OcrViewModeling {
    typealias Dependencies = HasLoggerServicing & HasScanningManager & HasLocationManager
    
    private weak var delegate: HomeFlowDelegate?
    private let logger: LoggerServicing
    private let scanningManager: ScanningManaging
    private let locationManager: LocationManaging
    
    // MARK: - Public Properties
    
    var captureSession: AVCaptureSession?
    var previewLayer: AVCaptureVideoPreviewLayer?
    @Published var isFlashOn: Bool = false
    
    init(dependencies: Dependencies, delegate: HomeFlowDelegate?) {
        self.delegate = delegate
        self.logger = dependencies.logger
        self.locationManager = dependencies.locationManager
        self.scanningManager = dependencies.scanningManager
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
        sendScannedPointToAPI(code)
        dismissCamera()
    }
    
    func extractCode(from text: String) -> String? {
        if let newCode = extractNewCode(from: text) {
            return newCode
        }
        return extractOldCode(from: text)
    }
    
    private func sendScannedPointToAPI(_ code: String) {
        locationManager.checkLocationAuthorization()
        let point = LoadPoint(code: code, codeSource: .text)
        Task { @MainActor [weak self] in
            do {
                try await self?.scanningManager.sendScannedPoint(point)
                self?.delegate?.onSuccess(source: .text)
            } catch {
                self?.delegate?.onFailure(source: .text)
            }
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
    
    private func extractOldCode(from text: String) -> String? {
        let oldCodeRegex = "\\b\\d{4}/\\d+[a-z]*\\b"
        guard let range = text.range(of: oldCodeRegex, options: .regularExpression) else {
            return nil
        }
        return String(text[range])
    }
}