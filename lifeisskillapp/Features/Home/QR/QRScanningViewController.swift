//
//  QRScanningViewController.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 29.07.2024.
//

import ACKategories
import SwiftUI
import AVFoundation

final class QRScannerViewController: Base.ViewController {
    let viewModel: QRViewModeling
    
    // MARK: - Initialization
    
    init(viewModel: QRViewModeling) {
        self.viewModel = viewModel
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupScanner()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewModel.stopScanning()
    }
    
    private func setupScanner() {
        viewModel.setupPreviewLayer()
        if let previewLayer = viewModel.previewLayer {
            previewLayer.frame = view.layer.bounds
            view.layer.addSublayer(previewLayer)
        }
        else {
            viewModel.scanningFailed()
        }
        viewModel.startScanning()
    }
}
