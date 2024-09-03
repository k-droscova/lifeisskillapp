//
//  EnterPinView.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 26.08.2024.
//

import SwiftUI

struct EnterPinView<ViewModel: ForgotPasswordViewModeling>: View {
    @StateObject var viewModel: ViewModel

    var body: some View {
        ForgotPasswordPageView(
            text: Text("forgot_password.instructions.pin")
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

private extension EnterPinView {
    private var contentView: some View {
        VStack() {
            textFieldView
            Spacer()
            buttonView
        }
        .padding(.bottom, ForgotPasswordPagesConstants.bottomPadding)
    }

    private var textFieldView: some View {
        TextField(
            "forgot_password.textfield.pin",
            text: $viewModel.pin
        )
        .autocapitalization(.none)
        .disableAutocorrection(true)
        .padding()
        .background(ForgotPasswordPagesConstants.Colors.textFieldBackground)
        .cornerRadius(ForgotPasswordPagesConstants.cornerRadius)
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
                    viewModel.validatePin()
                },
                text: "forgot_password.button.confirm",
                isEnabled: viewModel.isConfirmPinButtonEnabled
            )
        }
    }
}

struct EnterPinView_Previews: PreviewProvider {
    static var previews: some View {
        // Create a mock view model instance
        let mockViewModel = MockForgotPasswordViewModel()

        // Set initial state for the preview
        mockViewModel.email = "test@example.com"
        mockViewModel.isSendEmailButtonEnabled = true

        // Return the EnterEmailView with the mock view model
        return EnterPinView(viewModel: mockViewModel)
    }
}
