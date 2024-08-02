//
//  LoginViewController.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 01.07.2024.
//

import ACKategories
import SwiftUI

final class LoginViewController<ViewModel: LoginViewModeling>: Base.ViewController {
    let viewModel: ViewModel
    
    // MARK: - Initialization
    
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Controller lifecycle
    
    override func loadView() {
        super.loadView()
        
        let vc = LoginView(viewModel: viewModel).hosting()
        embedController(vc)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "login.title"
    }
}
