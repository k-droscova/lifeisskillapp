//
//  HomeCameraSignOCRViewControllerRepresentable.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 25.07.2024.
//

import SwiftUI
import UIKit
import VisionKit

@available(iOS 16.0, *)
struct HomeCameraSignOCRViewControllerRepresentable: UIViewControllerRepresentable {
    private let viewModel: OcrViewModeling
    
    init(viewModel: OcrViewModeling) {
        self.viewModel = viewModel
    }
    
    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()
        let dataScannerVC = DataScannerViewController(
            recognizedDataTypes: [.text()],
            qualityLevel: .accurate,  // Accurate to better recognize small texts
            recognizesMultipleItems: true,
            isHighFrameRateTrackingEnabled: true,
            isPinchToZoomEnabled: true,
            isGuidanceEnabled: true
        )
        dataScannerVC.delegate = context.coordinator
        viewController.addChild(dataScannerVC)
        viewController.view.addSubview(dataScannerVC.view)
        dataScannerVC.view.frame = viewController.view.bounds
        dataScannerVC.didMove(toParent: viewController)
        
        do {
            try dataScannerVC.startScanning()
        } catch {
            viewModel.scanningFailed()
        }
        
        context.coordinator.dataScannerVC = dataScannerVC
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        // Update the view controller if needed
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(viewModel: viewModel)
    }
    
    
    class Coordinator: NSObject, DataScannerViewControllerDelegate {
        private let viewModel: OcrViewModeling
        weak var dataScannerVC: DataScannerViewController?
        
        private var codeOccurrences: [String: Int] = [:]
        private let recognitionThreshold: Int = OcrConstants.minThreshold
        
        init(viewModel: OcrViewModeling) {
            self.viewModel = viewModel
        }
        
        func dataScanner(_ dataScanner: DataScannerViewController, didAdd addItems: [RecognizedItem], allItems: [RecognizedItem]) {
            for item in addItems {
                if case .text(let text) = item {
                    if let code = viewModel.extractCode(from: text.transcript) {
                        handleCodeRecognition(code)
                    }
                }
            }
        }
        
        func dataScanner(_ dataScanner: DataScannerViewController, didStopWithError error: Error) {
            stopScanning()
            viewModel.scanningFailed()
        }
        
        private func handleCodeRecognition(_ code: String) {
            guard let count = codeOccurrences[code] else {
                codeOccurrences[code] = 1
                return // threshold is definitely above 1
            }
            let newCount = count + 1 // increase occurence num by one
            codeOccurrences[code] = newCount // set new val
            guard newCount >= recognitionThreshold else {
                // if below threwshold then return
                return
            }
            processRecognizedCode(code)
            stopScanning()
        }
        
        private func processRecognizedCode(_ code: String) {
            viewModel.handleProcessedCode(code)
            codeOccurrences.removeAll()
        }
        
        private func stopScanning() {
            dataScannerVC?.stopScanning()
        }
    }
}
