//
//  BaseClass.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 22.07.2024.
//

import Foundation

class BaseClass: NSObject {
    override init() {
        super.init()
        appDependencies.logger.log(message: "📱 👶 \(self)")
    }
    
    deinit {
        appDependencies.logger.log(message: "📱 ⚰️ \(self)")
    }
}
