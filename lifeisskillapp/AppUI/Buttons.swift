//
//  Buttons.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 29.07.2024.
//

import Foundation
import SwiftUI

struct CameraButton: View {
    let action: () -> Void
    let systemImageName: String = "xmark"
    
    var body: some View {
        Button(action: {
            action()
        }) {
            Image(systemName: systemImageName)
        }
        .cameraButtonStyle()
    }
}

struct FlashButton: View {
    let action: () -> Void
    let flashOnButton: String = "flash_selected"
    let flashOffButton: String = "flash_unselected"
    @Binding var flashOn: Bool
    
    var body: some View {
        Button(action: {
            action()
        }) {
            flashOn ?
            Image(flashOnButton)
                .resizable()
                .frame(width: 16, height: 24)
            :
            Image(flashOffButton)
                .resizable()
                .frame(width: 16, height: 24)
        }
        .cameraButtonStyle()
    }
}
