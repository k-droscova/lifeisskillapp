//
//  OCRViewModel.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 26.07.2024.
//

import Foundation

protocol OcrViewModeling: BaseClass {
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
    private var scannedSignInfo = TouristSign()
    
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
        _ = LogEvent(
            message: "Error: Scanning Failure",
            context: .system,
            severity: .error,
            logger: logger
        )
        delegate?.onFailure(source: .text)
    }
    
    func handleProcessedCode(_ code: String) {
        scannedSignInfo.code = code
        sendScannedPointToAPI(sign: scannedSignInfo)
        dismissCamera()
    }
    
    func extractCode(from text: String) -> String? {
        if let newCode = extractNewCode(from: text) {
            return newCode
        }
        return extractOldCode(from: text)
    }
    
    private func sendScannedPointToAPI(sign: TouristSign) {
        locationManager.checkLocationAuthorization()
        guard let code = sign.code else { return }
        let point = LoadPoint(code: code, codeSource: .text)
        Task { @MainActor in
            do {
                try await scanningManager.sendScannedPoint(point)
                self.delegate?.onSuccess(source: .text)
            } catch {
                self.delegate?.onFailure(source: .text)
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
