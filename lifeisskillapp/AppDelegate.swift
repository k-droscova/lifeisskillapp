//
//  AppDelegate.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 01.07.2024.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let appFlowCoordinator = AppFlowCoordinator()
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        // Override point for customization after application launch.
        let window = UIWindow(frame: UIScreen.main.bounds)
        appFlowCoordinator.start(in: window)
        self.window = window
        return true
    }



}

