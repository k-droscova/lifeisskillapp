//
//  LoadPoint.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 22.07.2024.
//

import Foundation

struct ScannedPoint: UserData {
    let code: String
    let codeSource: CodeSource
}

extension ScannedPoint {
    var id: String { code }
}
