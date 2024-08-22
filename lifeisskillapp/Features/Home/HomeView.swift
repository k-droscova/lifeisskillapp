//
//  HomeView.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 24.07.2024.
//

import SwiftUI

struct HomeView<ViewModel: HomeViewModeling>: View {
    @StateObject private var viewModel: ViewModel
    
    init(viewModel: ViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        StatusBarContainerView(
            viewModel: self.viewModel.settingsViewModel,
            spacing: 0
        ) {
            CategorySelectorContainerView(
                viewModel: self.viewModel.csViewModel,
                topLeftView: userNameText,
                spacing: HomeViewConstants.vStackSpacing
            ) {
                contentView
            }
        }
        .onAppear {
            viewModel.onAppear()
        }
        .overlay(
            Group {
                if viewModel.isLoading {
                    CustomProgressView()
                }
            }
        )
    }
}

private extension HomeView {
    private var contentView: some View {
        ScrollView {
            VStack(spacing: HomeViewConstants.vStackSpacing) {
                imageView
                instructionsView
                buttonsView
            }
        }
    }
    
    private var userNameText: some View {
        Text(viewModel.username)
            .headline3
    }
    
    private var imageView: some View {
        Image(CustomImages.Screens.home.fullPath)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .squareFrame(size: HomeViewConstants.imageSize)
            .padding()
    }
    
    private var instructionsView: some View {
        Text("home.description")
            .body1Regular
            .padding(.horizontal, HomeViewConstants.horizontalPadding)
            .padding()
    }
    
    private var buttonsView: some View {
        VStack(spacing: HomeViewConstants.buttonSpacing) {
            HomeButton(
                action: viewModel.loadWithNFC,
                text: Text("home.nfc.button"),
                background: HomeViewConstants.Colors.nfc,
                textColor: HomeViewConstants.Colors.white
            )
            
            HomeButton(
                action: viewModel.loadWithQRCode,
                text: Text("home.qr.button"),
                background: HomeViewConstants.Colors.qr,
                textColor: HomeViewConstants.Colors.white
            )
            
            HomeButton(
                action: viewModel.loadFromCamera,
                text: Text("home.camera.button"),
                background: HomeViewConstants.Colors.camera,
                textColor: HomeViewConstants.Colors.black
            )
            
            HomeButton(
                action: viewModel.showOnboarding,
                text: Text("home.button.how"),
                background: HomeViewConstants.Colors.transparent,
                textColor: HomeViewConstants.Colors.help
            )
        }
    }
}

enum HomeViewConstants {
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

/*class MockHomeViewModel: BaseClass, HomeViewModeling {
    typealias categorySelectorVM = MockCategorySelectorViewModel
    
    @StateObject var csViewModel = MockCategorySelectorViewModel()
    
    var isLoading: Bool = false
    
    var username: String = "TestUser"
    
    func onAppear() {
        isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            print("Mock onAppear")
            self.username = "Mock done"
        }
        isLoading = false
    }
    
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
*/
