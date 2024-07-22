//
//  LoginView.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 01.07.2024.
//

import SwiftUI

struct LoginView: View {
    @State var viewModel: LoginViewModeling
    
    var body: some View {
        contentView
            .padding(30)
    }
    
    var contentView: some View {
        VStack {
            
            Spacer()
            
            VStack {
                TextField(
                    "login.username",
                    text: $viewModel.username
                )
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .padding(.top, 20)
                
                Divider()
                
                SecureField(
                    "login.password",
                    text: $viewModel.password
                )
                .padding(.top, 20)
                
                Divider()
            }
            
            Spacer()
            
            // LOGIN BUTTON
            Button(action: viewModel.login) {
                Text("login.login")
            }
            .loginButtonStyle()
            
            Spacer()
            
            // REGISTER BUTTON
            Button(action: viewModel.register) {
                Text("login.register")
            }
            .registerButtonStyle()
        }
        .onAppear {
            viewModel.onAppear()
        }
    }
}
