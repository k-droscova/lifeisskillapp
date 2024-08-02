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

// Specific Button Styles
struct LoginButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .frame(maxWidth: .infinity, maxHeight: 60)
            .foregroundColor(.white)
            .background(Color.blue)
            .cornerRadius(10)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    }
}

struct RegisterButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.body)
            .frame(maxWidth: .infinity, maxHeight: 20)
            .foregroundColor(.red)
            .background(Color.white)
            .cornerRadius(10)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    }
}

struct LogoutButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.body)
            .frame(maxWidth: .infinity, maxHeight: 20)
            .foregroundColor(.black)
            .background(Color.white)
            .cornerRadius(10)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
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
            .font(.headline)
            .background(color)
            .clipShape(Capsule())
            .shadow(color: color.opacity(0.3), radius: 10, x: 0, y: 5)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    }
}
