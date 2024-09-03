//
//  Alert.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 03.09.2024.
//

import UIKit

class Alert {
    static func okAction(
        style: UIAlertAction.Style = .cancel,
        completion: (() -> Void)? = nil
    ) -> UIAlertAction {
        return UIAlertAction(title: "OK", style: style) { _ in
            completion?()
        }
    }
}
