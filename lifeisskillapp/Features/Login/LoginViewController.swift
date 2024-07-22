//
//  LoginViewController.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 01.07.2024.
//

import ACKategories
import SwiftUI

final class LoginViewController: Base.ViewController {
    let viewModel: LoginViewModeling

    // MARK: - Initialization
    
    init(viewModel: LoginViewModeling) {
        self.viewModel = viewModel
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Controller lifecycle
    
    override func loadView() {
        super.loadView()
        
        let rootView = LoginView(viewModel: viewModel)
        let vc = UIHostingController(rootView: rootView)
        embedController(vc)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "login.title"
    }
}
