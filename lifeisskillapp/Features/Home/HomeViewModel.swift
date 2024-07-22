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
    func onAppear()
    func printUserCategoryData()
    func printUserPointData()
    func printGenericPointData()
}

final class HomeViewModel: HomeViewModeling, ObservableObject {
    
    typealias Dependencies = HasManagers

    private var locationManager: LocationManaging
    private var userManager: UserManaging
    private var gameDataManager: GameDataManaging
    private var userCategoryManager: any UserCategoryManaging
    private var userPointManager: any UserPointManaging
    private var genericPointManager: any GenericPointManaging
    
    init(dependencies: Dependencies) {
        self.locationManager = dependencies.locationManager
        self.userManager = dependencies.userManager
        self.gameDataManager = dependencies.gameDataManager
        self.userCategoryManager = dependencies.userCategoryManager
        self.userPointManager = dependencies.userPointManager
        self.genericPointManager = dependencies.genericPointManager
    }
    
    func logout() {
        userManager.logout()
    }
    
    func onAppear() {
        Task {
            await fetchData()
        }
    }
    
    func printUserCategoryData() {
        let categories = userCategoryManager.getAll()
        print(categories)
    }
    
    func printUserPointData() {
        let points = userPointManager.getAll()
        print(points)
    }
    
    func printGenericPointData() {
        let points = genericPointManager.getAll()
        print(points.count)
    }
    
    // MARK: Private helpers
    
    private func fetchData() async {
        locationManager.checkLocationAuthorization()
        await gameDataManager.fetchNewDataIfNeccessary()
    }
}
