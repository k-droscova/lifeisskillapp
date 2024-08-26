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
            .multilineTextAlignment(.center)
    }
    
    private var buttonsView: some View {
        VStack(spacing: HomeViewConstants.buttonVerticalSpacing) {
            HStack(spacing: HomeViewConstants.buttonHorizontalSpacing) {
                HomeButton(
                    action: viewModel.loadWithNFC,
                    background: HomeViewConstants.Colors.nfc,
                    foregroundColor: HomeViewConstants.Colors.white
                ) {
                    SFSSymbols.nfc.Image
                }
                
                HomeButton(
                    action: viewModel.loadWithQRCode,
                    background: HomeViewConstants.Colors.qr,
                    foregroundColor: HomeViewConstants.Colors.white
                ) {
                    SFSSymbols.qr.Image
                }
                
                
                HomeButton(
                    action: viewModel.loadFromCamera,
                    background: HomeViewConstants.Colors.camera,
                    foregroundColor: HomeViewConstants.Colors.black
                ) {
                    SFSSymbols.camera.Image
                }
                
            }
            HomeButton(
                action: viewModel.showOnboarding,
                background: HomeViewConstants.Colors.transparent,
                foregroundColor: HomeViewConstants.Colors.help
            ) {
                Text("home.button.how")
            }
        }
        .padding(.top, HomeViewConstants.buttonTopPadding)
    }
}

enum HomeViewConstants {
    static let vStackSpacing: CGFloat = 16
    static let buttonTopPadding: CGFloat = 16
    static let imageSize: CGFloat = 200
    static let horizontalPadding: CGFloat = 32
    static let buttonVerticalSpacing: CGFloat = 24
    static let buttonHorizontalSpacing: CGFloat = 24
    
    enum Colors {
        static let nfc = Color.colorLisRose
        static let qr = Color.colorLisGreen
        static let camera = Color.colorLisOchre
        static let virtual = Color.colorLisBlue
        static let white = Color.colorLisWhite
        static let transparent = Color.transparent
        static let help = Color.colorLisDarkGrey
        static let black = Color.black
    }
}
