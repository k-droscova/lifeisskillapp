//
//  UserStorage.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 10.07.2024.
//

import Foundation

protocol UserStoraging {
    func beginTransaction()
    func commitTransaction()
    func rollbackTransaction()
}
