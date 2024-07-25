//
//  HomeViewModel.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 24.07.2024.
//

import Foundation
import CoreNFC
import Observation

/// A protocol that defines the required methods for the HomeViewModel.
protocol HomeViewModeling: NFCNDEFReaderSessionDelegate {
    /// Called when a point is scanned. Sends the code to API.
    /// - Parameters:
    ///   - pointID: The ID of the scanned point.
    ///   - source: The source of the scanned point (QR, NFC, Text, Virtual).
    func pointScanned(pointID: String, source: CodeSource)
    
    // MARK: - NFC
    
    /// Initiates the process of loading with NFC.
    func loadWithNFC()
    
    // MARK: - QR
    
    /// Initiates the process of loading with QR code.
    func loadWithQRCode()
    
    // MARK: - Camera
    
    /// Initiates the process of loading with the camera.
    func loadFromCamera()
    
    /// Dismisses the camera view.
    func dismissCamera()
    
    /// Handles the failure of scanning.
    func scanningFailed()
    
    /// Called when a sign is successfully scanned.
    /// - Parameter sign: The scanned tourist sign.
    func signScanned(sign: TouristSign)
    
    /// Validates if the given text is part of a tourist sign.
    /// - Parameter str: The text to validate.
    /// - Returns: `true` if the text is valid; otherwise, `false`.
    func isSignTextValid(_ str: String) -> Bool
    
    /// Categorizes the given text as part of a tourist sign.
    /// - Parameter str: The text to categorize.
    func categorizeText(_ str: String)
    
    /// Handles the case when an unknown item is scanned.
    func unknownItem()
}

/// The HomeViewModel class responsible for managing the home flow within the app.
final class HomeViewModel: NSObject, HomeViewModeling, ObservableObject {
    typealias Dependencies = HasLoggerServicing & HasLocationManager
    
    private weak var delegate: HomeFlowDelegate?
    private var session: NFCReaderSession?
    private let locationManager: LocationManaging
    private let logger: LoggerServicing
    private let possibleSignTitles = ["PĚŠÍ TRASA KČT", "KČT"]
    private var scannedSignInfo = TouristSign()
    
    /// Initializes the HomeViewModel.
    /// - Parameters:
    ///   - dependencies: The dependencies required by the view model.
    ///   - delegate: The delegate to notify about events.
    init(dependencies: Dependencies, delegate: HomeFlowDelegate? = nil) {
        self.locationManager = dependencies.locationManager
        self.logger = dependencies.logger
        self.delegate = delegate
    }
    
    /// Called when a point is scanned.
    /// - Parameters:
    ///   - pointID: The ID of the scanned point.
    ///   - source: The source of the scanned point (QR, NFC, Text, Virtual).
    func pointScanned(pointID: String, source: CodeSource) {
        logger.log(message: "Point scanned from \(source.rawValue): \(pointID)")
        // TODO: send the point to API
        switch source {
        case .qr:
            delegate?.loadingSuccessQR()
        case .nfc:
            delegate?.loadingSuccessNFC()
        case .text:
            delegate?.loadingSuccessCamera()
        case .virtual:
            delegate?.loadingSuccessVirtual()
        }
    }
}

// MARK: - NFC
extension HomeViewModel {
    /// Initiates the process of loading with NFC.
    func loadWithNFC() {
        logger.log(message: "Attempting to load point with NFC")
        locationManager.checkLocationAuthorization()
        session = NFCNDEFReaderSession(delegate: self, queue: DispatchQueue.main, invalidateAfterFirstRead: false)
        session?.alertMessage = NSLocalizedString("home.nfc.alertMessage", comment: "")
        session?.begin()
    }
    
    /// Called when the NFC reader session is invalidated due to an error.
    /// - Parameters:
    ///   - session: The NFC reader session.
    ///   - error: The error that caused the invalidation.
    func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        do {
            throw BaseError(
                context: .system,
                message: error.localizedDescription,
                logger: logger
            )
        } catch {
            delegate?.loadingFailureNFC()
        }
    }
    
    /// Called when NFC NDEF messages are detected.
    /// - Parameters:
    ///   - session: The NFC reader session.
    ///   - messages: The detected NFC NDEF messages.
    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
        for message in messages {
            for record in message.records {
                // ensure correct format
                guard let string = String(data: record.payload, encoding: .ascii) else {
                    continue
                }
                // ensure that nfc is from LiS
                guard string.contains("Life is Skill") else {
                    continue
                }
                pointScanned(pointID: string.parseMessage(), source: .nfc)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                    session.invalidate()
                }
                return
            }
        }
        session.invalidate()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.delegate?.loadingFailureNFC()
        }
    }
}

// MARK: - QR
extension HomeViewModel {
    func loadWithQRCode() {
        // TODO: Implementation for QR code loading
    }
}

// MARK: - CAMERA
extension HomeViewModel {
    
    // MARK: - Public Interface
    
    /// Initiates the process of loading with the camera.
    func loadFromCamera() {
        logger.log(message: "Attempting to load point with camera")
        delegate?.loadFromCamera()
    }
    
    /// Dismisses the camera view.
    func dismissCamera() {
        delegate?.dismissCamera()
    }
    
    /// Handles the failure of scanning.
    func scanningFailed() {
        do {
            throw BaseError(
                context: .system,
                message: "Scanning failed",
                logger: logger)
        } catch {
            delegate?.loadingFailureCamera()
        }
    }
    
    /// Called when a sign is successfully scanned.
    /// - Parameter sign: The scanned tourist sign.
    func signScanned(sign: TouristSign) {
        guard isSignValid(sign: sign), let code = sign.code else {
            do {
                throw BaseError(
                    context: .system,
                    message: "Invalid sign",
                    logger: logger
                )
            } catch {
                self.resetTouristSign()
                delegate?.invalidSign()
                return
            }
        }
        logger.log(message: "Valid Sign \(code)")
        pointScanned(pointID: code, source: .text)
        self.resetTouristSign()
        self.dismissCamera()
        delegate?.loadingSuccessCamera()
    }
    
    /// Validates if the given text is part of a tourist sign.
    /// - Parameter str: The text to validate.
    /// - Returns: `true` if the text is valid; otherwise, `false`.
    func isSignTextValid(_ str: String) -> Bool {
        return containsRouteName(str) || containsYear(str) || containsCode(str)
    }
    
    /// Categorizes the given text as part of a tourist sign.
    /// - Parameter text: The text to categorize.
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
            signScanned(sign: scannedSignInfo)
            dismissCamera()
        }
    }
    
    /// Handles the case when an unknown item is scanned.
    func unknownItem() {
        logger.log(message:"Trying to scan unknown item")
    }
    
    // MARK: - Private helpers
    
    /// Validates if the given sign is valid.
    /// - Parameter sign: The tourist sign to validate.
    /// - Returns: `true` if the sign is valid; otherwise, `false`.
    private func isSignValid(sign: TouristSign) -> Bool {
        // TODO: HANDLE LOGIC OF VALID YEAR/NAME/CODE COMBINATIONS
        true
    }
    
    /// Checks if the given text contains a route name.
    /// - Parameter text: The text to check.
    /// - Returns: `true` if the text contains a route name; otherwise, `false`.
    private func containsRouteName(_ text: String) -> Bool {
        possibleSignTitles.contains(text)
    }
    
    /// Extracts the year from the given text.
    /// - Parameter text: The text to extract the year from.
    /// - Returns: The extracted year if found; otherwise, `nil`.
    private func extractYear(from text: String) -> String? {
        let yearRegex = "\\b\\d{4}\\b"
        if let range = text.range(of: yearRegex, options: .regularExpression) {
            return String(text[range])
        }
        return nil
    }
    
    /// Checks if the given text contains a year.
    /// - Parameter text: The text to check.
    /// - Returns: `true` if the text contains a year; otherwise, `false`.
    private func containsYear(_ text: String) -> Bool {
        return extractYear(from: text) != nil
    }
    
    /// Extracts the code from the given text.
    /// - Parameter text: The text to extract the code from.
    /// - Returns: The extracted code if found; otherwise, `nil`.
    private func extractCode(from text: String) -> String? {
        if let newCode = extractNewCode(from: text) {
            return newCode
        }
        return extractOldCode(from: text)
    }
    
    /// Extracts the new code format from the given text.
    /// - Parameter text: The text to extract the new code from.
    /// - Returns: The extracted new code if found; otherwise, `nil`.
    private func extractNewCode(from text: String) -> String? {
        let newCodeRegex = "\\b[A-Z]{2}\\d{3}[a-z]?\\b"
        if let range = text.range(of: newCodeRegex, options: .regularExpression) {
            let code = String(text[range])
            return String(code.prefix(5)) // Extract first 5 characters (2 letters and 3 numbers)
        }
        return nil
    }
    
    /// Extracts the old code format from the given text.
    /// - Parameter text: The text to extract the old code from.
    /// - Returns: The extracted old code if found; otherwise, `nil`.
    private func extractOldCode(from text: String) -> String? {
        // TODO: ask about the specific old format as well as what part of the code we are interested in
        let oldCodeRegex = "\\b\\d{4}/\\d+[a-z]*\\b"
        if let range = text.range(of: oldCodeRegex, options: .regularExpression) {
            return String(text[range])
        }
        return nil
    }
    
    /// Checks if the given text contains a code.
    /// - Parameter text: The text to check.
    /// - Returns: `true` if the text contains a code; otherwise, `false`.
    private func containsCode(_ text: String) -> Bool {
        return extractCode(from: text) != nil
    }
    
    /// Resets the scanned tourist sign information.
    private func resetTouristSign() {
        scannedSignInfo.routeName = nil
        scannedSignInfo.code = nil
        scannedSignInfo.year = nil
    }
}
