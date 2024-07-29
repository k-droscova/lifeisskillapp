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
            
            VStack {
                TopButtons(viewModel: viewModel)
                
                Spacer(minLength: 32)
                
                CenterView()
                
                Spacer(minLength: 32)
                
                InstructionsView()
            }
            .edgesIgnoringSafeArea([.leading, .trailing, .bottom])
            .padding(.top, UIApplication.shared.connectedScenes.first?.inputView?.window?.safeAreaInsets.top) // Ensure the view respects the top safe area so that the buttons react to taps
        }
    }
    
    private struct TopButtons: View {
        @State private var viewModel: QRViewModeling
        
        init(viewModel: QRViewModeling) {
            self._viewModel = State(initialValue: viewModel)
        }
        
        var body: some View {
            HStack {
                CameraButton(action: viewModel.dismissScanner)
                .padding(.leading, 20)
                .padding(.top, 20)
                
                Spacer()
                
                FlashButton(
                    action: {
                        viewModel.toggleFlash()
                    },
                    flashOn: $viewModel.isFlashOn
                )
                .padding(.trailing, 20)
                .padding(.top, 20)
            }
        }
    }
    
    private struct CenterView: View {
        var body: some View {
            VStack {

                Spacer(minLength: 32)
                
                Image("frame")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding()
                
                Spacer(minLength: 32)
                
            }
        }
    }
    
    private struct InstructionsView: View {
        var body: some View {
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
    
    private struct BorderView: View {
        var body: some View {
            Color.black.opacity(0.3)
        }
    }
}
