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
    static let pinValidityTime = 0.1 // in minutes
    #else
    static let pinValidityTime = 15.0 // in minutes
    #endif
}
