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
            
            VStack(spacing: 16) {
                usernameTextField
                passwordSecureField
            }
            .padding(.horizontal, 30)
            
            loginButton
                .padding(.horizontal, 30)
                .padding(.top, 20)
            
            Spacer()
            
            bottomButtons
        }
        .body2Login
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
        Image("loginScreen")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(height: 200)
            .padding(.bottom, 20)
    }
    
    private var usernameTextField: some View {
        TextField(
            "login.username",
            text: $viewModel.username
        )
        .autocapitalization(.none)
        .disableAutocorrection(true)
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(10)
    }
    
    private var passwordSecureField: some View {
        ZStack(alignment: .trailing) {
            Group {
                if viewModel.isPasswordVisible {
                    TextField(
                        "login.password",
                        text: $viewModel.password
                    )
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(10)
                } else {
                    SecureField(
                        "login.password",
                        text: $viewModel.password
                    )
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(10)
                }
            }
            
            Button(action: viewModel.onPasswordVisibilityTapped) {
                Image(systemName: viewModel.isPasswordVisible ? "eye.slash" : "eye")
                    .foregroundColor(.gray)
                    .padding(.trailing, 10)
            }
        }
    }
    
    private var loginButton: some View {
        Button(action: viewModel.login) {
            Text("login.login")
                .foregroundColor(viewModel.isLoginEnabled ? Color(.white) : Color("LisGreyTextFieldTitle"))
                .padding()
                .padding(.horizontal, 20)
                .background(viewModel.isLoginEnabled ? Color("LisGreen") : Color("LisGreyTextFieldTitle"))
                .cornerRadius(20)
        }
        .disabled(!viewModel.isLoginEnabled)
    }
    
    private var bottomButtons: some View {
        HStack {
            Button(action: viewModel.register) {
                Text("login.register")
            }
            Spacer()
            Button(action: viewModel.forgotPassword) {
                Text("login.forgotPassword")
            }
        }
        .padding(.horizontal, 30)
        .padding(.bottom, 30)
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        let mockViewModel = MockLoginViewModel()
        LoginView(viewModel: mockViewModel)
    }
}

class MockLoginViewModel: BaseClass, LoginViewModeling, ObservableObject {
    @Published var username: String = "TestUser"
    @Published var password: String = "Password123"
    @Published var isLoginEnabled: Bool = true
    @Published var isPasswordVisible: Bool = false
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
    
    func onPasswordVisibilityTapped() {
        isPasswordVisible.toggle()
        print("Password visibility toggled: \(isPasswordVisible)")
    }
}
