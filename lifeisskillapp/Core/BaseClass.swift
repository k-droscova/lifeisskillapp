//
//  BaseClass.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 22.07.2024.
//

import Foundation

public class BaseClass: NSObject {
    public override init() {
        super.init()
        appDependencies.logger.log(message: "📱 👶 \(self)")
    }
    
    deinit {
        appDependencies.logger.log(message: "📱 ⚰️ \(self)")
    }
}
