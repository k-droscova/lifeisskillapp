//
//  RegistrationViewModel.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 30.08.2024.
//

import Foundation
import Combine

struct RegistrationCredentials {
    let username: String
    let email: String
    let password: String
}

protocol RegistrationViewModelDelegate: AnyObject {
    func registrationDidSucceed()
    func registrationDidFail()
}

protocol RegistrationViewModeling: BaseClass, ObservableObject {
    var delegate: RegistrationViewModelDelegate? { get set }
    
    var username: String { get set }
    var email: String { get set }
    var password: String { get set }
    var passwordConfirm: String { get set }
    var isGdprConfirmed: Bool { get set }
    var isConsentGiven: Bool { get set }
    
    var usernameValidationState: ValidationState { get }
    var emailValidationState: ValidationState { get }
    var passwordValidationState: ValidationState { get }
    var confirmPasswordValidationState: ValidationState { get }
    var isFormValid: Bool { get }
    
    func submitRegistration()
}

class RegistrationViewModel: BaseClass, ObservableObject, RegistrationViewModeling {
    typealias Dependencies = HasLoggers & HasUserManager
    
    // MARK: - Private Properties
    
    private let logger: LoggerServicing
    private let userManager: UserManaging
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Public Properties
    
    weak var delegate: RegistrationViewModelDelegate?
    
    @Published var username: String = "" {
        didSet {
            validateUsername()
        }
    }
    @Published var email: String = "" {
        didSet {
            validateEmail()
        }
    }
    @Published var password: String = "" {
        didSet {
            validatePassword()
        }
    }
    @Published var passwordConfirm: String = "" {
        didSet {
            validateConfirmPassword()
        }
    }
    
    @Published var isGdprConfirmed: Bool = false
    @Published var isConsentGiven: Bool = false
    
    @Published private(set) var usernameValidationState: ValidationState = UsernameValidationState.initial
    @Published private(set) var emailValidationState: ValidationState = EmailValidationState.initial
    @Published private(set) var passwordValidationState: ValidationState = PasswordValidationState.initial
    @Published private(set) var confirmPasswordValidationState: ValidationState = ConfirmPasswordValidationState.initial
    
    var isFormValid: Bool {
        usernameValidationState.isValid &&
        emailValidationState.isValid &&
        passwordValidationState.isValid &&
        confirmPasswordValidationState.isValid &&
        isGdprConfirmed && isConsentGiven
    }
    
    // MARK: - Initialization
    
    init(dependencies: Dependencies, delegate: RegistrationViewModelDelegate? = nil) {
        self.logger = dependencies.logger
        self.userManager = dependencies.userManager
        self.delegate = delegate
    }
    
    // MARK: - Private Helpers
    
    private func validateUsername() {
        if username.isEmpty {
            usernameValidationState = UsernameValidationState.empty
        } else if username.count < Username.minLength {
            usernameValidationState = UsernameValidationState.short
        } else if isUsernameTaken(username) {
            usernameValidationState = UsernameValidationState.alreadyTaken
        } else {
            usernameValidationState = UsernameValidationState.valid
        }
    }
    
    private func validateEmail() {
        if email.isEmpty {
            emailValidationState = EmailValidationState.empty
        } else if !isValidEmailFormat(email) {
            emailValidationState = EmailValidationState.invalidFormat
        } else if isEmailTaken(email) {
            emailValidationState = EmailValidationState.alreadyTaken
        } else {
            emailValidationState = EmailValidationState.valid
        }
    }
    
    private func validatePassword() {
        if password.isEmpty {
            passwordValidationState = PasswordValidationState.empty
        } else if password.count < Password.minLenght {
            passwordValidationState = PasswordValidationState.invalidFormat
        } else {
            passwordValidationState = PasswordValidationState.valid
        }
    }
    
    private func validateConfirmPassword() {
        if password != passwordConfirm {
            confirmPasswordValidationState = ConfirmPasswordValidationState.mismatching
        } else {
            confirmPasswordValidationState = ConfirmPasswordValidationState.valid
        }
    }
    
    // TODO: implement api checks
    private func isUsernameTaken(_ username: String) -> Bool {
        let takenUsernames = ["user1", "user2", "takenUser"]
        return takenUsernames.contains(username)
    }
    
    // TODO: implement api checks
    private func isEmailTaken(_ email: String) -> Bool {
        let takenEmails = ["test@example.com", "user@example.com"]
        return takenEmails.contains(email)
    }
    
    private func isValidEmailFormat(_ email: String) -> Bool {
        let emailPred = NSPredicate(format: "SELF MATCHES %@", Email.emailPattern)
        return emailPred.evaluate(with: email)
    }
    
    // MARK: - Public Methods
    
    func submitRegistration() {
        guard isFormValid else {
            logger.log(message: "Form is not valid")
            delegate?.registrationDidFail()
            return
        }
        // TODO: implement api registration
        // Simulate registration process
        /*
         let credentials = RegistrationCredentials(username: username, email: email, password: password)
         userManager.registerUser(with: credentials) { [weak self] success in
         if success {
         self?.delegate?.registrationDidSucceed()
         } else {
         self?.delegate?.registrationDidFail()
         }
         }
         */
        delegate?.registrationDidSucceed()
    }
}
