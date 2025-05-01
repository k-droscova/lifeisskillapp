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
        ScreenResizingImage(
            Image: Image(CustomImages.Screens.home.fullPath),
            heightScreenRatio: 0.3
        )
        .padding(.bottom)
    }
    
    private var instructionsView: some View {
        Text("home.description")
            .body1Regular
            .frame(maxWidth: HomeViewConstants.maxDetailFrameWidth)
            .padding(.horizontal, HomeViewConstants.horizontalPadding)
            .multilineTextAlignment(.center)
    }
    
    private var buttonsView: some View {
        VStack(spacing: HomeViewConstants.buttonVerticalSpacing) {
            HStack(spacing: HomeViewConstants.buttonHorizontalSpacing) {
                nfcButton
                qrButton
                textButton
                if viewModel.isVirtualAvailable { virtualButton }
            }
            .caption
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
    
    private var nfcButton: some View {
        HomeButton(
            action: viewModel.loadWithNFC,
            background: HomeViewConstants.Colors.nfc,
            foregroundColor: HomeViewConstants.Colors.white
        ) {
            SFSSymbols.nfc.image
        }
    }
    
    private var qrButton: some View {
        HomeButton(
            action: viewModel.loadWithQRCode,
            background: HomeViewConstants.Colors.qr,
            foregroundColor: HomeViewConstants.Colors.white
        ) {
            SFSSymbols.qr.image
        }
    }
    
    private var textButton: some View {
        HomeButton(
            action: viewModel.loadFromCamera,
            background: HomeViewConstants.Colors.camera,
            foregroundColor: HomeViewConstants.Colors.black
        ) {
            SFSSymbols.camera.image
        }
    }
    
    private var virtualButton: some View {
        HomeButton(
            action: viewModel.loadVirtual,
            background: HomeViewConstants.Colors.virtual,
            foregroundColor: HomeViewConstants.Colors.white
        ) {
            SFSSymbols.virtual.image
        }
    }
}

enum HomeViewConstants {
    static let maxDetailFrameWidth: CGFloat = 600
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
