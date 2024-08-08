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

struct CategorySelectorContainerView<TopLeftView: View, Content: View, ViewModel: CategorySelectorViewModeling>: View {
    @StateObject private var viewModel: ViewModel
    private let topLeftView: TopLeftView
    private let spacing: CGFloat
    private let content: () -> Content
    
    internal init(viewModel: ViewModel, topLeftView: TopLeftView, spacing: CGFloat, @ViewBuilder content: @escaping () -> Content) {
        self._viewModel = StateObject(wrappedValue: viewModel)
        self.topLeftView = topLeftView
        self.spacing = spacing
        self.content = content
    }
    
    var body: some View {
        VStack(spacing: spacing) {
            HStack {
                topLeftView
                    .padding()
                Spacer()
                CategorySelectorView(viewModel: self.viewModel)
            }
            .padding(.horizontal, 8)
            content()
        }
    }
}

struct StatusView: View {
    @Binding var status: Bool
    private let textOn: String
    private let textOff: String
    private let colorOn: Color
    private let colorOff: Color

    internal init(status: Binding<Bool>, textOn: String, textOff: String, colorOn: Color, colorOff: Color) {
        self._status = status
        self.textOn = textOn
        self.textOff = textOff
        self.colorOn = colorOn
        self.colorOff = colorOff
    }

    var body: some View {
        Text(status ? textOn : textOff)
            .foregroundColor(status ? colorOn : colorOff)
    }
}

struct StatusBarContainerView<Content: View, ViewModel: SettingsBarViewModeling>: View {
    @StateObject private var viewModel: ViewModel
    private let spacing: CGFloat
    private let content: () -> Content
    
    internal init(viewModel: ViewModel, spacing: CGFloat, @ViewBuilder content: @escaping () -> Content) {
        self._viewModel = StateObject(wrappedValue: viewModel)
        self.spacing = spacing
        self.content = content
    }
    
    var body: some View {
        VStack(spacing: spacing) {
            SettingsBarView(viewModel: viewModel)
            content()
        }
      
      struct PointListCard<Content: View>: View {
    let content: () -> Content
    var body: some View {
        content()
            .cornerRadius(CustomSizes.PointListCard.cornerRadius.size)
            .shadow(radius: CustomSizes.PointListCard.shadowRadius.size)
            .padding(.horizontal, CustomSizes.PointListCard.paddingHorizontal.size)
            .padding(.vertical, CustomSizes.PointListCard.paddingVertical.size)
    }
}

struct ExDivider: View {
    let color: Color
    let height: CGFloat
    var body: some View {
        Rectangle()
            .fill(color)
            .frame(height: height)
            .edgesIgnoringSafeArea(.horizontal)
    }
}

struct UserPointsTopLeftButtonsView: View {
    @Binding var isMapShown: Bool
    
    enum ButtonType {
        case map
        case list
    }
    
    let imageSize: CGFloat
    let buttonNotPressed: Color
    let buttonPressed: Color
    var mapButtonAction: () -> Void
    var listButtonAction: () -> Void
    
    internal init(isMapShown: Binding<Bool>, imageSize: CGFloat, buttonNotPressed: Color, buttonPressed: Color, mapButtonAction: @escaping () -> Void, listButtonAction: @escaping () -> Void) {
        self._isMapShown = isMapShown
        self.imageSize = imageSize
        self.buttonNotPressed = buttonNotPressed
        self.buttonPressed = buttonPressed
        self.mapButtonAction = mapButtonAction
        self.listButtonAction = listButtonAction
    }
    
    var body: some View {
        HStack {
            Button(action: {
                isMapShown = true
                mapButtonAction()
            }) {
                Image(systemName: "map")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .squareFrame(size: imageSize)
                    .foregroundColor(isMapShown ? buttonPressed : buttonNotPressed)
                    .padding()
            }
            Button(action: {
                isMapShown = false
                listButtonAction()
            }) {
                Image(systemName: "list.bullet")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .squareFrame(size: imageSize)
                    .foregroundColor(!isMapShown ? buttonPressed : buttonNotPressed)
                    .padding()
            }
        }
    }
}
