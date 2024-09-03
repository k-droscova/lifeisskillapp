//
//  RegistrationView.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 30.08.2024.
//

import SwiftUI

struct RegistrationView<ViewModel: RegistrationViewModeling>: View {
    @StateObject var viewModel: ViewModel
    
    var body: some View {
        GeometryReader { geometry in // centers content of scrollview
            ScrollView() {
                VStack() {
                    formFields
                    consentToggles
                    submitButton
                }
                .frame(width: geometry.size.width)
                .frame(minHeight: geometry.size.height)
            }
        }
        .padding(.horizontal, RegistrationViewConstants.horizontalPadding)
        .onTapGesture {
            hideKeyboard()
        }
        .overlay(
            Group {
                if viewModel.isLoading {
                    CustomProgressView()
                }
            }
        )
    }
    
    // MARK: - Form Fields
    
    private var formFields: some View {
        Group {
            CustomTextField(
                placeholder: "register.username",
                text: $viewModel.username,
                showsValidationMessage: true,
                validationMessage: viewModel.usernameValidationState.validationMessage
            )
            
            CustomTextField(
                placeholder: "register.email",
                text: $viewModel.email,
                showsValidationMessage: true,
                validationMessage: viewModel.emailValidationState.validationMessage
            )
            
            CustomTextField(
                placeholder: "register.password",
                text: $viewModel.password,
                isSecure: true,
                showsValidationMessage: true,
                validationMessage: viewModel.passwordValidationState.validationMessage
            )
            
            CustomTextField(
                placeholder: "register.password_confirm",
                text: $viewModel.passwordConfirm,
                isSecure: true,
                showsValidationMessage: true,
                validationMessage: viewModel.confirmPasswordValidationState.validationMessage
            )
        }
    }
    
    // MARK: - Consent Toggles
    
    private var consentToggles: some View {
        VStack(alignment: .leading, spacing: RegistrationViewConstants.formSpacing) {
            Text("register.consent")
                .headline3
            
            HStack(spacing: RegistrationViewConstants.consentToggleSpacing) {
                Toggle("register.consent.gdpr", isOn: $viewModel.isGdprConfirmed)
                Toggle("register.consent.rules", isOn: $viewModel.isConsentGiven)
            }
        }
        .padding(.horizontal, RegistrationViewConstants.consentTogglesPadding)
        .padding(.top, RegistrationViewConstants.formSpacing)
    }
    
    // MARK: - Submit Button
    
    private var submitButton: some View {
        EnablingButton(
            action: viewModel.submitRegistration,
            text: "register.button",
            isEnabled: viewModel.isFormValid
        )
        .disabled(!viewModel.isFormValid)
        .padding(.vertical, RegistrationViewConstants.submitButtonBottomPadding)
    }
}

struct RegistrationViewConstants {
    static let horizontalPadding: CGFloat = 16
    static let verticalPadding: CGFloat = 16
    static let formSpacing: CGFloat = 16
    static let consentToggleSpacing: CGFloat = 32
    static let consentTogglesPadding: CGFloat = 24
    static let submitButtonBottomPadding: CGFloat = 32
}
