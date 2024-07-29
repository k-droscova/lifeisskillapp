//
//  QRViewModel.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 29.07.2024.
//

import AVFoundation

protocol QRViewModeling: BaseClass {
    func dismissScanner()
    func scanningFailed()
    func handleScannedQRCode(_ code: String)
}

final class QRViewModel: BaseClass, ObservableObject, QRViewModeling {
    typealias Dependencies = HasLoggerServicing & HasScanningManager & HasLocationManager
    
    // MARK: - Private Properties
    
    private weak var delegate: HomeFlowDelegate?
    private let logger: LoggerServicing
    private let scanningManager: ScanningManaging
    private let locationManager: LocationManaging
    @Published var scannedCode: String?
    private var captureSession: AVCaptureSession?
    private var previewLayer: AVCaptureVideoPreviewLayer?
    
    // MARK: - Initialization
    
    init(dependencies: Dependencies, delegate: HomeFlowDelegate?) {
        self.delegate = delegate
        self.logger = dependencies.logger
        self.scanningManager = dependencies.scanningManager
        self.locationManager = dependencies.locationManager
        super.init()
        setupScanner()
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
        do {
            throw BaseError(context: .system, message: "Scanning failed", logger: logger)
        } catch {
            delegate?.onFailure(source: .qr)
        }
    }
    
    func handleScannedQRCode(_ code: String) {
        // Handle the scanned QR code, e.g., send to server
        stopScanning()
        nulifyReferences()
        delegate?.onSuccess(source: .qr)
    }
    
    // MARK: - Private Helpers
        
    private func setupScanner() {
        captureSession = AVCaptureSession()
        
        guard let captureSession = captureSession,
              let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
            scanningFailed()
            return
        }
        
        do {
            let videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
            if captureSession.canAddInput(videoInput) {
                captureSession.addInput(videoInput)
            } else {
                scanningFailed()
                return
            }
        } catch {
            scanningFailed()
            return
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        if captureSession.canAddOutput(metadataOutput) {
            captureSession.addOutput(metadataOutput)
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            scanningFailed()
            return
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer?.videoGravity = .resizeAspectFill
        startScanning()
    }
    
    private func startScanning() {
        if let captureSession = captureSession, !captureSession.isRunning {
            captureSession.startRunning()
        }
    }
    
    private func stopScanning() {
        if let captureSession = captureSession, captureSession.isRunning {
            captureSession.stopRunning()
        }
    }
    
    private func nulifyReferences() {
        captureSession = nil
        previewLayer = nil
    }
}

extension QRViewModel: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        stopScanning()
        
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            handleScannedQRCode(stringValue)
        }
    }
}
