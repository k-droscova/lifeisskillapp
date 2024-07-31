//
//  HomeQRView.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 29.07.2024.
//

import SwiftUI

@available(iOS 16.0, *)
struct HomeQRView: View {
    @State private var viewModel: QRViewModeling

    init(viewModel: QRViewModeling) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        ZStack {
            HomeQRViewControllerRepresentable(viewModel: viewModel)
                .edgesIgnoringSafeArea(.all)
            
            OverlayView
            .edgesIgnoringSafeArea([.leading, .trailing, .bottom])
            .padding(.top, UIApplication.shared.connectedScenes.first?.inputView?.window?.safeAreaInsets.top) // Ensure the view respects the top safe area so that the buttons react to taps
        }
    }
    
    private var OverlayView: some View {
        VStack {
            TopButtons
            
            Spacer(minLength: 32)
            
            CenterView
            
            Spacer(minLength: 32)
            
            InstructionsView
        }
    }
    
    private var TopButtons: some View {
        HStack {
            CameraButton(
                action: viewModel.dismissScanner)
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
    
    private var CenterView: some View {
        Image(CustomImages.scanningFrame.rawValue)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .padding()
    }
    
    private var InstructionsView: some View {
        Text(Instructions.Scanning.qr.rawValue)
            .foregroundColor(.white)
            .multilineTextAlignment(.center)
            .padding()
            .background(Color.black.opacity(0.5))
            .cornerRadius(10)
            .padding(.bottom, 100)
            .padding(.horizontal, 20)
    }
}
