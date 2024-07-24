//
//  String.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 24.07.2024.
//

import Foundation

extension String {
    func parseMessage() -> String {
        let withoutFront = self.split(separator: "{")
        let withoutBack = withoutFront[1].split(separator: "}")

        return String(withoutBack.first ?? "")
    }
}
