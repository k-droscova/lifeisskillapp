//
//  FlowCoordinator.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 22.07.2024.
//

import Foundation
import ACKategories
import UIKit

public extension Base.FlowCoordinatorNoDeepLink {
    
    /// Handles an error by presenting an alert and executing a custom handling function.
    ///
    /// - Parameters:
    ///   - error: The error to be handled.
    ///   - handle: A closure that defines custom handling logic to be executed after the alert is dismissed.
    public func onError(_ error: Error, handle: @escaping () -> Void) {
        appDependencies.logger.log(
            message: error.localizedDescription
        )
        let alert = UIAlertController(title: "Oops, something went wrong", message: "Error: \(error.localizedDescription)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            handle()
        })
        rootViewController?.present(alert, animated: true, completion: nil)
    }
}
