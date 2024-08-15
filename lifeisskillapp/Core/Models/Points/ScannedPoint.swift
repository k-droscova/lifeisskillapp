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
    let location: UserLocation?
    
    init(code: String, codeSource: CodeSource, location: UserLocation?) {
        self.code = code
        self.codeSource = codeSource
        self.location = location
    }
}

extension ScannedPoint {
    var id: String { code }
}
