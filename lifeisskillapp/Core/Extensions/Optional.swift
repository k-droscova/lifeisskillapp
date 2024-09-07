//
//  Optional.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 07.09.2024.
//

import Foundation

extension Optional where Wrapped == String {
    var isNotEmpty: Bool {
        guard let self = self else { return false }
        return !self.isEmpty
    }
}
