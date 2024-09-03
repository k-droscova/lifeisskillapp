//
//  LoginView.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 01.07.2024.
//

import SwiftUI

struct LoginView<ViewModel: LoginViewModeling>: View {
    @StateObject var viewModel: ViewModel
    
    var body: some View {
        StatusBarContainerView(
            viewModel: self.viewModel.settingsViewModel,
            spacing: 0
        ) {
            contentView
        }
        .onAppear {
            viewModel.onAppear()
        }
        .onTapGesture {
            hideKeyboard()
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

private extension LoginView {
    private var contentView: some View {
        VStack {
            Spacer()
            
            loginImageView
            
            textFields
            
            loginButton
                .padding(.horizontal, LoginViewConstants.horizontalPadding)
                .padding(.top, LoginViewConstants.topPadding)
            
            Spacer()
            
            bottomButtons
        }
    }
    
    private var loginImageView: some View {
        Image(CustomImages.Screens.login.fullPath)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(height: LoginViewConstants.imageHeight)
            .padding(.bottom, LoginViewConstants.imageBottomPadding)
    }
    
    private var textFields: some View {
        VStack(spacing: LoginViewConstants.spacing) {
            CustomTextField(
                placeholder: "login.username",
                text: $viewModel.username
            )
            CustomTextField(
                placeholder: "login.password",
                text: $viewModel.password,
                isSecure: true
            )
        }
        .padding(.horizontal, LoginViewConstants.horizontalPadding)
    }
    
    private var loginButton: some View {
        EnablingButton(
            action: viewModel.login,
            text: "login.login",
            isEnabled: viewModel.isLoginEnabled
        )
        .disabled(!viewModel.isLoginEnabled)
    }
    
    private var bottomButtons: some View {
        HStack {
            Button(action: viewModel.forgotPassword) {
                Text("login.forgotPassword")
            }
            Spacer()
            Button(action: viewModel.register) {
                Text("login.register")
            }
        }
        .padding(.horizontal, LoginViewConstants.horizontalPadding)
        .padding(.bottom, LoginViewConstants.bottomPadding)
    }
}

// NOTE: constants are not in extension because static properties are not allowed in generic types
enum LoginViewConstants {
    static let spacing: CGFloat = 16
    static let horizontalPadding: CGFloat = 30
    static let topPadding: CGFloat = 20
    static let bottomPadding: CGFloat = 30
    static let imageHeight: CGFloat = 200
    static let imageBottomPadding: CGFloat = 20
}
