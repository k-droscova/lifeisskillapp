//
//  QRViewModel.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 29.07.2024.
//

import AVFoundation
import UIKit

protocol QRViewModeling: CameraViewModeling {
    var isScannerSetup: Bool { get }
    
    func setUpScanner()
    func dismissScanner()
    func scanningFailed()
    func handleProcessedCode(_ code: String)
    func startScanning()
    func stopScanning()
    func setupPreviewLayer()
    func attachPreviewLayer(to view: UIView)
}

final class QRViewModel: BaseClass, QRViewModeling, ObservableObject {
    typealias Dependencies = HasLoggerServicing & HasGameDataManager & HasLocationManager
    
    // MARK: - Private Properties
    
    weak var delegate: HomeFlowDelegate?
    private let logger: LoggerServicing
    private let gameDataManager: GameDataManaging
    private let locationManager: LocationManaging
    private var captureSession: AVCaptureSession?
    private var previewLayer: AVCaptureVideoPreviewLayer?
    
    // MARK: - Public Properties
    
    @Published var isFlashOn: Bool = false
    private(set) var isScannerSetup: Bool = false
    
    // MARK: - Initialization
    
    init(dependencies: Dependencies, delegate: HomeFlowDelegate?) {
        self.delegate = delegate
        self.logger = dependencies.logger
        self.gameDataManager = dependencies.gameDataManager
        self.locationManager = dependencies.locationManager
        super.init()
        setUpScanner()
    }
    
    // MARK: - Public Interface
    
    func dismissScanner() {
        stopScanning()
        nulifyReferences()
        delegate?.dismissQR()
    }
    
    func scanningFailed() {
        stopScanning()
        nulifyReferences()
        logger.log(message: "ERROR: QR Scanning Failure")
        delegate?.onFailure(source: .qr)
    }
    
    func handleProcessedCode(_ code: String) {
        locationManager.checkLocationAuthorization()
        delegatePointScanningToGameDataManager(code)
    }
    
    func startScanning() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            if let captureSession = self?.captureSession, !captureSession.isRunning {
                captureSession.startRunning()
            }
        }
    }
    
    func stopScanning() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            if let captureSession = self?.captureSession, captureSession.isRunning {
                captureSession.stopRunning()
            }
            self?.isScannerSetup = false
        }
    }
    
    func setupPreviewLayer() {
        if let captureSession = captureSession {
            previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            previewLayer?.videoGravity = .resizeAspectFill
        }
    }
    
    func setUpScanner() {
        captureSession = AVCaptureSession()
        
        guard let captureSession = captureSession,
              let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
            return
        }
        
        do {
            let videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
            if captureSession.canAddInput(videoInput) {
                captureSession.addInput(videoInput)
            } else {
                return
            }
        } catch {
            return
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        if captureSession.canAddOutput(metadataOutput) {
            captureSession.addOutput(metadataOutput)
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            return
        }
        isScannerSetup = true
    }
    
    func attachPreviewLayer(to view: UIView) {
        guard captureSession != nil else {
            scanningFailed()
            return
        }
        if let previewLayer = previewLayer {
            previewLayer.frame = view.bounds
            view.layer.addSublayer(previewLayer)
        } else {
            scanningFailed()
        }
    }
    
    private func nulifyReferences() {
        captureSession = nil
        previewLayer = nil
    }
    
    private func delegatePointScanningToGameDataManager(_ code: String) {
        Task { [weak self] in
            let point = ScannedPoint(code: code, codeSource: .qr, location: self?.locationManager.location)
            await self?.gameDataManager.onPointScanned(point)
        }
    }
}

extension QRViewModel: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        stopScanning()
        
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            let string = stringValue.removingPercentEncoding ?? ""
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            
            if string.contains("lifeisskill.cz") {
                handleProcessedCode(string.parsedMessage)
            } else {
                scanningFailed()
            }
        }
    }
}
