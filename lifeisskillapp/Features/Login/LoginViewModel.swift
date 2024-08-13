//
//  LoginViewModel.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 01.07.2024.
//

import Foundation
import Observation

protocol LoginViewModeling: ObservableObject {
    associatedtype settingBarVM: SettingsBarViewModeling
    var settingsViewModel: settingBarVM { get }
    var username: String { get set }
    var password: String { get set }
    var isLoginEnabled: Bool { get set }
    var isLoading: Bool { get set }
    func login()
    func onAppear()
    func register()
    func forgotPassword()
}

final class LoginViewModel<settingBarVM: SettingsBarViewModeling>: LoginViewModeling, ObservableObject {
    typealias Dependencies = HasUserManager & SettingsBarViewModel.Dependencies
    
    // MARK: - Private Properties

    private let userManager: UserManaging
    weak var delegate: LoginFlowDelegate?
    
    // MARK: - Public Properties

    @Published var username: String = "" {
        didSet {
            shouldEnableLoginButton()
        }
    }
    @Published var password: String = "" {
        didSet {
            shouldEnableLoginButton()
        }
    }
    @Published var isLoginEnabled: Bool = false
    @Published var isLoading: Bool = false
    var settingsViewModel: settingBarVM

    // MARK: - Initialization
    
    init(
        dependencies: Dependencies,
        delegate: LoginFlowDelegate?,
        settingsDelegate: SettingsBarFlowDelegate?
    ) {
        userManager = dependencies.userManager
        self.delegate = delegate
        self.settingsViewModel = settingBarVM.init(
            dependencies: dependencies,
            delegate: settingsDelegate
        )
    }
    
    // MARK: - Public Interface
    
    func login() {
        Task { @MainActor [weak self] in
            guard let self = self else { return }
            self.isLoading = true
            do {
                try await self.userManager.login(credentials: .init(username: username, password: password))
                self.isLoading = false
                self.delegate?.loginSuccessful()
            } catch let error as BaseError {
                self.isLoading = false
                if error.code == ErrorCodes.login(.offlineInvalidCredentials).code {
                    delegate?.offlineLoginFailed()
                }
            }
            catch {
                self.isLoading = false
                print("Login failed with error: \(error)")
                self.delegate?.loginFailed()
                return
            }
        }
    }
    
    func onAppear() {
        if !userManager.hasAppId {
            fetchData()
        }
    }
    
    func register() {
        delegate?.registerTapped()
    }
    
    func forgotPassword() {
        print("forgot password tapped")
    }
    
    // MARK: Private Helpers
    
    private func fetchData() {
        Task {
            try await appDependencies.userManager.initializeAppId()
        }
    }
    
    private func shouldEnableLoginButton() {
        isLoginEnabled = username.isNotEmpty && password.isNotEmpty
    }
}
