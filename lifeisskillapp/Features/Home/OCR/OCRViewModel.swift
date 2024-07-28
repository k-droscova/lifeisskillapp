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
        do {
            throw BaseError(context: .system, message: "Scanning failed", logger: logger)
        } catch {
            delegate?.onFailure(source: .text)
        }
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
        if scannedSignInfo.routeName != nil && scannedSignInfo.year != nil && scannedSignInfo.code != nil {
            sendScannedPointToAPI(sign: scannedSignInfo)
            dismissCamera()
        }
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
    
    func isSignTextValid(_ str: String) -> Bool {
        containsRouteName(str) || containsYear(str) || containsCode(str)
    }
    
    private func containsRouteName(_ text: String) -> Bool {
        possibleSignTitles.contains(text)
    }
    
    private func extractYear(from text: String) -> String? {
        let yearRegex = "\\b\\d{4}\\b"
        if let range = text.range(of: yearRegex, options: .regularExpression) {
            return String(text[range])
        }
        return nil
    }
    
    private func containsYear(_ text: String) -> Bool {
        return extractYear(from: text) != nil
    }
    
    private func extractCode(from text: String) -> String? {
        if let newCode = extractNewCode(from: text) {
            return newCode
        }
        return extractOldCode(from: text)
    }
    
    private func extractNewCode(from text: String) -> String? {
        let newCodeRegex = "\\b[A-Z]{2}\\d{3}[a-z]?\\b"
        if let range = text.range(of: newCodeRegex, options: .regularExpression) {
            let code = String(text[range])
            return String(code.prefix(5)) // Extract first 5 characters (2 letters and 3 numbers)
        }
        return nil
    }
    
    private func extractOldCode(from text: String) -> String? {
        let oldCodeRegex = "\\b\\d{4}/\\d+[a-z]*\\b"
        if let range = text.range(of: oldCodeRegex, options: .regularExpression) {
            return String(text[range])
        }
        return nil
    }
    
    private func containsCode(_ text: String) -> Bool {
        return extractCode(from: text) != nil
    }
    
    private func resetTouristSign() {
        scannedSignInfo.routeName = nil
        scannedSignInfo.code = nil
        scannedSignInfo.year = nil
    }
}
