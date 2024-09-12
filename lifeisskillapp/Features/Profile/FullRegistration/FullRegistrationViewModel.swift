//
//  FullRegistrationViewModel.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 05.09.2024.
//

import Foundation

protocol FullRegistrationViewModeling: BaseClass, ObservableObject {
    
    var isLoading: Bool { get }
    // User info fields
    var firstName: String { get set }
    var lastName: String { get set }
    var phoneNumber: String { get set }
    var dateOfBirth: Date { get set }
    var isMinor: Bool { get }
    var age: Int { get }
    var postalCode: String { get set }
    var gender: UserGender { get set }
    
    // Guardian info fields
    var guardianFirstName: String { get set }
    var guardianLastName: String { get set }
    var guardianPhoneNumber: String { get set }
    var guardianEmail: String { get set }
    var guardianRelationship: String { get set }
    
    // Validation States
    var firstNameValidationState: ValidationState { get }
    var lastNameValidationState: ValidationState { get }
    var phoneNumberValidationState: ValidationState { get }
    var postalCodeValidationState: ValidationState { get }
    var guardianFirstNameValidationState: ValidationState { get }
    var guardianLastNameValidationState: ValidationState { get }
    var guardianPhoneNumberValidationState: ValidationState { get }
    var guardianEmailValidationState: ValidationState { get }
    var guardianRelationshipValidationState: ValidationState { get }
    
    var isFormValid: Bool { get }
    func submitFullRegistration()
}

public final class FullRegistrationViewModel: BaseClass, ObservableObject, FullRegistrationViewModeling {
    typealias Dependencies = HasLoggers & HasUserManager
    
    // MARK: - Private Properties
    private weak var delegate: FullRegistrationFlowDelegate?
    private let logger: LoggerServicing
    private let userManager: UserManaging
    private var isGuardianFormValid: Bool {
        guard isMinor else { return true }
        return guardianFirstNameValidationState.isValid
        && guardianLastNameValidationState.isValid
        && guardianPhoneNumberValidationState.isValid
        && guardianEmailValidationState.isValid
        && guardianRelationshipValidationState.isValid
    }
    private var fullRegistrationInfo: FullRegistrationCredentials {
        let guardian: GuardianInfo? = isMinor ? GuardianInfo(
            firstName: guardianFirstName,
            lastName: guardianLastName,
            phoneNumber: guardianPhoneNumber,
            email: guardianEmail,
            relationship: guardianRelationship
        ) : nil
        
        return FullRegistrationCredentials(
            firstName: firstName,
            lastName: lastName,
            phoneNumber: phoneNumber,
            dateOfBirth: dateOfBirth,
            gender: gender,
            postalCode: postalCode,
            guardianInfo: guardian
        )
    }
    
    // MARK: - Public Properties
    
    @Published private(set) var isLoading: Bool = false
    @Published var firstName: String = "" { didSet { validateFirstName() } }
    @Published var lastName: String = "" { didSet { validateLastName() } }
    @Published var phoneNumber: String = "" { didSet { validatePhoneNumber() } }
    @Published var dateOfBirth: Date = Date() { didSet { updateUserAge() } }
    var isMinor: Bool { age < User.ageWhenConsideredNotMinor }
    @Published var age: Int = 0
    @Published var postalCode: String = "" { didSet { validatePostalCode() } }
    @Published var gender: UserGender = .male
    @Published var guardianFirstName: String = "" { didSet { validateGuardianFirstName() } }
    @Published var guardianLastName: String = "" { didSet { validateGuardianLastName() } }
    @Published var guardianPhoneNumber: String = "" { didSet { validateGuardianPhoneNumber() } }
    @Published var guardianEmail: String = "" { didSet { validateGuardianEmail() } }
    @Published var guardianRelationship: String = "" { didSet { validateGuardianRelationship() } }
    
    // Validation States
    @Published private(set) var firstNameValidationState: ValidationState = BasicValidationState.initial
    @Published private(set) var lastNameValidationState: ValidationState = BasicValidationState.initial
    @Published private(set) var phoneNumberValidationState: ValidationState = PhoneNumberValidationState.initial
    @Published private(set) var postalCodeValidationState: ValidationState = BasicValidationState.initial
    @Published private(set) var guardianFirstNameValidationState: ValidationState = BasicValidationState.initial
    @Published private(set) var guardianLastNameValidationState: ValidationState = BasicValidationState.initial
    @Published private(set) var guardianPhoneNumberValidationState: ValidationState = PhoneNumberValidationState.initial
    @Published private(set) var guardianEmailValidationState: ValidationState = GuardianEmailValidationState.base(.initial)
    @Published private(set) var guardianRelationshipValidationState: ValidationState = BasicValidationState.initial
    
    var isFormValid: Bool {
        firstNameValidationState.isValid
        && lastNameValidationState.isValid
        && phoneNumberValidationState.isValid
        && postalCodeValidationState.isValid
        && isGuardianFormValid
    }
    
    // MARK: - Initialization
    init(dependencies: Dependencies, delegate: FullRegistrationFlowDelegate? = nil) {
        self.logger = dependencies.logger
        self.userManager = dependencies.userManager
        self.delegate = delegate
        
#if DEBUG
        self.firstName = "TestFirstName"
        self.lastName = "TestLastName"
        self.phoneNumber = "123456789"
        self.dateOfBirth = Date.Backend.fromBirthday(dateString: "2017-01-01") ?? Date()
        self.postalCode = "12345"
        self.guardianFirstName = "TestParentFirstName"
        self.guardianLastName = "TestParentLastName"
        self.guardianPhoneNumber = "123456789"
        self.guardianEmail = "drosckar@cvut.cz"
        self.guardianRelationship = "test"
#endif
    }
    
    // MARK: - Public Methods
    func submitFullRegistration() {
        Task { @MainActor [weak self] in
            guard let self = self else { return }
            isLoading = true
            defer { isLoading = false }
            guard isFormValid else {
                logger.log(message: "Full registration form is not valid")
                return
            }
            do {
                let response = try await userManager.completeUserRegistration(credentials: fullRegistrationInfo)
                guard response.needParentActivation else {
                    delegate?.registrationDidSucceedAdult()
                    return
                }
                delegate?.registrationDidSucceedMinor()
            } catch {
                logger.log(message: "Failed to complete full registration")
                delegate?.registrationDidFail()
            }
        }
    }
    
    // MARK: - Private Helpers
    
    private func collectFullRegistrationInfo() -> FullRegistrationCredentials {
        let guardian: GuardianInfo? = isMinor ? GuardianInfo(
            firstName: guardianFirstName,
            lastName: guardianLastName,
            phoneNumber: guardianPhoneNumber,
            email: guardianEmail,
            relationship: guardianRelationship
        ) : nil
        
        return FullRegistrationCredentials(
            firstName: firstName,
            lastName: lastName,
            phoneNumber: phoneNumber,
            dateOfBirth: dateOfBirth,
            gender: gender,
            postalCode: postalCode,
            guardianInfo: guardian
        )
    }
    
    // Validation Logic
    private func validateFirstName() {
        firstNameValidationState = firstName.isEmpty ? BasicValidationState.empty : BasicValidationState.valid
    }
    
    private func validateLastName() {
        lastNameValidationState = lastName.isEmpty ? BasicValidationState.empty : BasicValidationState.valid
    }
    
    private func validatePhoneNumber() {
        if phoneNumber.isEmpty {
            phoneNumberValidationState = PhoneNumberValidationState.empty
        } else if !isValidPhoneNumber(phoneNumber) {
            phoneNumberValidationState = PhoneNumberValidationState.invalidFormat
        } else {
            phoneNumberValidationState = PhoneNumberValidationState.valid
        }
    }
    
    private func updateUserAge() {
        age = dateOfBirth.age ?? 0
    }
    
    private func validatePostalCode() {
        postalCodeValidationState = postalCode.isEmpty ? BasicValidationState.empty : BasicValidationState.valid
    }
    
    private func validateGuardianFirstName() {
        guardianFirstNameValidationState = guardianFirstName.isEmpty ? BasicValidationState.empty : BasicValidationState.valid
    }
    
    private func validateGuardianLastName() {
        guardianLastNameValidationState = guardianLastName.isEmpty ? BasicValidationState.empty : BasicValidationState.valid
    }
    
    private func validateGuardianPhoneNumber() {
        if guardianPhoneNumber.isEmpty {
            guardianPhoneNumberValidationState = PhoneNumberValidationState.empty
        } else if !isValidPhoneNumber(guardianPhoneNumber) {
            guardianPhoneNumberValidationState = PhoneNumberValidationState.invalidFormat
        } else {
            guardianPhoneNumberValidationState = PhoneNumberValidationState.valid
        }
    }
    
    private func validateGuardianEmail() {
        if guardianEmail.isEmpty {
            guardianEmailValidationState = GuardianEmailValidationState.base(.empty)
        } else if !isValidEmailFormat(guardianEmail) {
            guardianEmailValidationState = GuardianEmailValidationState.base(.invalidFormat)
        } else if matchesUserEmail() {
            guardianEmailValidationState = GuardianEmailValidationState.matchesUserEmail
        } else {
            guardianEmailValidationState = GuardianEmailValidationState.base(.valid)
        }
    }
    
    private func validateGuardianRelationship() {
        guardianRelationshipValidationState = guardianRelationship.isEmpty ? BasicValidationState.empty : BasicValidationState.valid
    }
    
    private func isValidPhoneNumber(_ phoneNumber: String) -> Bool {
        // TODO: think about foreign numbers...
        let phonePred = NSPredicate(format: "SELF MATCHES %@", Phone.phonePattern)
        return phonePred.evaluate(with: phoneNumber)
    }
    
    private func isValidEmailFormat(_ email: String) -> Bool {
        let emailPred = NSPredicate(format: "SELF MATCHES %@", Email.emailPattern)
        return emailPred.evaluate(with: email)
    }
    
    private func matchesUserEmail() -> Bool {
        userManager.loggedInUser?.email == guardianEmail
    }
}
