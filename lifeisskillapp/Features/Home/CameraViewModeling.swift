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
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            appDependencies.logger.log(message: "flash tapped")
            guard let device = AVCaptureDevice.default(for: .video), device.hasTorch else {
                appDependencies.logger.log(message: "Device has no Torch")
                return
            }
            do {
                try device.lockForConfiguration()
                DispatchQueue.main.async {
                    if self.isFlashOn {
                        device.torchMode = .off
                    } else {
                        do {
                            try device.setTorchModeOn(level: AVCaptureDevice.maxAvailableTorchLevel)
                        } catch {
                            appDependencies.logger.log(message: "Failed to set torch mode: \(error)")
                        }
                    }
                    self.isFlashOn.toggle()
                    device.unlockForConfiguration()
                }
            } catch {
                appDependencies.logger.log(message: "Failed to toggle flash: \(error)")
            }
        }
    }
}
