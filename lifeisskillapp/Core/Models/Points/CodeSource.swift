//
//  CodeSource.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 15.07.2024.
//

import Foundation

enum CodeSource: String, Codable {
    /// Loaded from tag with QR code
    case qr = "QR"

    /// Loaded from NFC tag
    case nfc = "NFC"

    /// Loaded from location, point only visible in map, no physical LiS sign/tag
    case virtual = "VIRTUAL"

    /// Loaded from tourist signs
    case text = "TEXT"
}
