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
    func fetchGenericPointData()
}

final class HomeViewModel: HomeViewModeling, ObservableObject {
    
    typealias Dependencies = HasManagers

    private var userManager: UserManaging
    private var userCategoryManager: any UserCategoryManaging
    private var userPointManager: any UserPointManaging
    private var genericPointManager: any GenericPointManaging
    
    init(dependencies: Dependencies) {
        self.userManager = dependencies.userManager
        self.userCategoryManager = dependencies.userCategoryManager
        self.userPointManager = dependencies.userPointManager
        self.genericPointManager = dependencies.genericPointManager
    }
    
    func logout() {
        userManager.logout()
    }
    
    func fetchUserCategoryData() {
        let categories = userCategoryManager.getAll()
        print(categories)
    }
    
    func fetchUserPointData() {
        let points = userPointManager.getAll()
        print(points)
    }
    
    func fetchGenericPointData() {
        let points = genericPointManager.getAll()
        print(points.count)
    }
}
