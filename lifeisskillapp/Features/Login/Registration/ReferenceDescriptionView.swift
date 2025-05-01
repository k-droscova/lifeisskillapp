//
//  ReferenceDescriptionView.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 04.09.2024.
//

import SwiftUI

struct ReferenceDescriptionView: View {
    var body: some View {
        OnboardingPageView(
            image: Image(CustomImages.Screens.helpDesk.fullPath),
            text: Text(LocalizedStringKey("registration.reference.instructions.body"))
        )
    }
}

#Preview {
    ReferenceDescriptionView()
}
