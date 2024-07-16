//
//  HomeViewModel.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 01.07.2024.
//

import Foundation
import Observation

protocol HomeViewModeling {
    func logout()
    func fetchUserCategoryData()
    func fetchUserPointData()
}

final class HomeViewModel: HomeViewModeling, ObservableObject {
    
    typealias Dependencies = HasManagers

    private let dependencies: Dependencies
    
    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }
    
    func logout() {
        dependencies.userManager.logout()
    }
    
    func fetchUserCategoryData() {
        let categories = dependencies.userCategoryManager.getAllCategories()
        print(categories)
    }
    
    func fetchUserPointData() {
        let points = dependencies.userPointManager.getAllPoints()
        print(points)
    }
}
