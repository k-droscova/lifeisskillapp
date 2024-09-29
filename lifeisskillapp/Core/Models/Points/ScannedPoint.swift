//
//  LoadPoint.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 22.07.2024.
//

import Foundation

public struct ScannedPoint: UserData {
    let code: String
    let codeSource: CodeSource
    let location: UserLocation?
    
    public init(code: String, codeSource: CodeSource, location: UserLocation?) {
        self.code = code
        self.codeSource = codeSource
        self.location = location
    }
}

extension ScannedPoint {
    public var id: String { code }
}
