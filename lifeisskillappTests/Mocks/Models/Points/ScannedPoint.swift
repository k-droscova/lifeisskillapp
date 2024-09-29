//
//  ScannedPoint.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 29.09.2024.
//

import lifeisskillapp
import Foundation

extension ScannedPoint {
    static func mock(
        code: String = "mockCode123",
        codeSource: CodeSource = .qr,
        location: UserLocation? = UserLocation.mock()
    ) -> ScannedPoint {
        return ScannedPoint(
            code: code,
            codeSource: codeSource,
            location: location
        )
    }
}
