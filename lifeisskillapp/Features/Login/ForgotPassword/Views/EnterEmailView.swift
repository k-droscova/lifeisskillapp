//
//  EnterEmailView.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 26.08.2024.
//

import SwiftUI

struct EnterEmailView<ViewModel: ForgotPasswordViewModeling>: View {
    @StateObject var viewModel: ViewModel

    var body: some View {
        ForgotPasswordPageView(
            text: Text("forgot_password.instructions.email")
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

private extension EnterEmailView {
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
            "forgot_password.textfield.username",
            text: $viewModel.email
        )
        .autocapitalization(.none)
        .disableAutocorrection(true)
        .padding()
        .background(ForgotPasswordPagesConstants.Colors.textFieldBackground)
        .cornerRadius(ForgotPasswordPagesConstants.cornerRadius)
    }

    private var buttonView: some View {
        HStack {
            Spacer()

            EnablingButton(
                action: {
                    viewModel.sendEmail()
                },
                text: "forgot_password.button.confirm",
                isEnabled: viewModel.isSendEmailButtonEnabled
            )
        }
    }
}

struct EnterEmailView_Previews: PreviewProvider {
    static var previews: some View {
        // Create a mock view model instance
        let mockViewModel = MockForgotPasswordViewModel()

        // Set initial state for the preview
        mockViewModel.email = "test@example.com"
        mockViewModel.isSendEmailButtonEnabled = true

        // Return the EnterEmailView with the mock view model
        return EnterEmailView(viewModel: mockViewModel)
    }
}
