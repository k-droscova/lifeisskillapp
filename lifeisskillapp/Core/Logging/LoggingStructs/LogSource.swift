//
//  LogSource.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 06.07.2024.
//

import Foundation

public struct LogSource: Codable {
    var fileID: String
    var fun: String
    var line: Int
    
    public init(fileID: String, fun: String, line: Int) {
        self.fileID = fileID
        self.fun = fun
        self.line = line
    }
}
