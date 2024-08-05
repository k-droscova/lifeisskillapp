//
//  HomeView.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 24.07.2024.
//

import SwiftUI

struct HomeView: View {
    @State private var viewModel: HomeViewModeling
    private let categorySelectorVC: UIViewController
    
    init(viewModel: HomeViewModeling, categorySelectorVC: UIViewController) {
        self._viewModel = State(initialValue: viewModel)
        self.categorySelectorVC = categorySelectorVC
    }
    
    var body: some View {
        CategorySelectorContainerView(
            categorySelectorVC: categorySelectorVC,
            spacing: Constants.vStackSpacing
        ) {
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
        Image(CustomImages.Screens.home.rawValue)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .squareFrame(size: Constants.imageSize)
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
                background: Constants.Colors.nfc,
                textColor: Constants.Colors.white
            )
            
            HomeButton(
                action: viewModel.loadWithQRCode,
                text: Text("home.qr.button"),
                background: Constants.Colors.qr,
                textColor: Constants.Colors.white
            )
            
            HomeButton(
                action: viewModel.loadFromCamera,
                text: Text("home.camera.button"),
                background: Constants.Colors.camera,
                textColor: Constants.Colors.black
            )
            
            HomeButton(
                action: viewModel.showOnboarding,
                text: Text("home.button.how"),
                background: Constants.Colors.transparent,
                textColor: Constants.Colors.help
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
            static let nfc = Color.colorLisRose
            static let qr = Color.colorLisGreen
            static let camera = Color.colorLisOchre
            static let white = Color.colorLisWhite
            static let transparent = Color.transparent
            static let help = Color.colorLisDarkGrey
            static let black = Color.black
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
        HomeView(viewModel: MockHomeViewModel(), categorySelectorVC:
                    CategorySelectorView(viewModel: MockCategorySelectorViewModel()).hosting()
        )
    }
}
