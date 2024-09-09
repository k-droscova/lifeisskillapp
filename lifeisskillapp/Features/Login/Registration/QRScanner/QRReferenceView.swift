//
//  ReferenceQRView.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 04.09.2024.
//

import SwiftUI

struct QRReferenceView: View {
    @State private var viewModel: QRViewModeling
    
    init(viewModel: QRViewModeling) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        ZStack {
            HomeQRViewControllerRepresentable(viewModel: viewModel)
                .edgesIgnoringSafeArea(.all)
            
            GeometryReader { geometry in
                QROverlayView(
                    topInset: geometry.safeAreaInsets.top,
                    exitButtonAction: viewModel.dismissScanner,
                    flashAction: viewModel.toggleFlash,
                    isFlashOn: $viewModel.isFlashOn,
                    instructions: "home.qr.scan_alert"
                )
                .edgesIgnoringSafeArea([.leading, .trailing, .bottom])
            }
        }
    }
}
