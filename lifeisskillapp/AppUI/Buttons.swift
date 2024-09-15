//
//  Buttons.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 29.07.2024.
//

import Foundation
import SwiftUI

struct ExitButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            SFSSymbols.close.image
        }
        .buttonStyle(CameraButtonStyle())
    }
}

struct FlashButton: View {
    let action: () -> Void
    @Binding var flashOn: Bool
    
    var body: some View {
        Button(action: action) {
            flashOn ?
            SFSSymbols.flashOn.image
            :
            SFSSymbols.flashOff.image
        }
        .buttonStyle(CameraButtonStyle())
    }
}

struct HomeButton<Content: View>: View {
    let action: () -> Void
    let background: Color
    let foregroundColor: Color
    @ViewBuilder let content: Content
    
    var body: some View {
        Button(action: action) {
            content
                .foregroundColor(foregroundColor)
        }
        .buttonStyle(HomeButtonStyle(color: background, textColor: foregroundColor))
    }
}

struct EnablingButton: View {
    let action: () -> Void
    let text: LocalizedStringKey
    let enabledColorBackground: Color
    let disabledColorBackground: Color
    let enabledColorText: Color
    let disabledColorText: Color
    let isEnabled: Bool
    
    // Custom initializer with default values
    init(
        action: @escaping () -> Void,
        text: LocalizedStringKey,
        enabledColorBackground: Color = Color.colorLisGreen,
        disabledColorBackground: Color = Color.colorLisGrey,
        enabledColorText: Color = Color.white,
        disabledColorText: Color = Color.colorLisDarkGrey,
        isEnabled: Bool
    ) {
        self.action = action
        self.text = text
        self.enabledColorBackground = enabledColorBackground
        self.disabledColorBackground = disabledColorBackground
        self.enabledColorText = enabledColorText
        self.disabledColorText = disabledColorText
        self.isEnabled = isEnabled
    }
    
    var body: some View {
        Button(action: action) {
            Text(text)
        }
        .buttonStyle(
            EnablingButtonStyle(
                isEnabled: isEnabled,
                enabledColor: enabledColorBackground,
                disabledColor: disabledColorBackground,
                enabledTextColor: enabledColorText,
                disabledTextColor: disabledColorText
            )
        )
    }
}

struct ForgotPasswordPageView<Content: View>: View {
    let image: Image = Image(CustomImages.ForgotPassword.defaultImage.fullPath)
    let text: Text
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(spacing: CustomSizes.ForgotPasswordPageView.verticalSpacing.size) {
            imageView
            textView
            contentView
        }
        .padding(.horizontal, CustomSizes.ForgotPasswordPageView.horizontalPadding.size)
    }
    
    private var imageView: some View {
        image
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(height: CustomSizes.ForgotPasswordPageView.frameHeight.size)
    }
    
    private var textView: some View {
        text
            .body1Regular
            .multilineTextAlignment(.center)
    }
    
    private var contentView: some View {
        content
    }
}
