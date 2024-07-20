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
                    "login.username".localized,
                    text: $viewModel.username
                )
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .padding(.top, 20)
                
                Divider()
                
                SecureField(
                    "login.password".localized,
                    text: $viewModel.password
                )
                .padding(.top, 20)
                
                Divider()
            }
            
            Spacer()
            
            // LOGIN BUTTON
            Button(action: viewModel.login) {
                Text("login.login".localized)
            }
            .loginButtonStyle()
            
            Spacer()
            
            // REGISTER BUTTON
            Button(action: viewModel.register) {
                Text("login.register".localized)
            }
            .registerButtonStyle()
        }
        .onAppear(perform: {
            viewModel.fetchData()
        })
    }
}
