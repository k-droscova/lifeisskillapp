//
//  NFCViewModel.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 26.07.2024.
//

import Foundation
import CoreNFC

protocol NfcViewModeling: BaseClass {
    func startScanning()
    func stopScanning()
}

final class NfcViewModel: BaseClass, NfcViewModeling {
    typealias Dependencies = HasLoggerServicing & HasLocationManager & HasGameDataManager
    
    private weak var delegate: HomeFlowDelegate?
    private let logger: LoggerServicing
    private let locationManager: LocationManaging
    private let gameDataManager: GameDataManaging
    private var session: NFCReaderSession?
    
    var isNfcAvailable: Bool { NFCNDEFReaderSession.readingAvailable }
    
    init(dependencies: Dependencies, delegate: HomeFlowDelegate?) {
        self.delegate = delegate
        self.logger = dependencies.logger
        self.locationManager = dependencies.locationManager
        self.gameDataManager = dependencies.gameDataManager
    }
    
    func startScanning() {
        guard isNfcAvailable else {
            delegate?.featureUnavailable(source: .nfc)
            return
        }
        logger.log(message: "Attempting to load point with NFC")
        locationManager.checkLocationAuthorization()
        session = NFCNDEFReaderSession(delegate: self, queue: DispatchQueue.main, invalidateAfterFirstRead: false)
        session?.alertMessage = NSLocalizedString("home.nfc.alert_message", comment: "")
        session?.begin()
    }
    
    func stopScanning() {
        session?.invalidate()
        session = nil
    }
    
    // MARK: - Private Helpers
    
    private func handleProcessedCode(_ code: String) {
        logger.log(message: "Point scanned from NFC: \(code)")
        locationManager.checkLocationAuthorization()
        delegatePointScanningToGameDataManager(code)
        self.stopScanning()
    }
    
    private func delegatePointScanningToGameDataManager(_ code: String) {
        Task { [weak self] in
            let point = ScannedPoint(code: code, codeSource: .nfc, location: self?.locationManager.location)
            await self?.gameDataManager.onPointScanned(point)
        }
    }
}

extension NfcViewModel: NFCNDEFReaderSessionDelegate {
    func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        if let nfcError = error as? NFCReaderError {
            switch nfcError.code {
            case .readerSessionInvalidationErrorUserCanceled:
                logger.log(message: "NFC session canceled by user.")
                break
            default:
                logger.log(message: "NFC session ended with error: \(nfcError.localizedDescription)")
            }
        }
        self.stopScanning()
    }
    
    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
        for message in messages {
            for record in message.records {
                guard let string = String(data: record.payload, encoding: .ascii) else {
                    continue
                }
                guard string.contains("Life is Skill") else {
                    continue
                }
                handleProcessedCode(string.parsedMessage)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                    session.invalidate()
                }
                return
            }
        }
        self.stopScanning()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.delegate?.onFailure(source: .nfc)
        }
    }
}
