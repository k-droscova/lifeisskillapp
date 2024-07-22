//
//  LoginViewModel.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 01.07.2024.
//

import Foundation
import Observation

protocol LoginViewModeling {
    var username: String { get set }
    var password: String { get set }
    func login()
    func onAppear()
    func register()
}

final class LoginViewModel: LoginViewModeling, ObservableObject {
    typealias Dependencies = HasUserManager
    
    private let userManager: UserManaging
    weak var delegate: LoginFlowDelegate?
    
    @Published var username: String = ""
    @Published var password: String = ""
    
    
    init(dependencies: Dependencies, delegate: LoginFlowDelegate?) {
        userManager = dependencies.userManager
        self.delegate = delegate
    }
    
    func login() {
        Task {
            do {
                try await userManager.login(loginCredentials: .init(username: username, password: password))
                if userManager.isLoggedIn {
                    delegate?.loginSuccessful()
                }
            } catch {
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
    
    // MARK: Private Helpers
    
    private func fetchData() {
        Task {
            try await appDependencies.userManager.initializeAppId()
        }
    }
}
