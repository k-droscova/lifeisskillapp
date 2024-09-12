//
//  FullRegistrationView.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 05.09.2024.
//

import SwiftUI

struct FullRegistrationView<ViewModel: FullRegistrationViewModeling>: View {
    @StateObject var viewModel: ViewModel
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: FullRegistrationViewConstants.verticalSpacingBetweenSections) {
                    userInfo
                    if viewModel.isMinor {
                        guardianInfo
                    }
                    submitButton
                }
                .frame(width: geometry.size.width)
                .frame(minHeight: geometry.size.height)
            }
        }
        .padding(.top, FullRegistrationViewConstants.topPadding)
        .padding(.horizontal, FullRegistrationViewConstants.horizontalPadding)
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
    
    // MARK: - Submit Button
    
    private var submitButton: some View {
        EnablingButton(
            action: viewModel.submitFullRegistration,
            text: "register.submit_button",
            isEnabled: viewModel.isFormValid
        )
        .disabled(!viewModel.isFormValid)
        .padding(.vertical, FullRegistrationViewConstants.submitButtonVerticalPadding)
    }
}

// MARK: User Section

private extension FullRegistrationView {
    private var userInfo: some View {
        Section(
            header: Text("register.user_info.title")
                .headline2
        ) {
            VStack(spacing: FullRegistrationViewConstants.verticalSpacingBetweenUserFields) {
                Text("register.user_info.instructions")
                    .multilineTextAlignment(.center)
                formFields
            }
        }
    }
    
    private var formFields: some View {
        VStack(spacing: FullRegistrationViewConstants.verticalSpacingBetweenFormFields) {
            firstName
            secondName
            phoneNumberAndPostalCode
            Group {
                genderPicker
                    .padding(.horizontal, FullRegistrationViewConstants.genderPickerHorizontalPadding)
                birthDayPicker
            }
        }
    }
    
    private var firstName: some View {
        CustomTextField(
            placeholder: "register.first_name",
            text: $viewModel.firstName,
            showsValidationMessage: true,
            validationMessage: viewModel.firstNameValidationState.validationMessage
        )
    }
    
    private var secondName: some View {
        CustomTextField(
            placeholder: "register.last_name",
            text: $viewModel.lastName,
            showsValidationMessage: true,
            validationMessage: viewModel.lastNameValidationState.validationMessage
        )
    }
    
    private var phoneNumberAndPostalCode: some View {
        HStack(spacing: FullRegistrationViewConstants.horizontalSpacingBetweenPhoneAndPostalCode) {
            CustomTextField(
                placeholder: "register.phone_number",
                text: $viewModel.phoneNumber,
                showsValidationMessage: true,
                validationMessage: viewModel.phoneNumberValidationState.validationMessage
            )
            CustomTextField(
                placeholder: "register.postal_code",
                text: $viewModel.postalCode,
                showsValidationMessage: true,
                validationMessage: viewModel.postalCodeValidationState.validationMessage
            )
        }
    }
    
    private var genderPicker: some View {
        HStack {
            Text("register.gender")
                .subheadlineBold
            Spacer()
            Picker("register.gender", selection: $viewModel.gender) {
                // full registration enables just 2 genders, nonspecified is reserved for incomplete registration only
                Text("register.gender.male").tag(UserGender.male)
                Text("register.gender.female").tag(UserGender.female)
            }
            .pickerStyle(.automatic)
            .tint(.colorLisBlue)
        }
    }
    
    private var birthDayPicker: some View {
        VStack(alignment: .leading, spacing: FullRegistrationViewConstants.verticalSpacingBetweenBirthdayInstructionsAndAge) {
            Text("register.date_of_birth.instructions")
                .subheadlineBold
            Text(
                LocalizedStringKey(
                    String(format: NSLocalizedString("register.date_of_birth.age:", comment: ""), String(viewModel.age))))
            .caption
            DatePicker("register.date_of_birth",
                       selection: $viewModel.dateOfBirth,
                       in: ...Date(),
                       displayedComponents: .date)
            .labelsHidden()
            .datePickerStyle(.wheel)
        }
    }
}

// MARK: Guardian Section

private extension FullRegistrationView {
    private var guardianInfo: some View {
        Section(
            header: Text("register.guardian_info")
                .headline2
        ) {
            guardianFields
        }
    }
    
    private var guardianFields: some View {
        VStack(spacing: FullRegistrationViewConstants.verticalSpacingBetweenGuardianFields) {
            guardianFirstName
            guardianSecondName
            email
            phoneAndRelationship
        }
    }
    
    private var guardianFirstName: some View {
        CustomTextField(
            placeholder: "register.first_name",
            text: $viewModel.guardianFirstName,
            showsValidationMessage: true,
            validationMessage: viewModel.guardianFirstNameValidationState.validationMessage
        )
    }
    
    private var guardianSecondName: some View {
        CustomTextField(
            placeholder: "register.last_name",
            text: $viewModel.guardianLastName,
            showsValidationMessage: true,
            validationMessage: viewModel.guardianLastNameValidationState.validationMessage
        )
    }
    
    private var phoneAndRelationship: some View {
        HStack(spacing: FullRegistrationViewConstants.horizontalSpacingBetweenPhoneAndEmail) {
            CustomTextField(
                placeholder: "register.phone_number",
                text: $viewModel.guardianPhoneNumber,
                showsValidationMessage: true,
                validationMessage: viewModel.guardianPhoneNumberValidationState.validationMessage
            )
            
            CustomTextField(
                placeholder: "register.guardian_relationship",
                text: $viewModel.guardianRelationship,
                showsValidationMessage: true,
                validationMessage: viewModel.guardianRelationshipValidationState.validationMessage
            )
        }
    }
    
    private var email: some View {
        CustomTextField(
            placeholder: "register.email",
            text: $viewModel.guardianEmail,
            showsValidationMessage: true,
            validationMessage: viewModel.guardianEmailValidationState.validationMessage
        )
    }
}

// MARK: - Constants

struct FullRegistrationViewConstants {
    static let horizontalPadding: CGFloat = 24
    static let topPadding: CGFloat = 32
    static let submitButtonVerticalPadding: CGFloat = 16
    // Spacing constants
    static let verticalSpacingBetweenSections: CGFloat = 16
    static let verticalSpacingBetweenUserFields: CGFloat = 24
    static let verticalSpacingBetweenFormFields: CGFloat = 16
    static let horizontalSpacingBetweenPhoneAndPostalCode: CGFloat = 16
    static let horizontalSpacingBetweenPhoneAndEmail: CGFloat = 16
    static let verticalSpacingBetweenBirthdayInstructionsAndAge: CGFloat = 4
    static let verticalSpacingBetweenGuardianFields: CGFloat = 16
    static let genderPickerHorizontalPadding: CGFloat = 12
}

class MockFullRegistrationViewModel: BaseClass, FullRegistrationViewModeling {
    var age: Int = 14
    
    // Required properties
    var isLoading: Bool = false
    
    // User info
    var firstName: String = ""
    var lastName: String = ""
    var phoneNumber: String = ""
    var countryCode: String = "+1"
    var dateOfBirth: Date = Date()
    var isMinor: Bool = true
    var postalCode: String = ""
    var gender: UserGender = .unspecified
    
    // Guardian info
    var guardianFirstName: String = ""
    var guardianLastName: String = ""
    var guardianPhoneNumber: String = ""
    var guardianCountryCode: String = "+1"
    var guardianEmail: String = ""
    var guardianRelationship: String = ""
    
    // Validation states
    var firstNameValidationState: ValidationState = BasicValidationState.initial
    var lastNameValidationState: ValidationState = BasicValidationState.initial
    var phoneNumberValidationState: ValidationState = PhoneNumberValidationState.initial
    var postalCodeValidationState: ValidationState = BasicValidationState.initial
    var guardianFirstNameValidationState: ValidationState = BasicValidationState.initial
    var guardianLastNameValidationState: ValidationState = BasicValidationState.initial
    var guardianPhoneNumberValidationState: ValidationState = PhoneNumberValidationState.initial
    var guardianEmailValidationState: ValidationState = EmailValidationState.initial
    var guardianRelationshipValidationState: ValidationState = BasicValidationState.initial
    
    var isFormValid: Bool = true
    
    // Methods
    func submitFullRegistration() {
        print("Full registration submitted")
    }
}

struct FullRegistrationView_Previews: PreviewProvider {
    static var previews: some View {
        FullRegistrationView(viewModel: MockFullRegistrationViewModel())
    }
}
