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
            
            OverlayView
            .edgesIgnoringSafeArea([.leading, .trailing, .bottom])
            .padding(.top, UIApplication.shared.connectedScenes.first?.inputView?.window?.safeAreaInsets.top) // Ensure the view respects the top safe area so that the buttons react to taps
        }
    }
    
    private var OverlayView: some View {
        VStack {
            TopButtons
            
            Spacer()
            
            InstructionsView
        }
    }
    
    private var TopButtons: some View {
        HStack {
            ExitButton(action: viewModel.dismissCamera)
                .padding(.leading, 20)
                .padding(.top, 20)
            
            Spacer()
            
            FlashButton(
                action: viewModel.toggleFlash,
                flashOn: $viewModel.isFlashOn
            )
            .padding(.trailing, 20)
            .padding(.top, 20)
        }
    }
    
    private var InstructionsView: some View {
        Text("home.camera.instructions")
            .foregroundColor(.white)
            .padding()
            .background(Color.black.opacity(0.5))
            .cornerRadius(10)
            .padding(.bottom, 100)
            .padding(.horizontal, 20)
    }
}
