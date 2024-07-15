//
//  CodeSource.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 15.07.2024.
//

import Foundation

enum CodeSource: String, Codable {
    case qr = "QR"
    case nfc = "NFC"
    case virtual = "VIRTUAL"
    case text = "TEXT"
}
