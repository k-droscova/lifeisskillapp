//
//  AppDependencies.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 01.07.2024.
//

import Foundation

let appDependencies = AppDependency()

final class AppDependency {
    lazy var userManager: UserManaging = UserManager()
    lazy var network: Networking = Network()
}

extension AppDependency: HasNetwork {}
extension AppDependency: HasUserManager {}
