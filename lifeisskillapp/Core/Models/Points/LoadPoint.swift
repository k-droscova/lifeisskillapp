//
//  LoadPoint.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 22.07.2024.
//

import Foundation

struct LoadPoint: UserData {
    let code: String
    let codeSource: CodeSource
}

extension LoadPoint {
    var id: String { code }
}
