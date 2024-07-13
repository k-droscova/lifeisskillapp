//
//  LoginView.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 01.07.2024.
//

import SwiftUI

struct LoginView: View {
    @State var viewModel: LoginViewModeling
    let defaultUsernameText = L10n.Login.username
    let defaultPasswordText = L10n.Login.password
    let loginButtonText = L10n.Login.login
    let registerButtonText = L10n.Login.register

    
    var body: some View {
        contentView
            .padding(30)
    }
    
    var contentView: some View {
        VStack {
            
            Spacer()
            
            VStack {
                TextField(
                    defaultUsernameText.localized,
                    text: $viewModel.username
                )
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .padding(.top, 20)
                
                Divider()
                
                SecureField(
                    defaultPasswordText.localized,
                    text: $viewModel.password
                )
                .padding(.top, 20)
                
                Divider()
            }
            
            Spacer()
            
            Button(
                action: viewModel.login,
                label: {
                    Text(loginButtonText.localized)
                        .font(.system(size: 24, weight: .bold, design: .default))
                        .frame(maxWidth: .infinity, maxHeight: 60)
                        .foregroundColor(Color.white)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
            )
            
            Spacer()
            
            Button(
                action: viewModel.register,
                label: {
                    Text(registerButtonText.localized)
                        .font(.system(size: 14, weight: .bold, design: .default))
                        .frame(maxWidth: .infinity, maxHeight: 20)
                        .foregroundColor(Color.red)
                        .background(Color.white)
                        .cornerRadius(10)
                }
            )
        }
    }
}
