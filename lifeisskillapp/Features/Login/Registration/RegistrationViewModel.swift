//
//  RegistrationViewModel.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 30.08.2024.
//

import Foundation
import Combine

protocol RegistrationViewModeling: BaseClass, ObservableObject {
    var isLoading: Bool { get }
    var username: String { get set }
    var email: String { get set }
    var password: String { get set }
    var passwordConfirm: String { get set }
    var isGdprConfirmed: Bool { get set }
    var isRulesConfirmed: Bool { get set }
    var addReference: Bool { get set }
    var referenceUsername: String? { get }
    
    var usernameValidationState: ValidationState { get }
    var emailValidationState: ValidationState { get }
    var passwordValidationState: ValidationState { get }
    var confirmPasswordValidationState: ValidationState { get }
    var isFormValid: Bool { get }
    
    func submitRegistration()
    func showReferenceInstructions()
    func scanQR()
    func rulesButtonClicked()
    func gdprButtonClicked()
}

class RegistrationViewModel: BaseClass, ObservableObject, RegistrationViewModeling {
    typealias Dependencies = HasLoggers & HasUserManager
    
    // MARK: - Private Properties
    
    private weak var delegate: RegistrationFlowDelegate?
    private let logger: LoggerServicing
    private let userManager: UserManaging
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Public Properties
    
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
    @Published var isRulesConfirmed: Bool = false
    @Published var addReference: Bool = false
    @Published private(set) var referenceUsername: String?
    
    @Published private(set) var usernameValidationState: ValidationState = UsernameValidationState.initial
    @Published private(set) var emailValidationState: ValidationState = EmailValidationState.initial
    @Published private(set) var passwordValidationState: ValidationState = PasswordValidationState.initial
    @Published private(set) var confirmPasswordValidationState: ValidationState = ConfirmPasswordValidationState.initial
    
    var isFormValid: Bool {
        usernameValidationState.isValid &&
        emailValidationState.isValid &&
        passwordValidationState.isValid &&
        confirmPasswordValidationState.isValid &&
        isGdprConfirmed && isRulesConfirmed
    }
    
    // MARK: - Initialization
    
    init(dependencies: Dependencies, delegate: RegistrationFlowDelegate? = nil) {
        self.logger = dependencies.logger
        self.userManager = dependencies.userManager
        self.delegate = delegate
    }
    
    // MARK: - Public Interface
    
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
            let credentials = NewRegistrationCredentials(username: username, email: email, password: password)
            do {
                try await self.userManager.registerUser(credentials: credentials)
                self.delegate?.registrationDidSucceed()
            } catch {
                self.delegate?.registrationDidFail()
            }
        }
    }
    
    func showReferenceInstructions() {
        print("instructions pressed")
        delegate?.showReferenceInstructions()
    }
    
    func scanQR() {
        print("qr pressed")
        delegate?.loadQR()
    }
    
    func gdprButtonClicked() {
        openLink(link: APIUrl.gdprUrl)
    }
    
    func rulesButtonClicked() {
        openLink(link: APIUrl.rulesUrl)
    }
    
    // MARK: - Private Helpers
    
    private func openLink(link: String) {
        delegate?.openLink(link: link)
    }
    
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
}
