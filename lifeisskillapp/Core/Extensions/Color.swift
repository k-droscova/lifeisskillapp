//
//  Color.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 02.08.2024.
//

import Foundation
import SwiftUI

extension Color {
    func toUIColor() -> UIColor {
        // Get the color components
        let components = self.cgColor?.components
        let colorSpace = self.cgColor?.colorSpace?.model
        
        if let components = components, let colorSpace = colorSpace {
            switch colorSpace {
            case .monochrome:
                let white = components[0]
                let alpha = components.count > 1 ? components[1] : 1.0
                return UIColor(white: white, alpha: alpha)
            case .rgb:
                let red = components[0]
                let green = components[1]
                let blue = components[2]
                let alpha = components.count > 3 ? components[3] : 1.0
                return UIColor(red: red, green: green, blue: blue, alpha: alpha)
            default:
                break
            }
        }
        // Return a default color if the conversion fails
        return UIColor.black
    }
}
