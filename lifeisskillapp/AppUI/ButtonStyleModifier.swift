//
//  ButtonStyleModifier.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 20.07.2024.
//

import SwiftUI

// General Custom Button Style
struct CustomButtonStyle: ButtonStyle {
    var backgroundColor: Color
    var textColor: Color
    var cornerRadius: CGFloat
    var maxHeight: CGFloat
    var padding: CGFloat
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity, maxHeight: maxHeight)
            .foregroundColor(textColor)
            .padding(padding)
            .background(backgroundColor)
            .cornerRadius(cornerRadius)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    }
}

struct EnablingButtonStyle: ButtonStyle {
    var isEnabled: Bool
    let enabledColor: Color
    let disabledColor: Color
    let enabledTextColor: Color
    let disabledTextColor: Color
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(isEnabled ? enabledTextColor : disabledTextColor)
            .padding()
            .padding(.horizontal, 20)
            .background(isEnabled ? enabledColor : disabledColor)
    }
}

struct CameraButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.white)
            .padding()
            .background(Color.black.opacity(0.5))
            .clipShape(Circle())
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    }
}

struct HomeButtonStyle: ButtonStyle {
    var color: Color
    var textColor: Color
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(textColor)
            .padding()
            .headline3
            .background(color)
            .clipShape(Capsule())
            .shadow(color: color.opacity(0.3), radius: 10, x: 0, y: 5)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    }
}
