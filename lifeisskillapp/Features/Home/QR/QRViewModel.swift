//
//  QRViewModel.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 29.07.2024.
//

import AVFoundation

protocol QRViewModeling: CameraViewModeling {
    var captureSession: AVCaptureSession? { get set }
    var previewLayer: AVCaptureVideoPreviewLayer? { get set }
    var isScannerSetup: Bool { get }
    
    func setUpScanner()
    func dismissScanner()
    func scanningFailed()
    func handleScannedQRCode(_ code: String)
    func startScanning()
    func stopScanning()
    func setupPreviewLayer()
}

final class QRViewModel: BaseClass, QRViewModeling, ObservableObject {
    typealias Dependencies = HasLoggerServicing & HasScanningManager & HasLocationManager
    
    // MARK: - Private Properties
    
    weak var delegate: HomeFlowDelegate?
    private let logger: LoggerServicing
    private let scanningManager: ScanningManaging
    private let locationManager: LocationManaging
    
    // MARK: - Public Properties
    
    var captureSession: AVCaptureSession?
    var previewLayer: AVCaptureVideoPreviewLayer?
    @Published var isFlashOn: Bool = false
    private(set) var isScannerSetup: Bool = false
    
    // MARK: - Initialization
    
    init(dependencies: Dependencies, delegate: HomeFlowDelegate?) {
        self.delegate = delegate
        self.logger = dependencies.logger
        self.scanningManager = dependencies.scanningManager
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
    
    func handleScannedQRCode(_ code: String) {
        locationManager.checkLocationAuthorization()
        let point = LoadPoint(code: code, codeSource: .text)
        Task { @MainActor [weak self] in
            do {
                try await self?.scanningManager.sendScannedPoint(point)
                self?.delegate?.onSuccess(source: .qr)
            } catch {
                self?.delegate?.onFailure(source: .qr)
            }
        }
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
            let string = stringValue.removingPercentEncoding ?? ""
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))

            if string.contains("lifeisskill.cz") {
                handleScannedQRCode(string.parseMessage())
            } else {
                scanningFailed()
                delegate?.onFailure(source: .qr)
            }
        }
    }
}
