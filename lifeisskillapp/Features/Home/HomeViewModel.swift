//
//  HomeViewModel.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 01.07.2024.
//

import Foundation
import Observation

protocol HomeViewModeling {
    
}

final class HomeViewModel: HomeViewModeling, ObservableObject {
    struct Dependencies: HasUserManager {
        let userManager: UserManaging
    }
    private let userManager: UserManaging
    
    init(dependencies: Dependencies) {
        userManager = dependencies.userManager
    }
}
