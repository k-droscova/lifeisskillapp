//
//  View.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 20.07.2024.
//

import SwiftUI

/*
 MARK: This is an example of how this can be used, UI elements specifics related to LiS will be handled later
 */
public extension View {
    /// Headline 1
    ///
    /// * Font: `Montserrat.bold`
    /// * Size: `28`
    /// * Line height: `36`
    var headline1: some View {
        self.font(
            AssetsFontFamily.Montserrat.bold(size: 28),
            lineHeight: 36,
            textStyle: .title1
        )
    }

    /// Headline 2
    ///
    /// * Font: `Montserrat.bold`
    /// * Size: `22`
    /// * Line height: `26`
    var headline2: some View {
        self.font(
            AssetsFontFamily.Montserrat.bold(size: 22),
            lineHeight: 26,
            textStyle: .title2
        )
    }

    /// Body 1 - regular
    ///
    /// * Font: `Montserrat.regular`
    /// * Size: `14`
    /// * Line height: `20`
    var body1Regular: some View {
        self.font(
            AssetsFontFamily.Montserrat.regular(size: 14),
            lineHeight: 20,
            textStyle: .body
        )
    }
    
    var body2Login: some View {
        self.font(
            AssetsFontFamily.Montserrat.regular(size: 16),
            lineHeight: 22,
            textStyle: .body
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
