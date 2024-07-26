//
//  NFCViewModel.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 26.07.2024.
//

import Foundation
import CoreNFC

protocol NfcViewModeling: NFCNDEFReaderSessionDelegate {
    func startScanning()
    func stopScanning()
}

final class NfcViewModel: NSObject, NfcViewModeling {
    typealias Dependencies = HasLoggerServicing & HasLocationManager & HasScanningManager
    
    private weak var delegate: HomeFlowDelegate?
    private let logger: LoggerServicing
    private let locationManager: LocationManaging
    private let scanningManager: ScanningManaging
    private var session: NFCReaderSession?
    
    init(dependencies: Dependencies, delegate: HomeFlowDelegate?) {
        self.delegate = delegate
        self.logger = dependencies.logger
        self.locationManager = dependencies.locationManager
        self.scanningManager = dependencies.scanningManager
    }
    
    func startScanning() {
        logger.log(message: "Attempting to load point with NFC")
        locationManager.checkLocationAuthorization()
        session = NFCNDEFReaderSession(delegate: self, queue: DispatchQueue.main, invalidateAfterFirstRead: false)
        session?.alertMessage = NSLocalizedString("home.nfc.alertMessage", comment: "")
        session?.begin()
    }
    
    func stopScanning() {
        session?.invalidate()
        session = nil
    }
    
    func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        do {
            throw BaseError(
                context: .system,
                message: error.localizedDescription,
                logger: logger
            )
        } catch {
            delegate?.onFailure(source: .nfc)
        }
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
                handleScannedPoint(string.parseMessage())
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                    session.invalidate()
                }
                return
            }
        }
        session.invalidate()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.delegate?.onFailure(source: .nfc)
        }
    }
    
    private func handleScannedPoint(_ pointID: String) {
        logger.log(message: "Point scanned from NFC: \(pointID)")
        let point = LoadPoint(code: pointID, codeSource: .nfc)
        Task {
            do {
                try await scanningManager.sendScannedPoint(point)
                delegate?.onSuccess(source: .nfc)
            } catch {
                delegate?.onFailure(source: .nfc)
            }
        }
    }
}
