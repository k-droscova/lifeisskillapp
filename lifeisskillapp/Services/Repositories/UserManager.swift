//
//  UserManager.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 01.07.2024.
//

import Foundation

protocol UserManagerFlowDelegate: NSObject {
    func onLogin()
    func onLogout()
}

protocol HasUserManager {
    var userManager: UserManaging { get }
}

protocol UserManaging {
    var delegate: UserManagerFlowDelegate? { get set }
    var apiKey: String? { get }
    var username: String? { get  set }
    var isLoggedIn: Bool { get }
    
    func login(apiKey: String, username: String)
    func logout()
}


final class UserManager: UserManaging {
    // MARK: - Initialization
    init() {
        
    }
    // MARK: - Public Properties
    
    weak var delegate: UserManagerFlowDelegate?
    
    var apiKey: String? {
        get { UserDefaults.standard.string(forKey: "apiKey") }
        set { UserDefaults.standard.set(newValue, forKey: "apiKey") }
    }
    
    var username: String? {
        get { UserDefaults.standard.string(forKey: "username") }
        set { UserDefaults.standard.set(newValue, forKey: "username") }
    }
    
    var isLoggedIn: Bool {
        !(apiKey ?? "").isEmpty
    }
    
    // MARK: - Public Interface
    func login(apiKey: String, username: String) {
        self.apiKey = apiKey
        self.username = username
        delegate?.onLogin()
    }
    func logout() {
        self.apiKey = nil
        self.username = nil
        delegate?.onLogout()
    }
}


