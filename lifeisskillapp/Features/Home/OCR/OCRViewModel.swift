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
    func categorizeText(_ text: String)
    func isSignTextValid(_ str: String) -> Bool
}

final class OcrViewModel: BaseClass, OcrViewModeling {
    typealias Dependencies = HasLoggerServicing & HasScanningManager & HasLocationManager
    
    // MARK: - Private Properties
    
    private weak var delegate: HomeFlowDelegate?
    private let logger: LoggerServicing
    private let scanningManager: ScanningManaging
    private let locationManager: LocationManaging
    private var scannedSignInfo = TouristSign()
    private let possibleSignTitles = ["PĚŠÍ TRASA KČT", "KČT"]
    
    // MARK: - Initialization
    
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
    
    func categorizeText(_ text: String) {
        if containsRouteName(text) {
            scannedSignInfo.routeName = text
        } else if let year = extractYear(from: text) {
            scannedSignInfo.year = year
        } else if let code = extractCode(from: text) {
            scannedSignInfo.code = code
        }
        
        // Check if all required fields are scanned
        if isSignComplete() {
            sendScannedPointToAPI(sign: scannedSignInfo)
            dismissCamera()
        }
    }
    
    func isSignTextValid(_ str: String) -> Bool {
        containsRouteName(str) || containsYear(str) || containsCode(str)
    }
    
    // MARK: - Private Helpers
    
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
    
    private func isSignValid(sign: TouristSign) -> Bool {
        // TODO: Handle validation logic (combination of title, year and code)
        true
    }
    
    private func isSignComplete() -> Bool {
        scannedSignInfo.routeName != nil && scannedSignInfo.year != nil && scannedSignInfo.code != nil
    }
    
    private func containsRouteName(_ text: String) -> Bool {
        possibleSignTitles.contains(text)
    }
    
    private func extractYear(from text: String) -> String? {
        let yearRegex = "\\b\\d{4}\\b"
        guard let range = text.range(of: yearRegex, options: .regularExpression) else {
            return nil
        }
        return String(text[range])
    }
    
    private func containsYear(_ text: String) -> Bool {
        extractYear(from: text) != nil
    }
    
    private func extractCode(from text: String) -> String? {
        if let newCode = extractNewCode(from: text) {
            return newCode
        }
        return extractOldCode(from: text)
    }
    
    private func extractNewCode(from text: String) -> String? {
        let newCodeRegex = "\\b[A-Z]{2}\\d{3}[a-z]?\\b"
        guard let range = text.range(of: newCodeRegex, options: .regularExpression) else {
            return nil
        }
        let code = String(text[range])
        return String(code.prefix(5)) // Extract first 5 characters (2 letters and 3 numbers)
    }
    
    private func extractOldCode(from text: String) -> String? {
        let oldCodeRegex = "\\b\\d{4}/\\d+[a-z]*\\b"
        guard let range = text.range(of: oldCodeRegex, options: .regularExpression) else {
            return nil
        }
        return String(text[range])
    }
    
    private func containsCode(_ text: String) -> Bool {
        extractCode(from: text) != nil
    }
}
