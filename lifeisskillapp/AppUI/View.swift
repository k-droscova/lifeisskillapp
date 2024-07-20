//
//  View.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 20.07.2024.
//

import Foundation
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
        font(
            AssetsFontFamily.Montserrat.bold(size: 28),
            lineHeight: 36,
            textStyle: .title
        )
    }

    /// Headline 2
    ///
    /// * Font: `Montserrat.bold`
    /// * Size: `22`
    /// * Line height: `26`
    var headline2: some View {
        font(
            AssetsFontFamily.Montserrat.bold(size: 22),
            lineHeight: 26,
            textStyle: .title
        )
    }

/// Body 1 - regular
    ///
    /// * Font: `Montserrat.regular`
    /// * Size: `14`
    /// * Line height: `20`
    var body1Regular: some View {
        font(
            AssetsFontFamily.Montserrat.regular(size: 14),
            lineHeight: 20,
            textStyle: .body
        )
    }
}
