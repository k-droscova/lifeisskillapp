//
//  EnterPasswordView.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 26.08.2024.
//

import SwiftUI

struct EnterPasswordView<ViewModel: ForgotPasswordViewModeling>: View {
    @StateObject var viewModel: ViewModel

    var body: some View {
        ForgotPasswordPageView(
            text: Text("forgot_password.instructions.password")
        ) {
            contentView
        }
        .padding(.top, ForgotPasswordPagesConstants.topPadding)
        .overlay(
            Group {
                if viewModel.isLoading {
                    CustomProgressView()
                }
            }
        )
    }
}

private extension EnterPasswordView {
    private var contentView: some View {
        VStack {
            passwordView
            Spacer()
            buttonView
        }
        .padding(.bottom, ForgotPasswordPagesConstants.bottomPadding)
    }

    private var passwordView: some View {
        VStack {
            SecureField(
                "forgot_password.textfield.password",
                text: $viewModel.newPassword
            )
            .autocapitalization(.none)
            .disableAutocorrection(true)
            .padding()
            .background(ForgotPasswordPagesConstants.Colors.textFieldBackground)
            .cornerRadius(ForgotPasswordPagesConstants.cornerRadius)

            SecureField(
                "forgot_password.textfield.password_confirm",
                text: $viewModel.confirmPassword
            )
            .autocapitalization(.none)
            .disableAutocorrection(true)
            .padding()
            .background(ForgotPasswordPagesConstants.Colors.textFieldBackground)
            .cornerRadius(ForgotPasswordPagesConstants.cornerRadius)
        }
    }

    private var buttonView: some View {
        HStack {
            Button(action: viewModel.sendEmail) {
                Text("forgot_password.button.new_pin")
                    .foregroundColor(ForgotPasswordPagesConstants.Colors.buttonText)
                    .padding()
                    .padding(.horizontal, 16)
                    .background(ForgotPasswordPagesConstants.Colors.button)
                    .cornerRadius(20)
            }
            .subheadline

            Spacer()

            EnablingButton(
                action: {
                    viewModel.changePassword()
                },
                text: "forgot_password.button.confirm",
                isEnabled: viewModel.isChangePasswordButtonEnabled
            )
        }
    }
}

struct EnterPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        // Create a mock view model instance
        let mockViewModel = MockForgotPasswordViewModel()

        // Set initial state for the preview
        mockViewModel.newPassword = "password123"
        mockViewModel.confirmPassword = "password123"
        mockViewModel.isChangePasswordButtonEnabled = true

        // Return the EnterPinView with the mock view model
        return EnterPasswordView(viewModel: mockViewModel)
    }
}
