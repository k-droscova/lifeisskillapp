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
            recognizesMultipleItems: false,  // Only recognize one item at a time
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
        
        private var highlightView: HighlightView?
        private var recognitionTimer: Timer?
        private var currentRecognizedCode: String?
        private let timerConstant: TimeInterval = 2.0
        
        init(viewModel: OcrViewModeling) {
            self.viewModel = viewModel
        }
        
        func dataScanner(_ dataScanner: DataScannerViewController, didAdd addItems: [RecognizedItem], allItems: [RecognizedItem]) {
            for item in addItems {
                if case .text(let text) = item {
                    if let code = viewModel.extractCode(from: text.transcript) {
                        // If no code is being tracked, or this is a new code
                        if currentRecognizedCode == nil || currentRecognizedCode != code {
                            resetRecognitionProcess()  // Reset previous processes
                            currentRecognizedCode = code
                            highlightItem(item, in: dataScanner)
                            startRecognitionTimer(for: code)
                        }
                    }
                }
            }
        }
        
        func dataScanner(_ dataScanner: DataScannerViewController, didUpdate updatedItems: [RecognizedItem], allItems: [RecognizedItem]) {
            for item in updatedItems {
                if case .text(let text) = item,
                   let code = viewModel.extractCode(from: text.transcript),
                   let currentCode = currentRecognizedCode {
                    if currentCode == code {
                        return
                    }
                }
            }
            resetRecognitionProcess()
        }
        
        func dataScanner(_ dataScanner: DataScannerViewController, didRemove removedItems: [RecognizedItem], allItems: [RecognizedItem]) {
            for item in removedItems {
                if case .text(let text) = item,
                    let code = viewModel.extractCode(from: text.transcript),
                    let currentCode = currentRecognizedCode {
                    if currentCode == code {
                        resetRecognitionProcess()
                        return
                    }
                }
            }
        }
        
        private func startRecognitionTimer(for code: String) {
            recognitionTimer = Timer.scheduledTimer(withTimeInterval: timerConstant, repeats: false) { [weak self] _ in
                DispatchQueue.main.async {
                    self?.processRecognizedCode(code)
                }
            }
        }
        
        private func resetRecognitionProcess() {
            recognitionTimer?.invalidate()
            recognitionTimer = nil
            highlightView?.removeFromSuperview()
            highlightView = nil
            currentRecognizedCode = nil
        }
        
        private func processRecognizedCode(_ code: String) {
            viewModel.handleProcessedCode(code)
            resetRecognitionProcess()
        }
        
        private func highlightItem(_ item: RecognizedItem, in dataScanner: DataScannerViewController) {
            let newView = HighlightView(item: item)
            dataScanner.overlayContainerView.addSubview(newView)
            highlightView = newView 
        }
    }
    
    class HighlightView: UIView {
        init(item: RecognizedItem) {
            let frame = CGRect(
                x: item.bounds.topLeft.x - 10,
                y: item.bounds.topLeft.y - 10,
                width: abs(item.bounds.topRight.x - item.bounds.topLeft.x) + 20,
                height: abs(item.bounds.topLeft.y - item.bounds.bottomLeft.y) + 20
            )
            super.init(frame: frame)
            
            backgroundColor = UIColor.red.withAlphaComponent(0.2)
            layer.borderColor = UIColor.red.cgColor
            layer.borderWidth = 1
            clipsToBounds = true
            layer.cornerRadius = 8
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}
