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
            SFSSymbols.close.Image
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
            SFSSymbols.flashOn.Image
            :
            SFSSymbols.flashOff.Image
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

struct LoginButton: View {
    let action: () -> Void
    let text: Text
    let enabledColorBackground: Color
    let disabledColorBackground: Color
    let enabledColorText: Color
    let disabledColorText: Color
    let isEnabled: Bool
    
    var body: some View {
        Button(action: action) {
            text
                .foregroundColor(isEnabled ? enabledColorText : disabledColorText)
                .padding()
                .padding(.horizontal, 20)
                .background(isEnabled ? enabledColorBackground : disabledColorBackground)
                .cornerRadius(20)
        }
        .subheadline
        .scaleEffect(isEnabled ? 1.0 : 0.95)
        .disabled(!isEnabled)
    }
}
