//
//  HomeCameraOCRView.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 25.07.2024.
//

import SwiftUI

@available(iOS 16.0, *)
struct HomeCameraOCRView: View {
    @State private var viewModel: OcrViewModeling
    
    init(viewModel: OcrViewModeling) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        ZStack {
            HomeCameraSignOCRViewControllerRepresentable(viewModel: viewModel)
            
            GeometryReader { geometry in
                CameraOverlayView(
                    topInset: geometry.safeAreaInsets.top,
                    exitButtonAction: viewModel.dismissCamera,
                    flashAction: viewModel.toggleFlash,
                    isFlashOn: $viewModel.isFlashOn,
                    instructions: "home.camera.instructions"
                ) { 
                    // empty (nil) center view
                }
                .edgesIgnoringSafeArea([.leading, .trailing, .bottom])
            }
        }
    }
}
