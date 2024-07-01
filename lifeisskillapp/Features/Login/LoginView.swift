//
//  LoginView.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 01.07.2024.
//

import SwiftUI

struct LoginView: View {
    @State var viewModel: LoginViewModeling
    let defaultUsernameText = "username/email"
    let defaultPasswordText = "password"
    let buttonText = "login"

    
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
                    Text(buttonText.localized)
                        .font(.system(size: 24, weight: .bold, design: .default))
                        .frame(maxWidth: .infinity, maxHeight: 60)
                        .foregroundColor(Color.white)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
            )
        }
    }
}
