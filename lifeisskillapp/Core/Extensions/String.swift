//
//  String.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 01.07.2024.
//

import Foundation

extension String {
    var localized: String {
        NSLocalizedString(self, comment: "")
    }
    func localized(arguments: CVarArg...) -> String {
        String(format: self.localized, arguments: arguments)
    }
}
