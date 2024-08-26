//
//  ForgotPasswordViewModel.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 26.08.2024.
//

import Foundation
import Observation

protocol ForgotPasswordViewModelDelegate: NSObject {
    func didRequestNewPin()
    func didValidatePin()
    func didRenewPassword()
    func failedRenewPassword()
    func timerRanOut()
}

protocol ForgotPasswordViewModeling: BaseClass, ObservableObject {
    var delegate: ForgotPasswordViewModelDelegate? { get set }
    var email: String { get set }
    var pin: String { get set }
    var newPassword: String { get set }
    var confirmPassword: String { get set }
    var isSendButtonEnabled: Bool { get set }
    var isConfirmButtonEnabled: Bool { get set }
    var isChangePasswordButtonEnabled: Bool { get set }
    var isLoading: Bool { get set }

    func sendEmail()
    func validatePin()
    func changePassword()
}

final class ForgotPasswordViewModel: BaseClass, ForgotPasswordViewModeling, ObservableObject {
    typealias Dependencies = HasLoggers
    // MARK: - Private Properties

    private let logger: LoggerServicing
    //private var data: ForgotPasswordData? // TODO: implement fetching of data
    private var timer: Timer?
    private var timerExpirationDate: Date?

    // MARK: - Public Properties
    weak var delegate: ForgotPasswordViewModelDelegate?
    @Published var email: String = "" {
        didSet {
            isSendButtonEnabled = !email.isEmpty
        }
    }
    @Published var pin: String = "" {
        didSet {
            isConfirmButtonEnabled = !pin.isEmpty
        }
    }
    @Published var newPassword: String = "" {
        didSet {
            validatePasswords()
        }
    }
    @Published var confirmPassword: String = "" {
        didSet {
            validatePasswords()
        }
    }
    @Published var isSendButtonEnabled: Bool = false
    @Published var isConfirmButtonEnabled: Bool = false
    @Published var isChangePasswordButtonEnabled: Bool = false
    @Published var isLoading: Bool = false

    // MARK: - Initialization

    init(
        dependencies: Dependencies,
        delegate: ForgotPasswordViewModelDelegate? = nil
    ) {
        self.logger = dependencies.logger
        self.delegate = delegate
    }

    // MARK: - Public Interface

    func sendEmail() {
        isLoading = true
        // Simulate an API call to send the email
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.isLoading = false
            self.delegate?.didRequestNewPin()
            self.startPinExpirationTimer() // Start the 15-minute timer after the pin is received
        }
    }

    func validatePin() {
        isLoading = true
        // Simulate an API call to validate the PIN
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.isLoading = false
            self.invalidateTimer() // Invalidate the timer if the password is successfully changed
            self.delegate?.didValidatePin()
        }
    }

    func changePassword() {
        guard newPassword == confirmPassword else {
            // Handle mismatched passwords
            return
        }
        isLoading = true
        // Simulate an API call to change the password
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.isLoading = false
            self.delegate?.didRenewPassword()
        }
    }

    // MARK: - Private Gelpers

    private func validatePasswords() {
        isChangePasswordButtonEnabled = validatePasswordLength() && validatePasswordsMatch()
    }

    private func validatePasswordLength() -> Bool {
        newPassword.count >= Password.minLenght
    }

    private func validatePasswordsMatch() -> Bool {
        newPassword == confirmPassword
    }

    private func startPinExpirationTimer() {
        timerExpirationDate = Date().addingTimeInterval(15 * 60) // 15 minutes from now
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.checkTimer()
        }
    }

    private func checkTimer() {
        guard let expirationDate = timerExpirationDate else { return }
        if Date() >= expirationDate {
            self.invalidateTimer()
            self.delegate?.timerRanOut() // Notify delegate that the timer has expired
        }
    }

    private func invalidateTimer() {
        timer?.invalidate()
        timer = nil
        timerExpirationDate = nil
    }
}

class MockForgotPasswordViewModel: BaseClass, ForgotPasswordViewModeling {
    weak var delegate: ForgotPasswordViewModelDelegate?

    @Published var email: String = "" {
        didSet {
            isSendButtonEnabled = !email.isEmpty
        }
    }
    @Published var pin: String = "" {
        didSet {
            isConfirmButtonEnabled = !pin.isEmpty
        }
    }
    @Published var newPassword: String = "" {
        didSet {
            validatePasswords()
        }
    }
    @Published var confirmPassword: String = "" {
        didSet {
            validatePasswords()
        }
    }
    @Published var isSendButtonEnabled: Bool = false
    @Published var isConfirmButtonEnabled: Bool = false
    @Published var isChangePasswordButtonEnabled: Bool = false
    @Published var isLoading: Bool = false

    init(delegate: ForgotPasswordViewModelDelegate? = nil) {
        self.delegate = delegate
    }

    func sendEmail() {
        isLoading = true
        // Simulate sending an email without delay
        DispatchQueue.main.async {
            self.isLoading = false
            self.delegate?.didRequestNewPin()
        }
    }

    func validatePin() {
        isLoading = true
        // Simulate PIN validation without delay
        DispatchQueue.main.async {
            self.isLoading = false
            self.delegate?.didValidatePin()
        }
    }

    func changePassword() {
        guard newPassword == confirmPassword else {
            // should never happen!!
            return
        }
        isLoading = true
        // Simulate changing the password without delay
        DispatchQueue.main.async {
            self.isLoading = false
            self.delegate?.didRenewPassword()
        }
    }

    private func validatePasswords() {
        isChangePasswordButtonEnabled = validatePasswordLength() && validatePasswordsMatch()
    }

    private func validatePasswordLength() -> Bool {
        newPassword.count >= Password.minLenght
    }

    private func validatePasswordsMatch() -> Bool {
        newPassword == confirmPassword
    }
}
