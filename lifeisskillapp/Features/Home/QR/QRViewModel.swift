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
    
    func setUpScanner()
    func dismissScanner()
    func scanningFailed()
    func handleProcessedCode(_ code: String)
    func startScanning()
    func stopScanning()
    func setupPreviewLayer()
}

final class QRViewModel: BaseClass, QRViewModeling, ObservableObject {
    typealias Dependencies = HasLoggerServicing & HasUserPointManager & HasLocationManager
    
    // MARK: - Private Properties
    
    weak var delegate: HomeFlowDelegate?
    private let logger: LoggerServicing
    private let userPointManager: any UserPointManaging
    private let locationManager: LocationManaging
    
    // MARK: - Public Properties
    
    var captureSession: AVCaptureSession?
    var previewLayer: AVCaptureVideoPreviewLayer?
    @Published var isFlashOn: Bool = false
    
    // MARK: - Initialization
    
    init(dependencies: Dependencies, delegate: HomeFlowDelegate?) {
        self.delegate = delegate
        self.logger = dependencies.logger
        self.userPointManager = dependencies.userPointManager
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
        delegatePointProcessingToUserPointManager(code)
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
    }
    
    private func nulifyReferences() {
        captureSession = nil
        previewLayer = nil
    }
    
    private func delegatePointProcessingToUserPointManager(_ code: String) {
        let point = ScannedPoint(code: code, codeSource: .qr, location: locationManager.location)
        userPointManager.handleScannedPoint(point)
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
                handleProcessedCode(string.parseMessage())
            } else {
                scanningFailed()
            }
        }
    }
}
