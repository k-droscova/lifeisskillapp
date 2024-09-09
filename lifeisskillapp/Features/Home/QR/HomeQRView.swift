//
//  HomeQRView.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 29.07.2024.
//

import SwiftUI

struct HomeQRView: View {
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
