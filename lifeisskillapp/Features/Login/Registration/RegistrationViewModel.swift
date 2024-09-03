//
//  RegistrationViewModel.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 30.08.2024.
//

import Foundation
import Combine

protocol RegistrationViewModelDelegate: AnyObject {
    func registrationDidSucceed()
    func registrationDidFail()
}

protocol RegistrationViewModeling: BaseClass, ObservableObject {
    var delegate: RegistrationViewModelDelegate? { get set }
    
    var isLoading: Bool { get }
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
    @Published private(set) var isLoading: Bool = false
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
        Task { @MainActor [weak self] in
            guard let self = self else { return }
            if self.username.isEmpty {
                self.usernameValidationState = UsernameValidationState.empty
            } else if self.username.count < Username.minLength {
                self.usernameValidationState = UsernameValidationState.short
            } else if await !self.isUsernameAvailable(self.username) {
                self.usernameValidationState = UsernameValidationState.alreadyTaken
            } else {
                self.usernameValidationState = UsernameValidationState.valid
            }
        }
    }
    
    private func validateEmail() {
        Task { @MainActor [weak self] in
            guard let self = self else { return }
            if self.email.isEmpty {
                self.emailValidationState = EmailValidationState.empty
            } else if !self.isValidEmailFormat(email) {
                self.emailValidationState = EmailValidationState.invalidFormat
            } else if await !self.isEmailAvailable(email) {
                self.emailValidationState = EmailValidationState.alreadyTaken
            } else {
                self.emailValidationState = EmailValidationState.valid
            }
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
    
    private func isUsernameAvailable(_ username: String) async -> Bool {
        do {
            return try await userManager.checkUsernameAvailability(username)
        } catch {
            logger.log(message: "Unable to check username \(username)")
            return false // will result in error upon final registration, but enables smoother registration process
        }
    }
    
    private func isEmailAvailable(_ email: String) async -> Bool {
#if DEBUG
        return true
#else
        do {
            return try await userManager.checkEmailAvailability(email)
        } catch {
            logger.log(message: "Unable to check email \(email)")
            return false // will result in error upon final registration, but enables smoother registration process
        }
#endif
    }
    
    private func isValidEmailFormat(_ email: String) -> Bool {
        let emailPred = NSPredicate(format: "SELF MATCHES %@", Email.emailPattern)
        return emailPred.evaluate(with: email)
    }
    
    // MARK: - Public Methods
    
    func submitRegistration() {
        Task { @MainActor [weak self] in
            guard let self = self else { return }
            self.isLoading = true
            defer { self.isLoading = false }
            guard self.isFormValid else {
                self.logger.log(message: "Form is not valid")
                self.delegate?.registrationDidFail()
                return
            }
            let credentials = RegistrationCredentials(username: username, email: email, password: password)
            do {
                try await self.userManager.registerUser(credentials: credentials)
                self.delegate?.registrationDidSucceed()
            } catch {
                self.delegate?.registrationDidFail()
            }
        }
    }
}
