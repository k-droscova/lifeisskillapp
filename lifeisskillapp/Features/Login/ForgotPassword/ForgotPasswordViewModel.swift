//
//  ForgotPasswordViewModel.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 26.08.2024.
//

import Foundation
import Observation

protocol ForgotPasswordViewModeling: BaseClass, ObservableObject {
    var delegate: ForgotPasswordFlowDelegate? { get set }
    var isLoading: Bool { get }
    var email: String { get set }
    var pin: String { get set }
    var newPassword: String { get set }
    var confirmPassword: String { get set }
    var isSendEmailButtonEnabled: Bool { get set }
    var isConfirmPinButtonEnabled: Bool { get set }
    var isChangePasswordButtonEnabled: Bool { get set }

    func sendEmail()
    func validatePin()
    func changePassword()
}

final class ForgotPasswordViewModel: BaseClass, ForgotPasswordViewModeling, ObservableObject {
    typealias Dependencies = HasLoggers & HasUserManager
    // MARK: - Private Properties

    private let logger: LoggerServicing
    private let userManager: UserManaging
    private var requestData: ForgotPasswordData?
    private var timer: Timer?
    private var timerExpirationDate: Date?

    // MARK: - Public Properties
    weak var delegate: ForgotPasswordFlowDelegate?
    @Published private(set) var isLoading: Bool = false
    @Published var email: String = "" {
        didSet {
            isSendEmailButtonEnabled = !email.isEmpty
        }
    }
    @Published var pin: String = "" {
        didSet {
            isConfirmPinButtonEnabled = !pin.isEmpty
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
    @Published var isSendEmailButtonEnabled: Bool = false
    @Published var isConfirmPinButtonEnabled: Bool = false
    @Published var isChangePasswordButtonEnabled: Bool = false

    // MARK: - Initialization

    init(
        dependencies: Dependencies,
        delegate: ForgotPasswordFlowDelegate? = nil
    ) {
        self.logger = dependencies.logger
        self.userManager = dependencies.userManager
        self.delegate = delegate
    }
    
    deinit {
        self.invalidateTimer()
    }

    // MARK: - Public Interface

    func sendEmail() {
        Task { @MainActor [weak self] in
            guard let self = self else { return }
            self.isLoading = true
            defer { self.isLoading = false }
            do {
                self.requestData = try await self.userManager.requestPinForPasswordRenewal(username: self.email)
                self.pin = "" // reset the textfield
                self.delegate?.didRequestNewPin()
                self.startPinExpirationTimer()
            } catch {
                print("Forgot Password Request failed with error: \(error)")
                self.delegate?.failedRequestNewPin()
                return
            }
        }
    }

    func validatePin() {
        Task { @MainActor [weak self] in
            guard let self = self else { return }
            self.isLoading = true
            defer { self.isLoading = false }
            guard self.pin == self.requestData?.pin else {
                self.delegate?.failedValidatePin()
                return
            }
            self.invalidateTimer()
            self.delegate?.didValidatePin()
        }
    }

    func changePassword() {
        Task { @MainActor [weak self] in
            guard let self = self else { return }
            guard self.newPassword == self.confirmPassword else {
                // should never happen since passwords have to match for button to be enabled
                return
            }
            self.isLoading = true
            defer { self.isLoading = false }
            do {
                guard let data = self.requestData else {
                    throw BaseError(
                        context: .system,
                        message: "Cannot validate empty request data",
                        logger: logger
                    )
                }
                let credentials = ForgotPasswordCredentials(email: data.userEmail, newPassword: self.newPassword, pin: self.pin)
                let response = try await userManager.validateNewPassword(credentials: credentials)
                logger.log(message: "Password validated with result: \(response.description)")
                self.delegate?.didRenewPassword()
            } catch {
                logger.log(message: "Forgot Password Request failed with error: \(error.localizedDescription)")
                self.delegate?.failedRenewPassword()
                return
            }
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
        timerExpirationDate = Date().addingTimeInterval(Password.pinValidityTime * 60) // 15 minutes from now
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
    weak var delegate: ForgotPasswordFlowDelegate?

    @Published var email: String = "" {
        didSet {
            isSendEmailButtonEnabled = !email.isEmpty
        }
    }
    @Published var pin: String = "" {
        didSet {
            isConfirmPinButtonEnabled = !pin.isEmpty
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
    @Published var isSendEmailButtonEnabled: Bool = false
    @Published var isConfirmPinButtonEnabled: Bool = false
    @Published var isChangePasswordButtonEnabled: Bool = false
    @Published var isLoading: Bool = false

    init(delegate: ForgotPasswordFlowDelegate? = nil) {
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
