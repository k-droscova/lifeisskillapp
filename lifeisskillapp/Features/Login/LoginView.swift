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
        VStack {
            Spacer()
            
            loginImageView
            
            VStack(spacing: LoginViewConstants.spacing) {
                usernameTextField
                passwordSecureField
            }
            .body1Regular
            .foregroundStyle(Color.colorLisDarkGrey)
            .kerning(1.2)
            .padding(.horizontal, LoginViewConstants.horizontalPadding)
            
            loginButton
                .padding(.horizontal, LoginViewConstants.horizontalPadding)
                .padding(.top, LoginViewConstants.topPadding)
            
            Spacer()
            
            bottomButtons
        }
        .onAppear {
            viewModel.onAppear()
        }
        .overlay(
            Group {
                if viewModel.isLoading {
                    ZStack {
                        Color.black.opacity(0.3)
                            .edgesIgnoringSafeArea(.all)
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                            .foregroundColor(.white)
                    }
                }
            }
        )
    }
}

private extension LoginView {
    
    private var loginImageView: some View {
        Image(CustomImages.Screens.login.rawValue)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(height: LoginViewConstants.imageHeight)
            .padding(.bottom, LoginViewConstants.imageBottomPadding)
    }
    
    private var usernameTextField: some View {
        TextField(
            "login.username",
            text: $viewModel.username
        )
        .autocapitalization(.none)
        .disableAutocorrection(true)
        .padding()
        .background(LoginViewConstants.Colors.textFieldBackground)
        .cornerRadius(LoginViewConstants.cornerRadius)
    }
    
    private var passwordSecureField: some View {
        SecureField(
            "login.password",
            text: $viewModel.password
        )
        .padding()
        .background(LoginViewConstants.Colors.textFieldBackground)
        .cornerRadius(LoginViewConstants.cornerRadius)
    }
    
    private var loginButton: some View {
        LoginButton(
            action: viewModel.login,
            text: Text("login.login"),
            enabledColorBackground: LoginViewConstants.Colors.enabledButton,
            disabledColorBackground: LoginViewConstants.Colors.disabledButton,
            enabledColorText: LoginViewConstants.Colors.enabledText,
            disabledColorText: LoginViewConstants.Colors.disabledText,
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
    static let cornerRadius: CGFloat = 10
    
    enum Colors {
        static let textFieldBackground = Color.lighterGrey
        static let enabledButton = Color.colorLisGreen
        static let disabledButton = Color.colorLisGrey
        static let enabledText = Color.white
        static let disabledText = Color.colorLisDarkGrey
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        let mockViewModel = MockLoginViewModel()
        LoginView(viewModel: mockViewModel)
    }
}

class MockLoginViewModel: BaseClass, LoginViewModeling, ObservableObject {
    @Published var username: String = "dc" {
        didSet {
            shouldEnableLoginButton()
        }
    }
    @Published var password: String = "csdc" {
        didSet {
            shouldEnableLoginButton()
        }
    }
    @Published var isLoginEnabled: Bool = false
    @Published var isLoading: Bool = false
    
    func login() {
        // Mock loading behavior
        isLoading = true
        print("Login started")
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            self.isLoading = false
            print("Login finished")
        }
    }
    
    func onAppear() {
        // Mock onAppear behavior
        print("Mock onAppear")
    }
    
    func register() {
        // Mock register behavior
        print("Mock register")
    }
    
    func forgotPassword() {
        // Mock forgotPassword behavior
        print("Mock forgotPassword")
    }
    
    private func shouldEnableLoginButton() {
        isLoginEnabled = username.isNotEmpty && password.isNotEmpty
    }
}
