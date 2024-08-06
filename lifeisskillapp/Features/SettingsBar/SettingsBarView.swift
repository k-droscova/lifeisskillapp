//
//  SettingsBarView.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 06.08.2024.
//

import SwiftUI

struct SettingsBarView<ViewModel: SettingsBarViewModeling>: View {
    @StateObject private var viewModel: ViewModel
    
    init(viewModel: ViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        VStack {
            header
            LocationStatusBarView(viewModel: viewModel.locationVM)
        }
    }
    
    // MARK: - Private Components
    
    private var header: some View {
        HStack {
            title
            Spacer()
            if viewModel.isLoggedIn {
                buttons
            }
        }
        .padding()
        .foregroundColor(.white)
        .background(Color.colorLisBlue)
    }
    
    private var title: some View {
        Text("statusBar.title")
            .headline3
    }
    
    private var buttons: some View {
        HStack(spacing: 24) {
            cameraButton
            menuButton
        }
        .padding(.trailing, 4)
    }
    
    private var cameraButton: some View {
        Button(action: {
            viewModel.cameraPressed()
        }) {
            Image(systemName: "camera")
        }
    }
    
    private var menuButton: some View {
        Menu {
            Button(action: {
                viewModel.logoutPressed()
            }) {
                Text("settings.logout")
            }
            Button(action: {
                viewModel.settingsPressed()
            }) {
                Text("settings.settings")
            }
            Button(action: {
                viewModel.onboardingPressed()
            }) {
                Text("settings.onboarding")
            }
        } label: {
            Image(systemName: "ellipsis.circle")
        }
    }
}
