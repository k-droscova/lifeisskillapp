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
        @State private var viewModel: OcrViewModeling
        
        init(viewModel: OcrViewModeling) {
            self._viewModel = State(initialValue: viewModel)
        }
        
        var body: some View {
            HStack {
                Button(action: {
                    print("Close tapped")
                    viewModel.dismissCamera()
                }) {
                    Image(systemName: "xmark")
                }
                .cameraButtonStyle()
                .padding(.leading, 20)
                .padding(.top, 20)
                
                Spacer()
                
                Button(action: {
                    print("Flash tapped")
                }) {
                    Image(systemName: "bolt")
                }
                .cameraButtonStyle()
                .padding(.trailing, 20)
                .padding(.top, 20)
            }
        }
    }
    
    private struct CenterView: View {
        var body: some View {
            VStack {
                HStack {
                    BorderView()
                        .frame(width: 20)
                    Spacer()
                    BorderView()
                        .frame(width: 20)
                }
                .frame(maxHeight: 200)

                Spacer(minLength: 32)
                
                Image(systemName: "camera.viewfinder")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .padding()
                    .background(Color.black.opacity(0.5))
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                
                Spacer(minLength: 32)
                
                HStack {
                    BorderView()
                        .frame(width: 20)
                    Spacer()
                    BorderView()
                        .frame(width: 20)
                }
                .frame(maxHeight: 200)
            }
        }
    }
    
    private struct InstructionsView: View {
        var body: some View {
            Text("home.camera.instructions")
                .foregroundColor(.white)
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
