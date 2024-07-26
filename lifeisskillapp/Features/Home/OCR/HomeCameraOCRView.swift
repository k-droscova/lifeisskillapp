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
                .edgesIgnoringSafeArea([.leading, .trailing, .bottom])

            VStack {
                Spacer()
                
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
                        Image(systemName: "bolt.fill")
                    }
                    .cameraButtonStyle()
                    .padding(.trailing, 20)
                    .padding(.top, 20)
                }
                
                Spacer()
                
                VStack {
                    HStack {
                        BorderView()
                            .frame(width: 20)
                        Spacer()
                        BorderView()
                            .frame(width: 20)
                    }
                    .frame(height: 200)
                    
                    Spacer()
                    
                    Image(systemName: "camera.viewfinder")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 200)
                        .padding()
                        .background(Color.black.opacity(0.5))
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                    
                    Spacer()
                    
                    HStack {
                        BorderView()
                            .frame(width: 20)
                        Spacer()
                        BorderView()
                            .frame(width: 20)
                    }
                    .frame(height: 200)
                }
                
                Spacer()
                
                Text("home.camera.instructions")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.black.opacity(0.5))
                    .cornerRadius(10)
                    .padding(.bottom, 100)
                    .padding(.horizontal, 20)
            }
        }
    }
    
    struct BorderView: View {
        var body: some View {
            Color.black.opacity(0.3)
        }
    }
}

/*@available(iOS 16.0, *)
struct HomeCameraOCRView_Previews: PreviewProvider {
    static var previews: some View {
        HomeCameraOCRView(viewModel: HomeViewModel(dependencies: appDependencies))
    }
}*/
