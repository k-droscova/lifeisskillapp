//
//  ButtonStyleModifier.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 20.07.2024.
//

import SwiftUI

struct CustomButtonStyle: ViewModifier {
    var fontSize: CGFloat
    var fontWeight: Font.Weight
    var foregroundColor: Color
    var backgroundColor: Color
    var cornerRadius: CGFloat
    var maxHeight: CGFloat
    
    func body(content: Content) -> some View {
        content
            .font(.system(size: fontSize, weight: fontWeight, design: .default))
            .frame(maxWidth: .infinity, maxHeight: maxHeight)
            .foregroundColor(foregroundColor)
            .background(backgroundColor)
            .cornerRadius(cornerRadius)
    }
}

extension View {
    func customButtonStyle(fontSize: CGFloat, fontWeight: Font.Weight, foregroundColor: Color, backgroundColor: Color, cornerRadius: CGFloat, maxHeight: CGFloat) -> some View {
        self.modifier(CustomButtonStyle(fontSize: fontSize, fontWeight: fontWeight, foregroundColor: foregroundColor, backgroundColor: backgroundColor, cornerRadius: cornerRadius, maxHeight: maxHeight))
    }
}

struct LoginButtonStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(size: 24, weight: .bold, design: .default))
            .frame(maxWidth: .infinity, maxHeight: 60)
            .foregroundColor(.white)
            .background(Color.blue)
            .cornerRadius(10)
    }
}

struct RegisterButtonStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(size: 14, weight: .bold, design: .default))
            .frame(maxWidth: .infinity, maxHeight: 20)
            .foregroundColor(.red)
            .background(Color.white)
            .cornerRadius(10)
    }
}

extension View {
    func loginButtonStyle() -> some View {
        self.modifier(LoginButtonStyle())
    }
    
    func registerButtonStyle() -> some View {
        self.modifier(RegisterButtonStyle())
    }
}
