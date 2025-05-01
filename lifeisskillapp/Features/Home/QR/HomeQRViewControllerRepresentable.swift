//
//  HomeQRViewControllerRepresentable.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 29.07.2024.
//

import SwiftUI

struct HomeQRViewControllerRepresentable: UIViewControllerRepresentable {
    typealias UIViewControllerType = QRScannerViewController
    
    @State var viewModel: QRViewModeling
    
    init(viewModel: QRViewModeling) {
        self.viewModel = viewModel
    }
    
    func makeUIViewController(context: Context) -> QRScannerViewController {
        QRScannerViewController(viewModel: viewModel)
    }
    
    func updateUIViewController(_ uiViewController: QRScannerViewController, context: Context) {
        // No update required 
    }
}
