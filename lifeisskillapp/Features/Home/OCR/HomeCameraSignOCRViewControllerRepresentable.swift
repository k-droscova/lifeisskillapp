//
//  HomeCameraSignOCRViewControllerRepresentable.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 25.07.2024.
//

import SwiftUI
import UIKit
import VisionKit

/// A SwiftUI representable struct that wraps a `UIViewController` to use the VisionKit `DataScannerViewController` for scanning text.
@available(iOS 16.0, *)
struct HomeCameraSignOCRViewControllerRepresentable: UIViewControllerRepresentable {
    private let viewModel: HomeViewModeling
    
    /// Initializes the `HomeCameraSignOCRViewControllerRepresentable` with the provided view model.
    /// - Parameter viewModel: The view model conforming to `HomeViewModeling`.
    init(viewModel: HomeViewModeling) {
        self.viewModel = viewModel
    }
    
    /// Creates and returns the `UIViewController` that will be presented.
    /// - Parameter context: The context in which the view controller is created.
    /// - Returns: The created `UIViewController`.
    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()
        let dataScannerVC = DataScannerViewController(
            recognizedDataTypes: [.text()],
            qualityLevel: .balanced,
            recognizesMultipleItems: true,
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
    
    /// Updates the `UIViewController` when the SwiftUI view’s state changes.
    /// - Parameters:
    ///   - uiViewController: The `UIViewController` to update.
    ///   - context: The context in which the view is updated.
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        // Update the view controller if needed
    }
    
    /// Creates and returns the coordinator that manages the `DataScannerViewController` interactions.
    /// - Returns: The created coordinator.
    func makeCoordinator() -> Coordinator {
        Coordinator(viewModel: viewModel)
    }
    
    /// A coordinator class that serves as the delegate for the `DataScannerViewController`.
    class Coordinator: NSObject, DataScannerViewControllerDelegate {
        private let viewModel: HomeViewModeling
        weak var dataScannerVC: DataScannerViewController?
        private var itemHighlightViews: [RecognizedItem.ID: HighlightView] = [:]
        
        /// Initializes the coordinator with the provided view model.
        /// - Parameter viewModel: The view model conforming to `HomeViewModeling`.
        init(viewModel: HomeViewModeling) {
            self.viewModel = viewModel
        }
        
        /// Called when the user taps on a recognized item.
        /// - Parameters:
        ///   - dataScanner: The `DataScannerViewController` instance.
        ///   - item: The recognized item that was tapped.
        func dataScanner(_ dataScanner: DataScannerViewController, didTapOn item: RecognizedItem) {
            switch item {
            case .text(let text):
                viewModel.categorizeText(text.transcript)
            case .barcode: break
            @unknown default:
                viewModel.scanningFailed()
            }
        }
        
        /// Called when new recognized items are added.
        /// - Parameters:
        ///   - dataScanner: The `DataScannerViewController` instance.
        ///   - addItems: The newly added recognized items.
        ///   - allItems: All currently recognized items.
        func dataScanner(_ dataScanner: DataScannerViewController, didAdd addItems: [RecognizedItem], allItems: [RecognizedItem]) {
            for item in addItems {
                switch item {
                case .text(let text):
                    if viewModel.isSignTextValid(text.transcript) {
                        let newView = HighlightView(item: item)
                        itemHighlightViews[item.id] = newView
                        dataScanner.overlayContainerView.addSubview(newView)
                    }
                case .barcode: break
                @unknown default:
                    viewModel.scanningFailed()
                }
            }
        }
        
        /// Called when recognized items are updated.
        /// - Parameters:
        ///   - dataScanner: The `DataScannerViewController` instance.
        ///   - updatedItems: The updated recognized items.
        ///   - allItems: All currently recognized items.
        func dataScanner(_ dataScanner: DataScannerViewController, didUpdate updatedItems: [RecognizedItem], allItems: [RecognizedItem]) {
            for item in updatedItems {
                if let view = itemHighlightViews[item.id] {
                    view.removeFromSuperview()
                    itemHighlightViews.removeValue(forKey: item.id)
                    let newView = HighlightView(item: item)
                    itemHighlightViews[item.id] = newView
                    dataScanner.overlayContainerView.addSubview(newView)
                }
            }
        }
        
        /// Called when recognized items are removed.
        /// - Parameters:
        ///   - dataScanner: The `DataScannerViewController` instance.
        ///   - removedItems: The removed recognized items.
        ///   - allItems: All currently recognized items.
        func dataScanner(_ dataScanner: DataScannerViewController, didRemove removedItems: [RecognizedItem], allItems: [RecognizedItem]) {
            for item in removedItems {
                if let view = itemHighlightViews[item.id] {
                    itemHighlightViews.removeValue(forKey: item.id)
                    view.removeFromSuperview()
                }
            }
        }
    }
    
    /// A custom view used to highlight recognized items in the data scanner's overlay container view.
    class HighlightView: UIView {
        /// Initializes the `HighlightView` with the provided recognized item.
        /// - Parameter item: The recognized item to highlight.
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
