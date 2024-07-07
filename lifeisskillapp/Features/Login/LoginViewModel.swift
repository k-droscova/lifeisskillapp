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
}

final class LoginViewModel: LoginViewModeling, ObservableObject {
    typealias Dependencies = HasUserManager
    
    private let userManager: UserManaging
    
    @Published var username: String = ""
    @Published var password: String = ""
    
    init(dependencies: Dependencies) {
        userManager = dependencies.userManager
    }
    
    func login() {
        Task {
            do {
                try await userManager.login(loginCredentials: .init(username: username, password: password))
            } catch {
                // Handle the error appropriately on the main thread
                print("Login failed with error: \(error)")
            }
        }
    }
}
