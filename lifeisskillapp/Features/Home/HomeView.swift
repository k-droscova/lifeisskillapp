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
        self._viewModel = State(initialValue: viewModel)
    }
    
    var body: some View {
        VStack(spacing: Constants.vStackSpacing) {
            // TODO: insert category selector
            ScrollView {
                VStack(spacing: Constants.vStackSpacing) {
                    imageView
                    instructionsView
                    buttonsView
                }
            }
        }
    }
    
    private var imageView: some View {
        Image(CustomImages.home.rawValue)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: Constants.imageSize, height: Constants.imageSize)
            .padding()
    }
    
    private var instructionsView: some View {
        Text("home.description")
            .body1Regular
            .padding(.horizontal, Constants.horizontalPadding)
            .padding()
    }
    
    private var buttonsView: some View {
        VStack(spacing: Constants.buttonSpacing) {
            HomeButton(
                action: viewModel.loadWithNFC,
                text: Text("home.nfc.button"),
                background: Constants.Colors.pink,
                textColor: .white
            )
            
            HomeButton(
                action: viewModel.loadWithQRCode,
                text: Text("home.qr.button"),
                background: Constants.Colors.green,
                textColor: .white
            )
            
            HomeButton(
                action: viewModel.loadFromCamera,
                text: Text("home.camera.button"),
                background: Constants.Colors.yellow,
                textColor: .black
            )
            
            HomeButton(
                action: viewModel.showOnboarding,
                text: Text("home.button.how"),
                background: .clear,
                textColor: .secondary
            )
        }
    }
}

extension HomeView {
    enum Constants {
        static let vStackSpacing: CGFloat = 16
        static let imageSize: CGFloat = 200
        static let horizontalPadding: CGFloat = 32
        static let buttonSpacing: CGFloat = 24
        
        enum Colors {
            static let pink = Color.pink
            static let green = Color.green
            static let yellow = Color.yellow
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
