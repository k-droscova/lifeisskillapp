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
        menuButton
        .padding(.trailing, 4)
    }
    
    private var menuButton: some View {
        Menu {
            Button(action: {
                viewModel.logoutPressed()
            }) {
                Text("settings.logout")
            }
            Button(action: {
                viewModel.onboardingPressed()
            }) {
                Text("settings.onboarding")
            }
            // MARK: settings will be implemented in the future once Martin determines what will be done in the settings
        } label: {
            SFSSymbols.settingsMenu.Image
        }
    }
}
