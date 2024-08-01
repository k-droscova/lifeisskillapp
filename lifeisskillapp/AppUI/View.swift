//
//  View.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 20.07.2024.
//

import SwiftUI

public extension View {
    var headline1: some View {
        self.font(
            AssetsFontFamily.Montserrat.bold(size: 28),
            lineHeight: 36,
            textStyle: .title1
        )
    }
    
    var headline2: some View {
        self.font(
            AssetsFontFamily.Montserrat.bold(size: 22),
            lineHeight: 26,
            textStyle: .title2
        )
    }
    
    var headline3: some View {
        self.font(
            AssetsFontFamily.Montserrat.semiBold(size: 20),
            lineHeight: 24,
            textStyle: .title3
        )
    }
    
    var subheadline: some View {
        self.font(
            AssetsFontFamily.Montserrat.regular(size: 17),
            lineHeight: 22,
            textStyle: .subheadline
        )
    }
    
    var body1Regular: some View {
        self.font(
            AssetsFontFamily.Montserrat.regular(size: 14),
            lineHeight: 20,
            textStyle: .body
        )
    }
    
    var body2Regular: some View {
        self.font(
            AssetsFontFamily.Montserrat.regular(size: 16),
            lineHeight: 22,
            textStyle: .body
        )
    }
    
    var caption: some View {
        self.font(
            AssetsFontFamily.Montserrat.regular(size: 12),
            lineHeight: 16,
            textStyle: .caption1
        )
    }
    
    var footnote: some View {
        self.font(
            AssetsFontFamily.Montserrat.regular(size: 13),
            lineHeight: 18,
            textStyle: .footnote
        )
    }
    
    var largeTitle: some View {
        self.font(
            AssetsFontFamily.Montserrat.bold(size: 34),
            lineHeight: 41,
            textStyle: .largeTitle
        )
    }
}

struct CustomFontModifier: ViewModifier {
    var font: UIFont
    var lineHeight: CGFloat
    var textStyle: UIFont.TextStyle
    
    func body(content: Content) -> some View {
        content
            .font(Font(font as CTFont))  // Convert UIFont to Font
            .lineSpacing(lineHeight - font.lineHeight)
    }
}

extension View {
    func font(_ font: UIFont, lineHeight: CGFloat, textStyle: UIFont.TextStyle) -> some View {
        self.modifier(CustomFontModifier(font: font, lineHeight: lineHeight, textStyle: textStyle))
    }
}
