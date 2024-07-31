//
//  LoginViewModel.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 01.07.2024.
//

import Foundation
import Observation

protocol LoginViewModeling: ObservableObject {
    var username: String { get set }
    var password: String { get set }
    var isLoginEnabled: Bool { get set }
    var isLoading: Bool { get set }
    func login()
    func onAppear()
    func register()
    func forgotPassword()
}

final class LoginViewModel: LoginViewModeling, ObservableObject {
    typealias Dependencies = HasUserManager
    
    private let userManager: UserManaging
    weak var delegate: LoginFlowDelegate?
    
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
    
    init(dependencies: Dependencies, delegate: LoginFlowDelegate?) {
        userManager = dependencies.userManager
        self.delegate = delegate
    }
    
    func login() {
        Task { @MainActor in
            isLoading = true
            do {
                try await userManager.login(loginCredentials: .init(username: username, password: password))
                isLoading = false
                if userManager.isLoggedIn {
                    delegate?.loginSuccessful()
                }
            } catch {
                isLoading = false
                // Handle the error appropriately on the main thread
                print("Login failed with error: \(error)")
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
