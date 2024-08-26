//
//  CameraViewModeling.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 29.07.2024.
//

import Foundation
import AVFoundation

protocol CameraViewModeling: BaseClass {
    var isFlashOn: Bool { get set }
    func toggleFlash()
}

extension CameraViewModeling {

    func toggleFlash() {
        var device: AVCaptureDevice?

        if #available(iOS 17, *) {
            device = AVCaptureDevice.userPreferredCamera
        } else {
            let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(
                deviceTypes: [
                    .builtInTripleCamera,
                    .builtInDualWideCamera,
                    .builtInUltraWideCamera,
                    .builtInWideAngleCamera,
                    .builtInTrueDepthCamera
                ],
                mediaType: .video,
                position: .back
            )
            device = deviceDiscoverySession.devices.first
        }

        guard let device else {
            print("No suitable camera device found.")
            return
        }

        if device.hasTorch && device.isTorchAvailable {
            do {
                try device.lockForConfiguration()
                if device.torchMode == .on {
                    device.torchMode = .off
                } else {
                    try device.setTorchModeOn(level: AVCaptureDevice.maxAvailableTorchLevel)
                }
                device.unlockForConfiguration()
                DispatchQueue.main.async {
                    self.isFlashOn = (device.torchMode == .on)
                }
            } catch {
                print("Failed to configure the torch: \(error)")
            }
        } else {
            print("Torch is not available on this device.")
        }
    }
}
