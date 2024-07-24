//
//  HomeViewModel.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 24.07.2024.
//

import Foundation
import CoreNFC
import Observation

protocol HomeViewModeling: NFCNDEFReaderSessionDelegate {
    func pointScanned(pointID: String, source: CodeSource)
    func loadWithNFC()
    func loadWithQRCode()
    func loadFromPhoto()
}

final class HomeViewModel: NSObject, HomeViewModeling, ObservableObject {
    typealias Dependencies = HasLoggerServicing & HasLocationManager
    
    private weak var delegate: HomeFlowDelegate?
    private var session: NFCReaderSession?
    private let locationManager: LocationManaging
    private let logger: LoggerServicing
    
    init(dependencies: Dependencies, delegate: HomeFlowDelegate? = nil) {
        self.locationManager = dependencies.locationManager
        self.logger = dependencies.logger
        self.delegate = delegate
    }
    
    func pointScanned(pointID: String, source: CodeSource) {
        logger.log(message: "Point scanned from \(source.rawValue): \(pointID)")
        delegate?.loadingSuccessNFC()
    }
    
    func loadWithNFC() {
        logger.log(message: "Attempting to load point with NFC")
        locationManager.checkLocationAuthorization()
        session = NFCNDEFReaderSession(delegate: self, queue: DispatchQueue.main, invalidateAfterFirstRead: false)
        session?.alertMessage = NSLocalizedString("home.nfc.alertMessage", comment: "")
        session?.begin()
    }
    
    func loadWithQRCode() {

    }
    
    func loadFromPhoto() {

    }
}

extension HomeViewModel {
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
    
    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
        for message in messages {
            for record in message.records {
                if let string = String(data: record.payload, encoding: .ascii) {
                    if string.contains("Life is Skill") {
                        pointScanned(pointID: string.parseMessage(), source: .nfc)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                            session.invalidate()
                        }
                        return
                    }
                }
            }
        }
        session.invalidate()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.delegate?.loadingFailureNFC()
        }
    }
}
