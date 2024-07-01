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
    var apiKey: String? { get }
    func login()
}

final class LoginViewModel: LoginViewModeling, ObservableObject {
    struct Dependencies: HasUserManager {
        let userManager: UserManaging
    }
    private let userManager: UserManaging
    @Published var username: String = ""
    @Published var password: String = ""
    var apiKey: String? {
        userManager.apiKey
    }
    
    init(dependencies: Dependencies) {
        userManager = dependencies.userManager
    }
    
    // MARK: - Helpers
    
    func login() {
        LoginAction(
            parameters: LoginRequest(
                username: self.username,
                password: self.password
            )
        ).login { response in
            self.userManager.login(apiKey: response.data.accessToken, username: self.username)
        }
    }
}

extension LoginViewModel {
    enum Constants {
        static let myAPIKey = "V1nB7JnWfTxVFwrw+3UYPQ==yfEMAwRyHm19MIix"
    }
}

extension LoginViewModel {
    struct LoginAction {
        
        var parameters: LoginRequest
        
        init(parameters: LoginRequest) {
            self.parameters = parameters
        }
        
        func login(completion: @escaping (LoginResponse) -> Void) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                if ( correctSignIn() ) {
                    completion(.mockReponse)
                }
            })
        }
        
        private func correctSignIn() -> Bool {
            return parameters.password.elementsEqual("admin")
        }
    }

}

