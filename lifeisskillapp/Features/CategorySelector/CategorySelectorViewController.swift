//
//  CategorySelectorViewController.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 02.08.2024.
//

import ACKategories
import SwiftUI

final class CategorySelectorViewController<ViewModel: CategorySelectorViewModeling>: Base.ViewController {
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
        
        let vc = CategorySelectorView(viewModel: self.viewModel).hosting()
        embedController(vc)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
