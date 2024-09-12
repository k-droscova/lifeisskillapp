//
//  View.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 20.07.2024.
//

import SwiftUI

import SwiftUI

public extension View {
    
    // MARK: - Fonts
    
    var headline1: some View {
        font(
            AssetsFontFamily.Roboto.black(size: 28),
            lineHeight: 36,
            textStyle: .title1
        )
    }
    
    var headline2: some View {
        font(
            AssetsFontFamily.Roboto.black(size: 22),
            lineHeight: 26,
            textStyle: .title2
        )
    }
    
    var headline3: some View {
        font(
            AssetsFontFamily.Roboto.medium(size: 20),
            lineHeight: 24,
            textStyle: .title3
        )
    }
    
    var subheadline: some View {
        font(
            AssetsFontFamily.Roboto.regular(size: 17),
            lineHeight: 22,
            textStyle: .subheadline
        )
    }
    
    var subheadlineBold: some View {
        font(
            AssetsFontFamily.Roboto.semiBold(size: 17),
            lineHeight: 22,
            textStyle: .subheadline
        )
    }
    
    var body1Regular: some View {
        font(
            AssetsFontFamily.Roboto.regular(size: 16),
            lineHeight: 22,
            textStyle: .body
        )
    }
    
    var body2Regular: some View {
        font(
            AssetsFontFamily.Roboto.regular(size: 14),
            lineHeight: 20,
            textStyle: .body
        )
    }
    
    var caption: some View {
        font(
            AssetsFontFamily.Roboto.regular(size: 12),
            lineHeight: 16,
            textStyle: .caption1
        )
    }
    
    var locationCaption: some View {
        font(
            AssetsFontFamily.Roboto.regular(size: 8),
            lineHeight: 12,
            textStyle: .caption1
        )
    }
    
    var footnote: some View {
        font(
            AssetsFontFamily.Roboto.regular(size: 13),
            lineHeight: 18,
            textStyle: .footnote
        )
    }
    
    var largeTitle: some View {
        font(
            AssetsFontFamily.Roboto.black(size: 34),
            lineHeight: 41,
            textStyle: .largeTitle
        )
    }
    
    // MARK: - Foregrounds
    
    var foregroundsPrimary: some View {
        foregroundColor(.primary)
    }
    
    var foregroundsSecondary: some View {
        foregroundColor(.secondary)
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
        modifier(CustomFontModifier(font: font, lineHeight: lineHeight, textStyle: textStyle))
    }
}

extension View {
    func squareFrame(size: CGFloat) -> some View {
        frame(width: size, height: size, alignment: .center)
    }
}
