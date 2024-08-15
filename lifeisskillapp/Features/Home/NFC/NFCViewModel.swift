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
    typealias Dependencies = HasLoggerServicing & HasLocationManager & HasUserPointManager
    
    private weak var delegate: HomeFlowDelegate?
    private let logger: LoggerServicing
    private let locationManager: LocationManaging
    private let userPointManager: any UserPointManaging
    private var session: NFCReaderSession?
    
    public var isNfcAvailable: Bool { NFCNDEFReaderSession.readingAvailable }
    
    init(dependencies: Dependencies, delegate: HomeFlowDelegate?) {
        self.delegate = delegate
        self.logger = dependencies.logger
        self.locationManager = dependencies.locationManager
        self.userPointManager = dependencies.userPointManager
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
        delegatePointProcessingToUserPointManager(code)
        self.stopScanning()
    }
    
    private func delegatePointProcessingToUserPointManager(_ code: String) {
        let point = ScannedPoint(code: code, codeSource: .text, location: locationManager.location)
        userPointManager.handleScannedPoint(point)
    }
}

extension NfcViewModel: NFCNDEFReaderSessionDelegate {
    func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        logger.log(message: "ERROR: NFC Readed Failed with \(error.localizedDescription)")
        self.stopScanning()
        delegate?.onFailure(source: .nfc)
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
                handleProcessedCode(string.parseMessage())
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
