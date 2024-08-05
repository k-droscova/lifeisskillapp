//
//  PointsFlowCoordinator.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 05.08.2024.
//

import Foundation

protocol PointFlowDelegate: GameDataManagerFlowDelegate, NSObject {
    func onError(_ error: Error)
    func onNoDataAvailable()
    func selectCategoryPrompt()
    func categoryPointsMapButtonPressed()
    func categoryListButtonPressed()
    func pointMapButtonPressed(point: Point)
}


