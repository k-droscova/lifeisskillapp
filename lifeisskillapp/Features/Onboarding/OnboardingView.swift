//
//  OnbardingView.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 12.08.2024.
//

import SwiftUI

struct OnboardingView: View {
    var body: some View {
        TabView {
            page1
            page2
            page3
            page4
            page5
            page6
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
    }
}

extension OnboardingView {
    private var page1: some View {
        OnboardingPageView(
            image: Image(CustomImages.Screens.howTo1.fullPath),
            text: Text("onboarding.description.find")
        )
    }
    
    private var page2: some View {
        OnboardingPageView(
            image: Image(CustomImages.Screens.messagesNews.fullPath),
            text: Text("onboarding.description.web")
        )
    }
    
    private var page3: some View {
        OnboardingPageView(
            image: Image(CustomImages.Screens.howTo2.fullPath),
            text: Text("onboarding.description.activity")
        )
    }
    
    private var page4: some View {
        OnboardingPageView(
            image: Image(CustomImages.Screens.home.fullPath),
            text: Text("onboarding.description.point")
        )
    }
    
    private var page5: some View {
        OnboardingPageView(
            image: Image(CustomImages.Screens.rank.fullPath),
            text: Text("onboarding.description.prizes")
        )
    }
    
    private var page6: some View {
        OnboardingPageView(
            image: Image(CustomImages.Screens.helpDesk.fullPath),
            text: Text("onboarding.description.problems")
        )
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
            .previewDevice("iPhone 8")
    }
}
