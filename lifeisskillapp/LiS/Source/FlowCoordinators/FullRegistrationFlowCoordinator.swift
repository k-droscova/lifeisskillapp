//
//  FullRegistrationFlowCoordinator.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 06.09.2024.
//

import Foundation

protocol FullRegistrationFlowDelegate: NSObject {
    func registrationDidSucceed()
    func registrationDidFail()
}
