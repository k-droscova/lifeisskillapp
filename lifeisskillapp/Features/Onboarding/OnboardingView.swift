//
//  OnbardingView.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 12.08.2024.
//

import SwiftUI

struct OnboardingView: View {
    init() {
        self.setupPageControlAppearance()
    }
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
    private func setupPageControlAppearance() {
        UIPageControl.appearance().currentPageIndicatorTintColor = UIColor.colorLisRose // Active dot color
        UIPageControl.appearance().pageIndicatorTintColor = UIColor.colorLisBlue // Inactive dot color
    }
}

extension OnboardingView {
    private var page1: some View {
        OnboardingPageView(
            image: Image("Ilustrations/howTo1"),
            text: Text("onboarding.description.find")
        )
    }
    
    private var page2: some View {
        OnboardingPageView(
            image: Image("Ilustrations/messages_news"),
            text: Text("onboarding.description.web")
        )
    }
    
    private var page3: some View {
        OnboardingPageView(
            image: Image("Ilustrations/howTo2"),
            text: Text("onboarding.description.activity")
        )
    }
    
    private var page4: some View {
        OnboardingPageView(
            image: Image("Ilustrations/home"),
            text: Text("onboarding.description.point")
        )
    }
    
    private var page5: some View {
        OnboardingPageView(
            image: Image("Ilustrations/ranking"),
            text: Text("onboarding.description.prizes")
        )
    }
    
    private var page6: some View {
        OnboardingPageView(
            image: Image("Ilustrations/helpDesk"),
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
