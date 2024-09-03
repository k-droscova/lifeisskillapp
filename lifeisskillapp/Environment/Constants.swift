//
//  Constants.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 26.08.2024.
//

import Foundation

enum Password {
    static let minLenght = 6
    #if DEBUG
    static let pinValidityTime = 0.5 // in minutes
    #else
    static let pinValidityTime = 15.0 // in minutes
    #endif
}

enum Username {
    static let minLength = 4
}

enum Email {
    static let emailPattern = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}$" // regex
}
