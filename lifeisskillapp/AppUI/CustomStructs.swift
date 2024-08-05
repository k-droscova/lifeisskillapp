//
//  CustomStructs.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 01.08.2024.
//

import SwiftUI

struct DropdownMenu<T: Identifiable & CustomStringConvertible>: View {
    @Binding private var selectedOption: T?
    private let options: [T]
    private let placeholder: Text

    init(options: [T], selectedOption: Binding<T?>, placeholder: Text = Text("home.category_selector")) {
        self.options = options
        self._selectedOption = selectedOption
        self.placeholder = placeholder
    }

    var body: some View {
        Menu {
            ForEach(options) { option in
                Button(action: {
                    selectedOption = option
                }) {
                    Text(option.description)
                }
            }
        } label: {
            HStack {
                if let description = selectedOption?.description {
                    Text(description)
                }
                else {
                    placeholder
                }
                Image(systemName: "chevron.down")
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .cornerRadius(8)
        }
    }
}

struct CustomProgressView: View {
    var body: some View {
        ZStack {
            CustomColors.ProgressView.background.color
                .edgesIgnoringSafeArea(.all)
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle())
                .foregroundColor(CustomColors.ProgressView.foreground.color)
        }
    }
}

struct ListCard<Content: View>: View {
    let content: () -> Content

    var body: some View {
        content()
            .padding(.vertical, CustomSizes.ListCard.verticalPadding.size)
            .background(CustomColors.ListCard.foreground.color)
            .cornerRadius(CustomSizes.ListCard.cornerRadius.size)
            .shadow(
                color: CustomColors.ListCard.shadow.color,
                radius: CustomSizes.ListCard.shadowRadius.size,
                x: CustomSizes.ListCard.shadowX.size,
                y: CustomSizes.ListCard.shadowY.size
            )
    }
}

struct CategorySelectorContainerView<Content: View>: View {
    private let categorySelectorVC: UIViewController
    private let spacing: CGFloat
    private let content: Content
    
    init(categorySelectorVC: UIViewController, spacing: CGFloat, @ViewBuilder content: () -> Content) {
        self.categorySelectorVC = categorySelectorVC
        self.spacing = spacing
        self.content = content()
    }
    
    var body: some View {
        VStack(spacing: spacing) {
            ViewControllerRepresentable(viewController: categorySelectorVC)
                .frame(height: 100)
            
            content
        }
        .ignoresSafeArea()
    }
}
