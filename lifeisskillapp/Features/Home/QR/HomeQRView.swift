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
            
            overlayView
            .edgesIgnoringSafeArea([.leading, .trailing, .bottom])
            .padding(.top, UIApplication.shared.connectedScenes.first?.inputView?.window?.safeAreaInsets.top) // Ensure the view respects the top safe area so that the buttons react to taps
        }
    }
    
    private var overlayView: some View {
        VStack {
            topButtons
            
            Spacer(minLength: 32)
            
            centerView
            
            Spacer(minLength: 32)
            
            instructionsView
        }
    }
    
    private var topButtons: some View {
        HStack {
            CameraButton(action: viewModel.dismissScanner)
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
    
    private var centerView: some View {
        Image(CustomImages.scanningFrame.rawValue)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .padding()
    }
    
    private var instructionsView: some View {
        Text("home.qr.scan_alert")
            .foregroundColor(.white)
            .multilineTextAlignment(.center)
            .padding()
            .background(Color.black.opacity(0.5))
            .cornerRadius(10)
            .padding(.bottom, 100)
            .padding(.horizontal, 20)
    }
}