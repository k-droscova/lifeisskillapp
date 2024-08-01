//
//  ButtonStyleModifier.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 20.07.2024.
//

import SwiftUI

struct CustomButtonStyle: ViewModifier {
    var maxWidth: CGFloat = .infinity
    var maxHeight: CGFloat
    var backgroundColor: Color
    var cornerRadius: CGFloat
    
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: maxWidth, maxHeight: maxHeight)
            .background(backgroundColor)
            .cornerRadius(cornerRadius)
    }
}

extension View {
    func customButtonStyle(maxHeight: CGFloat, backgroundColor: Color, cornerRadius: CGFloat) -> some View {
        self.modifier(CustomButtonStyle(maxHeight: maxHeight, backgroundColor: backgroundColor, cornerRadius: cornerRadius))
    }
}

struct LoginButtonStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .headline1
            .frame(maxWidth: .infinity, maxHeight: 60)
            .foregroundColor(.white)
            .background(Color.blue)
            .cornerRadius(10)
    }
}

struct RegisterButtonStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .body1Regular
            .frame(maxWidth: .infinity, maxHeight: 20)
            .foregroundColor(.red)
            .background(Color.white)
            .cornerRadius(10)
    }
}

struct LogoutButtonStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .body1Regular
            .frame(maxWidth: .infinity, maxHeight: 20)
            .foregroundColor(.black)
            .background(Color.white)
            .cornerRadius(10)
    }
}

struct CameraButtonStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .foregroundColor(.white)
            .padding()
            .background(Color.black.opacity(0.5))
            .clipShape(Circle())
    }
}

struct HomeButtonStyle: ViewModifier {
    var color: Color
    var textColor: Color
    
    func body(content: Content) -> some View {
        content
            .foregroundColor(textColor)
            .padding()
            .headline3
            .background(color)
            .clipShape(Capsule())
            .shadow(color: color.opacity(0.3), radius: 10, x: 0, y: 5)
    }
}

extension View {
    func loginButtonStyle() -> some View {
        self.modifier(LoginButtonStyle())
    }
    
    func registerButtonStyle() -> some View {
        self.modifier(RegisterButtonStyle())
    }
    
    func logoutButtonStyle() -> some View {
        self.modifier(LogoutButtonStyle())
    }
    func cameraButtonStyle() -> some View {
        self.modifier(CameraButtonStyle())
    }
    func homeButtonStyle(background: Color, text: Color) -> some View {
        self.modifier(
            HomeButtonStyle(
                color: background,
                textColor: text
            )
        )
    }
}
