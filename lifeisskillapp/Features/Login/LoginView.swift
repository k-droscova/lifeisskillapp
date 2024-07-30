//
//  LoginView.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 01.07.2024.
//

import SwiftUI

import SwiftUI

struct LoginView: View {
    @State var viewModel: LoginViewModeling
    
    var body: some View {
        VStack {
            Spacer()
            
            LoginImageView()
            
            VStack(spacing: 16) {
                UsernameTextField(username: $viewModel.username)
                
                PasswordSecureField(
                    password: $viewModel.password,
                    isPasswordVisible: $viewModel.isPasswordVisible,
                    toggleVisibilityAction: viewModel.onPasswordVisibilityTapped
                )
            }
            .padding(.horizontal, 30)
            
            LoginButton(
                isEnabled: viewModel.isLoginEnabled,
                action: viewModel.login
            )
            .padding(.horizontal, 30)
            .padding(.top, 20)
            
            Spacer()
            
            BottomButtons(registerAction: viewModel.register, forgotPasswordAction: viewModel.forgotPassword)
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
    
    struct LoginImageView: View {
        var body: some View {
            Image("loginScreen") // Replace with your image asset name
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 200)
                .padding(.bottom, 20)
        }
    }
    
    struct UsernameTextField: View {
        @Binding var username: String
        
        var body: some View {
            TextField(
                "login.username",
                text: $username
            )
            .autocapitalization(.none)
            .disableAutocorrection(true)
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(10)
        }
    }
    
    struct PasswordSecureField: View {
        @Binding var password: String
        @Binding var isPasswordVisible: Bool
        var toggleVisibilityAction: () -> Void
        
        var body: some View {
            ZStack(alignment: .trailing) {
                if isPasswordVisible {
                    TextField(
                        "login.password",
                        text: $password
                    )
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(10)
                } else {
                    SecureField(
                        "login.password",
                        text: $password
                    )
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(10)
                }
                
                Button(action: toggleVisibilityAction) {
                    Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
                        .foregroundColor(.gray)
                        .padding(.trailing, 10)
                }
            }
        }
    }

    
    struct LoginButton: View {
        var isEnabled: Bool
        var action: () -> Void
        
        var body: some View {
            Button(action: action) {
                Text("login.login")
                    .foregroundColor(isEnabled ? Color(.white) : Color("LisGreyTextFieldTitle"))
                    .padding()
                    .padding(.horizontal, 20)
                    .background(isEnabled ? Color("LisGreen") : Color("LisGreyTextFieldTitle"))
                    .cornerRadius(20)
            }
            .cornerRadius(10)
            .disabled(!isEnabled)
        }
    }
    
    struct BottomButtons: View {
        var registerAction: () -> Void
        var forgotPasswordAction: () -> Void
        
        var body: some View {
            HStack {
                Button(action: registerAction) {
                    Text("login.register")
                }
                Spacer()
                Button(action: forgotPasswordAction) {
                    Text("login.forgotPassword")
                }
            }
            .padding(.horizontal, 30)
            .padding(.bottom, 30)
        }
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

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        let mockViewModel = MockLoginViewModel()
        LoginView(viewModel: mockViewModel)
    }
}
