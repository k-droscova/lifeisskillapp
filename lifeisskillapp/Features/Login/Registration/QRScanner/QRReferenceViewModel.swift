//
//  QRReferenceViewModel.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 04.09.2024.
//

import AVFoundation
import UIKit

final class QRReferenceViewModel: BaseClass, QRViewModeling, ObservableObject {
    // MARK: - Dependencies
    weak var delegate: RegistrationFlowDelegate?
    private let logger: LoggerServicing
    
    // MARK: - Public Properties
    var captureSession: AVCaptureSession?
    var previewLayer: AVCaptureVideoPreviewLayer?
    @Published var isFlashOn: Bool = false
    var isScannerSetup: Bool = false
    
    // MARK: - Initialization
    init(logger: LoggerServicing, delegate: RegistrationFlowDelegate?) {
        self.logger = logger
        self.delegate = delegate
        super.init()
        setUpScanner()
    }
    
    // MARK: - Public Methods
    func dismissScanner() {
        stopScanning()
        nulifyReferences()
        delegate?.dismissQR()
    }
    
    func scanningFailed() {
        stopScanning()
        nulifyReferences()
        logger.log(message: "ERROR: QR Scanning Failure")
        delegate?.scanningQRDidFail()
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
    
    func handleProcessedCode(_ code: String) {
        if let referenceInfo = code.reference {
            delegate?.scanningQRDidSucceed(referenceInfo)
        } else {
            scanningFailed()
        }
    }
    
    // MARK: - Helper Methods
    
    private func nulifyReferences() {
        captureSession = nil
        previewLayer = nil
    }
}

extension QRReferenceViewModel: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        stopScanning()
        
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            let string = stringValue.removingPercentEncoding.emptyIfNil
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            handleProcessedCode(string)
        }
    }
}
