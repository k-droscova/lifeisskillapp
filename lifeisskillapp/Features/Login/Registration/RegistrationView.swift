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
                    Group {
                        referenceSection
                        consentToggles
                    }
                    .padding(.horizontal, RegistrationViewConstants.toggleSectionPadding)
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
    
    // MARK: - Reference Section
    
    private var referenceSection: some View {
        VStack(spacing: RegistrationViewConstants.referenceSectionVerticalSpacing) {
            referenceToggle
            if (viewModel.addReference) {
                HStack {
                    referenceInfo
                    Spacer(minLength: RegistrationViewConstants.referenceSectionHorizontalSpacing)
                    qrButton
                }
                .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: RegistrationViewConstants.animationDuration), value: viewModel.addReference)
    }
    
    private var referenceInfo: some View {
        VStack(alignment: .leading, spacing: RegistrationViewConstants.referenceUserInfoVerticalSpacing) {
            Text("registration.reference.user")
                .subheadline
            referenceUsername
                .body2Regular
        }
    }
    
    private var referenceUsername: some View {
        if let referenceUsername = viewModel.referenceUsername {
            Text(referenceUsername)
        } else {
            Text("registration.reference.user.placeholder")
        }
    }
    
    private var qrButton: some View {
        HomeButton(
            action: viewModel.scanQR,
            background: RegistrationViewConstants.Colors.qrBackground,
            foregroundColor: RegistrationViewConstants.Colors.qrForeground
        ) {
            SFSSymbols.qr.image
                .squareFrame(size: RegistrationViewConstants.qrButtonIconSize)
        }
    }
    
    private var referenceToggle: some View {
        Toggle(isOn: $viewModel.addReference) {
            // Content of the label
            HStack(spacing: RegistrationViewConstants.referenceToggleSpacing) {
                Text("registration.reference.title")
                Button(action: {
                    viewModel.showReferenceInstructions()
                }) {
                    SFSSymbols.instructionsPopover.image
                        .tint(.colorLisBlue)
                }
            }
        }
        .toggleStyle(SwitchToggleStyle(tint: RegistrationViewConstants.Colors.toggles)) // Apply custom color
        .headline3
    }
    
    // MARK: - Consent Toggles
    
    private var consentToggles: some View {
        VStack(alignment: .leading, spacing: RegistrationViewConstants.formSpacing) {
            Text("register.consent")
                .headline3
            
            HStack(spacing: RegistrationViewConstants.consentToggleHorizontalSpacing) {
                Toggle(isOn: $viewModel.isGdprConfirmed) {
                    Link(LocalizedStringKey("register.consent.gdpr"), destination: URL(string: APIUrl.gdprUrl)!)
                }
                .toggleStyle(SwitchToggleStyle(tint: RegistrationViewConstants.Colors.toggles))
                Toggle(isOn: $viewModel.isRulesConfirmed) {
                    Link(LocalizedStringKey("register.consent.rules"), destination: URL(string: APIUrl.rulesUrl)!)
                }
                .toggleStyle(SwitchToggleStyle(tint: RegistrationViewConstants.Colors.toggles))
            }
            .body1Regular
        }
        .padding(.top, RegistrationViewConstants.consentTopPadding)
    }
    
    // MARK: - Submit Button
    
    private var submitButton: some View {
        EnablingButton(
            action: viewModel.submitRegistration,
            text: "register.button",
            isEnabled: viewModel.isFormValid
        )
        .disabled(!viewModel.isFormValid)
        .padding(.vertical, RegistrationViewConstants.submitButtonVerticalPadding)
    }
}

struct RegistrationViewConstants {
    static let horizontalPadding: CGFloat = 16
    static let toggleSectionPadding: CGFloat = 12
    static let formSpacing: CGFloat = 16
    static let consentToggleHorizontalSpacing: CGFloat = 32
    static let consentTopPadding: CGFloat = 32
    static let submitButtonVerticalPadding: CGFloat = 32
    
    static let referenceSectionVerticalSpacing: CGFloat = 12
    static let referenceSectionHorizontalSpacing: CGFloat = 32
    static let referenceUserInfoVerticalSpacing: CGFloat = 4
    static let referenceToggleSpacing: CGFloat = 16
    
    static let qrButtonIconSize: CGFloat = 8
    static let animationDuration: Double = 0.3
    
    enum Colors {
        static let qrForeground = Color.white
        static let qrBackground = Color.colorLisBlue
        static let toggles = Color.colorLisGreen
    }
}

class MockRegistrationViewModel: BaseClass, RegistrationViewModeling {
    // Required properties
    var isLoading: Bool = false
    var username: String = ""
    var email: String = ""
    var password: String = ""
    var passwordConfirm: String = ""
    var isGdprConfirmed: Bool = false
    var isRulesConfirmed: Bool = false
    var addReference: Bool = true
    var referenceUsername: String?
    
    var usernameValidationState: ValidationState = UsernameValidationState.initial
    var emailValidationState: ValidationState = EmailValidationState.initial
    var passwordValidationState: ValidationState = PasswordValidationState.initial
    var confirmPasswordValidationState: ValidationState = ConfirmPasswordValidationState.initial
    
    var isFormValid: Bool = false

    // Required methods
    func submitRegistration() {
        print("Mock submit registration")
    }
    
    func showReferenceInstructions() {
        print("Mock show reference instructions")
    }
    
    func scanQR() {
        print("Mock scan QR code")
    }
}

struct RegistrationView_Previews: PreviewProvider {
    static var previews: some View {
        // Use the mock view model in the preview
        RegistrationView(viewModel: MockRegistrationViewModel())
    }
}
