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
    private let labelView: (T) -> Text
    
    init(options: [T], selectedOption: Binding<T?>, placeholder: Text = Text("home.category_selector"), labelView: @escaping (T) -> Text) {
        self.options = options
        self._selectedOption = selectedOption
        self.placeholder = placeholder
        self.labelView = labelView
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
                if let selectedOption {
                    labelView(selectedOption)
                } else {
                    placeholder
                }
                SFSSymbols.expandDown.image
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
    let backgroundColor: Color
    let foregroundColor: Color
    let cornerRadius: CGFloat
    let shadowColor: Color
    let shadowRadius: CGFloat
    let shadowX: CGFloat
    let shadowY: CGFloat
    
    // Initializer with default values
    init(
        backgroundColor: Color,
        foregroundColor: Color,
        cornerRadius: CGFloat = CustomSizes.ListCard.cornerRadius.size,
        shadowColor: Color = CustomColors.ListCard.shadow.color,
        shadowRadius: CGFloat = CustomSizes.ListCard.shadowRadius.size,
        shadowX: CGFloat = CustomSizes.ListCard.shadowX.size,
        shadowY: CGFloat = CustomSizes.ListCard.shadowY.size,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.backgroundColor = backgroundColor
        self.foregroundColor = foregroundColor
        self.cornerRadius = cornerRadius
        self.shadowColor = shadowColor
        self.shadowRadius = shadowRadius
        self.shadowX = shadowX
        self.shadowY = shadowY
        self.content = content
    }
    
    var body: some View {
        content()
            .background(backgroundColor)
            .foregroundStyle(foregroundColor)
            .cornerRadius(cornerRadius)
            .shadow(
                color: shadowColor,
                radius: shadowRadius,
                x: shadowX,
                y: shadowY
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
    }
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
    var padding: CGFloat = 0
    let userNameTextHeight: CGFloat = CustomSizes.UserPointsTopLeftButtonsView.referenceUserNameTextHeight.size
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
        
        self.padding = self.calculatePadding(imageSize: imageSize, usernameTextSize: userNameTextHeight)
    }
    
    var body: some View {
        HStack(spacing: CustomSizes.UserPointsTopLeftButtonsView.horizontalPadding.size) {
            Button(action: {
                mapButtonAction()
            }) {
                SFSSymbols.map.image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .squareFrame(size: imageSize)
                    .foregroundColor(isMapShown ? buttonPressed : buttonNotPressed)
            }
            Button(action: {
                listButtonAction()
            }) {
                SFSSymbols.list.image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .squareFrame(size: imageSize)
                    .foregroundColor(!isMapShown ? buttonPressed : buttonNotPressed)
            }
        }
        .padding(self.padding)
    }
    
    // Ensures padding that fits into the line Height of UserName Text Height in home/rank screens so that the category selector appears always in the same position
    private func calculatePadding(imageSize: CGFloat, usernameTextSize: CGFloat) -> CGFloat {
        guard usernameTextSize > imageSize else { return 0}
        let result = (usernameTextSize - imageSize) / 2.0
        return result
    }
}

struct OnboardingPageView: View {
    let image: Image
    let text: Text
    
    var body: some View {
        VStack(spacing: CustomSizes.OnboardingPageView.verticalSpacing.size) {
            imageView
            textView
        }
        .padding(.horizontal, CustomSizes.OnboardingPageView.horizontalPadding.size)
    }
    
    private var imageView: some View {
        image
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(height: CustomSizes.OnboardingPageView.frameHeight.size)
    }
    
    private var textView: some View {
        text
            .body1Regular
            .multilineTextAlignment(.center)
    }
}

struct CustomTextField<Content: View>: View {
    let placeholder: LocalizedStringKey
    @Binding var text: String
    
    // MARK: optional arguments, can be customized in init, defaults to generic LiS textfield style
    let isSecure: Bool
    let backgroundColor: Color
    let foregroundColor: Color
    let cornerRadius: CGFloat
    let kernig: CGFloat
    let showsValidationMessage: Bool
    let validationTextColor: Color
    var validationMessage: LocalizedStringKey? = nil
    @ViewBuilder var sendButton: () -> Content  // Optional sendButton content
    
    init(placeholder: LocalizedStringKey,
         text: Binding<String>,
         isSecure: Bool = false,
         backgroundColor: Color = CustomColors.TextFieldView.background.color,
         foregroundColor: Color = CustomColors.TextFieldView.foreground.color,
         cornerRadius: CGFloat = CustomSizes.TextFieldView.cornerRadius.size,
         kernig: CGFloat = CustomSizes.TextFieldView.kernig.size,
         showsValidationMessage: Bool = false,
         validationTextColor: Color = .colorLisRed,
         validationMessage: LocalizedStringKey? = nil,
         @ViewBuilder sendButton: @escaping () -> Content = { EmptyView() }) {
        
        self.placeholder = placeholder
        self._text = text
        self.isSecure = isSecure
        self.backgroundColor = backgroundColor
        self.foregroundColor = foregroundColor
        self.cornerRadius = cornerRadius
        self.kernig = kernig
        self.showsValidationMessage = showsValidationMessage
        self.validationTextColor = validationTextColor
        self.validationMessage = validationMessage
        self.sendButton = sendButton
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: CustomSizes.TextFieldView.verticalSpacing.size) {
            Text(text.isEmpty ? " " : placeholder)
                .body1Regular
                .foregroundStyle(foregroundColor)
                .transition(.move(edge: .top))
                .padding(.horizontal, CustomSizes.TextFieldView.horizontalPaddingTitleAndValidationMessage.size)
            
            HStack(alignment: .center) {
                textField
                    .foregroundStyle(foregroundColor)
                sendButton()
            }
            .padding()
            .background(backgroundColor)
            .cornerRadius(cornerRadius)
            .kerning(kernig)
            .body1Regular
            
            if showsValidationMessage {
                validatioMessageField
                    .caption
                    .foregroundStyle(validationTextColor)
                    .padding(.horizontal, CustomSizes.TextFieldView.horizontalPaddingTitleAndValidationMessage.size)
            }
        }
    }
    
    private var textField: some View {
        Group {
            if isSecure {
                SecureField(placeholder, text: $text)
            } else {
                TextField(placeholder, text: $text)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
            }
        }
    }
    
    private var validatioMessageField: some View {
        Group {
            if let validationMessage = validationMessage {
                Text(validationMessage)
            } else {
                Text(" ")  // Placeholder text to maintain layout stability
            }
        }
        .frame(height: CustomSizes.TextFieldView.validationMessageFrame.size)  // Reserve space for validation message, should equal lineHeight of .caption
    }
}

struct ProfileDetailRow: View {
    let title: LocalizedStringKey
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .subheadlineBold
            Spacer()
            Text(value)
                .body1Regular
        }
    }
}

struct CameraOverlayView<CenterView: View>: View {
    let topInset: CGFloat
    let exitButtonAction: () -> Void
    let flashAction: () -> Void
    let isFlashOn: Binding<Bool>
    let instructions: LocalizedStringKey
    let centerView: CenterView?
    
    init(
        topInset: CGFloat,
        exitButtonAction: @escaping () -> Void,
        flashAction: @escaping () -> Void,
        isFlashOn: Binding<Bool>,
        instructions: LocalizedStringKey,
        @ViewBuilder centerView: () -> CenterView? = { nil }
    ) {
        self.topInset = topInset
        self.exitButtonAction = exitButtonAction
        self.flashAction = flashAction
        self.isFlashOn = isFlashOn
        self.instructions = instructions
        self.centerView = centerView()
    }
    
    var body: some View {
        VStack {
            topButtons
                .padding(.top, topInset)
            if let centerView = centerView {
                Spacer(minLength: CustomSizes.QROverlayView.spacingBetweenSections.size)
                centerView
                Spacer(minLength: CustomSizes.QROverlayView.spacingBetweenSections.size)
            } else {
                Spacer()
            }
            instructionsView
        }
        .padding(.horizontal, CustomSizes.QROverlayView.buttonPaddingHorizontal.size)
    }
    
    private var topButtons: some View {
        HStack {
            ExitButton(action: exitButtonAction)
            Spacer()
            FlashButton(
                action: flashAction,
                flashOn: isFlashOn
            )
        }
    }
    
    private var instructionsView: some View {
        Text(instructions)
            .foregroundColor(CustomColors.QROverlayView.instructionsText.color)
            .multilineTextAlignment(.center)
            .padding()
            .background(CustomColors.QROverlayView.instructionsBackground.color)
            .cornerRadius(CustomSizes.QROverlayView.instructionsCornerRadius.size)
            .padding(.bottom, CustomSizes.QROverlayView.instructionsBottomPadding.size)
    }
}

struct QROverlayView: View {
    let topInset: CGFloat
    let exitButtonAction: () -> Void
    let flashAction: () -> Void
    let isFlashOn: Binding<Bool>
    let instructions: LocalizedStringKey
    
    var body: some View {
        CameraOverlayView(
            topInset: topInset,
            exitButtonAction: exitButtonAction,
            flashAction: flashAction,
            isFlashOn: isFlashOn,
            instructions: instructions
        ) {
            Image(CustomImages.Miscellaneous.scanningFrame.fullPath)
                .resizable()
                .aspectRatio(contentMode: .fit)
        }
    }
}

struct PhoneTextField: View {
    let placeholder: LocalizedStringKey
    @Binding var text: String
    @Binding var selectedCountry: Country?
    
    // Optional arguments
    let countries: [Country]
    let backgroundColor: Color
    let foregroundColor: Color
    let cornerRadius: CGFloat
    let kernig: CGFloat
    let showsValidationMessage: Bool
    let validationTextColor: Color
    var validationMessage: LocalizedStringKey? = nil
    
    init(
        placeholder: LocalizedStringKey = "register.phone_number",
        text: Binding<String>,
        selectedCountry: Binding<Country?>,
        countries: [Country],
        backgroundColor: Color = CustomColors.TextFieldView.background.color,
        foregroundColor: Color = CustomColors.TextFieldView.foreground.color,
        cornerRadius: CGFloat = CustomSizes.TextFieldView.cornerRadius.size,
        kernig: CGFloat = CustomSizes.TextFieldView.kernig.size,
        showsValidationMessage: Bool = true,
        validationTextColor: Color = .colorLisRed,
        validationMessage: LocalizedStringKey? = nil
    ) {
        self.placeholder = placeholder
        self._text = text
        self._selectedCountry = selectedCountry
        self.countries = countries
        self.backgroundColor = backgroundColor
        self.foregroundColor = foregroundColor
        self.cornerRadius = cornerRadius
        self.kernig = kernig
        self.showsValidationMessage = showsValidationMessage
        self.validationTextColor = validationTextColor
        self.validationMessage = validationMessage
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: CustomSizes.TextFieldView.verticalSpacing.size) {
            Text(text.isEmpty ? " " : placeholder)
                .body1Regular
                .foregroundStyle(foregroundColor)
                .transition(.move(edge: .top))
                .padding(.horizontal, CustomSizes.TextFieldView.horizontalPaddingTitleAndValidationMessage.size)
            
            HStack(alignment: .center) {
                countryMenu
                    .foregroundColor(foregroundColor)
                
                textField
                    .foregroundStyle(foregroundColor)
            }
            .padding(12)
            .background(backgroundColor)
            .cornerRadius(cornerRadius)
            .kerning(kernig)
            .body1Regular
            
            if showsValidationMessage {
                validatioMessageField
                    .caption
                    .foregroundStyle(validationTextColor)
                    .padding(.horizontal, CustomSizes.TextFieldView.horizontalPaddingTitleAndValidationMessage.size)
            }
        }
    }
    
    private var countryMenu: some View {
        DropdownMenu(
            options: countries,
            selectedOption: $selectedCountry,
            placeholder: Text("register.phone_menu"),
            labelView: { country in
                Text("\(country.flagEmoji) +\(country.phone)")
            }
        )
        .foregroundColor(foregroundColor)
    }
    
    private var textField: some View {
        TextField(placeholder, text: $text)
            .autocapitalization(.none)
            .disableAutocorrection(true)
    }
    
    private var validatioMessageField: some View {
        Group {
            if let validationMessage = validationMessage {
                Text(validationMessage)
            } else {
                Text(" ")  // Placeholder text to maintain layout stability
            }
        }
        .frame(height: CustomSizes.TextFieldView.validationMessageFrame.size)  // Reserve space for validation message, should equal lineHeight of .caption
    }
}

struct ScreenResizingImage: View {
    let Image: Image
    let screenHeight = UIScreen.main.bounds.height
    let heightScreenRatio: CGFloat
    
    init(Image: Image,
         heightScreenRatio: CGFloat = 0.25
         
    ) {
        self.Image = Image
        self.heightScreenRatio = heightScreenRatio
    }
    var body: some View {
        Image
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(height: screenHeight * heightScreenRatio)
    }
}
