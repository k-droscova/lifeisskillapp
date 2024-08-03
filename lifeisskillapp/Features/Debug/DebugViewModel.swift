//
//  HomeViewModel.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 01.07.2024.
//

import Foundation
import Observation

protocol DebugViewModeling {
    func logout()
    func onAppear()
    func printUserCategoryData()
    func printUserPointData()
    func printGenericPointData()
    func printUserRankData()
}

final class DebugViewModel: DebugViewModeling, ObservableObject {
    typealias Dependencies = HasManagers

    private let locationManager: LocationManaging
    private let userManager: UserManaging
    private let gameDataManager: GameDataManaging
    private let userCategoryManager: any UserCategoryManaging
    private let userPointManager: any UserPointManaging
    private let genericPointManager: any GenericPointManaging
    private let userRankManager: any UserRankManaging
    
    init(dependencies: Dependencies) {
        self.locationManager = dependencies.locationManager
        self.userManager = dependencies.userManager
        self.gameDataManager = dependencies.gameDataManager
        self.userCategoryManager = dependencies.userCategoryManager
        self.userPointManager = dependencies.userPointManager
        self.genericPointManager = dependencies.genericPointManager
        self.userRankManager = dependencies.userRankManager
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
    
    func printUserRankData() {
        let ranks = userRankManager.getAll()
        print(ranks)
    }
    // MARK: Private helpers
    
    private func fetchData() async {
        locationManager.checkLocationAuthorization()
        await gameDataManager.fetchNewDataIfNeccessary(endpoint: nil)
    }
}
