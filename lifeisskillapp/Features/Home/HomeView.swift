//
//  HomeView.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 24.07.2024.
//

import SwiftUI

struct HomeView: View {
    @State private var viewModel: HomeViewModeling
    
    init(viewModel: HomeViewModeling) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack {
            topBarView
            ScrollView {
                VStack {
                    imageView
                    instructionsView
                    // TODO: change button colors
                    // TODO: implement automatic nfc scan?
                    buttonsView
                }
            }
        }
    }
    
    private var topBarView: some View {
        HStack {
            Text("Username")
                .padding()
                .headline2
            Spacer()
            DropdownMenu()
        }
    }
    
    private var imageView: some View {
        Image(CustomImages.home.rawValue)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 200, height: 200)
            .padding()
    }
    
    private var instructionsView: some View {
        Text("home.description.nfc")
            .body1Regular
            .padding(.horizontal, 34)
            .padding()
    }
    
    private var buttonsView: some View {
        VStack {
            Button(action: viewModel.loadWithNFC) {
                Text("home.nfc.button")
            }
            .buttonStyle(DefaultButtonStyle())
            .padding()
            
            Button(action: viewModel.loadWithQRCode) {
                Text("home.qr.button")
            }
            .homeButtonStyle(.green)
            .padding()
            
            Button(action: viewModel.loadFromCamera) {
                Text("home.camera.button")
            }
            .homeButtonStyle(.yellow)
            .padding()
            
            Button(action: viewModel.showOnboarding) {
                Text("Jak na to?")
            }
            .buttonStyle(DefaultButtonStyle())
            .padding()
        }
    }
}

class MockHomeViewModel: BaseClass, HomeViewModeling {
    func loadWithNFC() {
        print("I was tapped: loadWithNFC")
    }
    
    func loadWithQRCode() {
        print("I was tapped: loadWithQRCode")
    }
    
    func loadFromCamera() {
        print("I was tapped: loadFromCamera")
    }
    
    func dismissCamera() {
        print("I was tapped: dismissCamera")
    }
    
    func showOnboarding() {
        print("I was tapped: showOnboarding")
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(viewModel: MockHomeViewModel())
    }
}
