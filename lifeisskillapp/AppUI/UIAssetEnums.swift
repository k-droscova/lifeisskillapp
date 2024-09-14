//
//  SFSSymbols.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 31.07.2024.
//

import Foundation
import UIKit
import SwiftUI

enum SFSSymbols: String {
    case close = "xmark"
    case flashOn = "bolt.fill"
    case flashOff = "bolt.slash.fill"
    case list = "list.bullet"
    case map = "map"
    case expandDown = "chevron.down"
    case settingsMenu = "ellipsis.circle"
    case navigationBack = "chevron.backward"
    case qr = "qrcode.viewfinder"
    case camera = "camera.viewfinder"
    case nfc = "tag.square"
    case virtual = "paperplane.circle"
    case instructionsPopover = "questionmark.circle"
    case linkArrow = "arrow.up.forward.app"
    case hideUp = "chevron.up"
    case warning = "exclamationmark.circle.fill"
    case send = "paperplane.fill"
    
    var image: Image {
        SwiftUI.Image(systemName: self.rawValue)
    }
}

enum CustomImages {
    enum Miscellaneous: String {
        private static let basePath = "Miscellaneous/"
        case scanningFrame = "frame"
        
        var fullPath: String {
            Miscellaneous.basePath + self.rawValue
        }
    }
    
    enum Screens: String {
        private static let basePath = "Ilustrations/"
        case home = "home"
        case login = "login"
        case helpDesk = "helpDesk"
        case howTo1 = "howTo1"
        case howTo2 = "howTo2"
        case messagesNews = "messages_news"
        case rank = "ranking"
        case signUp = "signUp"
        
        var fullPath: String {
            Screens.basePath + self.rawValue
        }
    }
    
    enum Notifications: String {
        private static let basePath = "Icons/Notifications/"
        case emailOn = "Email/On"
        case emailOff = "Email/Off"
        case phoneOn = "Phone/On"
        case phoneOff = "Phone/Off"
        
        var fullPath: String {
            Notifications.basePath + self.rawValue
        }
    }
    
    enum Rankings: String {
        private static let basePath = "Icons/Rankings/"
        case first = "firstPlace"
        case second = "secondPlace"
        case third = "thirdPlace"
        
        var fullPath: String {
            Rankings.basePath + self.rawValue
        }
    }
    
    enum TabBar {
        private static let basePath = "Icons/TabBar/"
        
        enum Home: String {
            private static let basePath = TabBar.basePath + "Home/"
            case pink = "Pink"
            case black = "Black"
            
            var fullPath: String {
                Home.basePath + self.rawValue
            }
        }
        
        enum Map: String {
            private static let basePath = TabBar.basePath + "Map/"
            case pink = "Pink"
            case black = "Black"
            
            var fullPath: String {
                Map.basePath + self.rawValue
            }
        }
        
        enum News: String {
            private static let basePath = TabBar.basePath + "News/"
            case pink = "Pink"
            case black = "Black"
            
            var fullPath: String {
                News.basePath + self.rawValue
            }
        }
        
        enum Profile: String {
            private static let basePath = TabBar.basePath + "Profile/"
            case pink = "Pink"
            case black = "Black"
            
            var fullPath: String {
                Profile.basePath + self.rawValue
            }
        }
        
        enum Rank: String {
            private static let basePath = TabBar.basePath + "Rank/"
            case pink = "Pink"
            case black = "Black"
            
            var fullPath: String {
                Rank.basePath + self.rawValue
            }
        }
    }
    
    enum Avatar: String {
        private static let basePath = "Avatars/"
        case male = "pointListBoy"
        case female = "pointListGirl"
        
        var fullPath: String {
            Avatar.basePath + self.rawValue
        }
    }
    
    enum Map: String {
        private static let basePath = "Icons/Map/"
        case sport = "sport"
        case environment = "nature"
        case culture = "culture"
        case tourist = "tourist"
        case energySponsor = "7en_green"
        case virtual = "virtual"
        case unknown = "unknown"
        
        var fullPath: String {
            Map.basePath + self.rawValue
        }
    }
    
    enum ForgotPassword: String {
        private static let basePath = "Ilustrations/"
        case defaultImage = "helpDesk"
        
        var fullPath: String {
            ForgotPassword.basePath + self.rawValue
        }
    }
}

enum CustomColors {
    enum TabBar {
        case background
        case unselectedItem
        case selectedItem
        case selectedBackground
        
        var color: UIColor {
            switch self {
            case .background:
                UIColor(.libBaseGray)
            case .unselectedItem:
                UIColor(.libDarkerGray)
            case .selectedItem:
                UIColor(.colorPrimary)
            case .selectedBackground:
                UIColor(.libDarkerGray)
            }
        }
    }
    
    enum ProgressView {
        case foreground
        case background
        
        var color: Color {
            switch self {
            case .foreground:
                Color.white
            case .background:
                Color.blackOverlay
            }
        }
    }
    
    enum ListCard {
        case foreground
        case shadow
        
        var color: Color {
            switch self {
            case .foreground:
                Color.white
            case .shadow:
                Color.blackOverlay
            }
        }
    }
    
    enum LocationStatusBar {
        case statusOn
        case statusOff
        case foreground
        
        var color: Color {
            switch self {
            case .statusOn:
                Color.colorLisGreen
            case .statusOff:
                Color.colorLisRed
            case .foreground:
                Color.colorLisDarkGrey
            }
        }
    }
    
    enum ListPointCard {
        case foreground
        case invalidPoint
        case shadow
        
        var color: Color {
            switch self {
            case .foreground:
                Color.white
            case .invalidPoint:
                Color.colorLisDarkGrey
            case .shadow:
                Color.blackOverlay
            }
        }
    }
    
    enum TextFieldView {
        case foreground
        case background
        var color: Color {
            switch self {
            case .foreground:
                Color.colorLisDarkGrey
            case .background:
                Color.lighterGrey
            }
        }
    }
    
    enum QROverlayView {
        case instructionsText
        case instructionsBackground
        
        var color: Color {
            switch self {
            case .instructionsText:
                Color.white
            case .instructionsBackground:
                Color.black.opacity(0.5)
            }
        }
    }
}

enum CustomSizes {
    enum ListCard {
        case verticalPadding
        case cornerRadius
        case shadowRadius
        case shadowX
        case shadowY
        
        var size: CGFloat {
            switch self {
            case .verticalPadding:
                10
            case .cornerRadius:
                8
            case .shadowRadius:
                5
            case .shadowX:
                1
            case .shadowY:
                2
            }
        }
    }
    
    enum PointListCard {
        case cornerRadius
        case shadowRadius
        case paddingVertical
        case paddingHorizontal
        
        var size: CGFloat {
            switch self {
            case .cornerRadius:
                10
            case .shadowRadius:
                2
            case .paddingVertical:
                4
            case .paddingHorizontal:
                24
            }
        }
    }
    
    enum UserPointsTopLeftButtonsView {
        case horizontalPadding
        case referenceUserNameTextHeight
        
        var size: CGFloat {
            switch self {
            case .horizontalPadding:
                24
            case .referenceUserNameTextHeight:
                24 // Should match lineHeight of the selected font for userName Text
            }
        }
    }
    
    enum OnboardingPageView {
        case verticalSpacing
        case horizontalPadding
        case frameHeight
        
        var size: CGFloat {
            switch self {
            case .verticalSpacing:
                64
            case .horizontalPadding:
                32
            case .frameHeight:
                300
            }
        }
    }
    
    enum ForgotPasswordPageView {
        case verticalSpacing
        case horizontalPadding
        case frameHeight
        
        var size: CGFloat {
            switch self {
            case .verticalSpacing:
                32
            case .horizontalPadding:
                32
            case .frameHeight:
                300
            }
        }
    }
    
    enum TextFieldView {
        case cornerRadius
        case kernig
        case verticalSpacing
        case horizontalPaddingTitleAndValidationMessage
        case validationMessageFrame
        var size: CGFloat {
            switch self {
            case .cornerRadius:
                10
            case .kernig:
                1.2
            case .verticalSpacing:
                4
            case .horizontalPaddingTitleAndValidationMessage:
                12
            case .validationMessageFrame:
                16
            }
        }
    }
    
    enum QROverlayView {
        case buttonPaddingHorizontal
        case spacingBetweenSections
        case instructionsBottomPadding
        case instructionsCornerRadius
        
        var size: CGFloat {
            switch self {
            case .buttonPaddingHorizontal:
                return 16
            case .spacingBetweenSections:
                return 32
            case .instructionsBottomPadding:
                return 96
            case .instructionsCornerRadius:
                return 10
            }
        }
    }
}

enum ForgotPasswordPagesConstants {
    static let topPadding: CGFloat = 32
    static let bottomPadding: CGFloat = 32
    static let cornerRadius: CGFloat = 10
    
    enum Colors {
        static let textFieldBackground = Color.lighterGrey
        static let button = Color.colorLisBlue
        static let buttonText = Color.white
        static let enabledButton = Color.colorLisGreen
        static let disabledButton = Color.colorLisGrey
        static let enabledText = Color.white
        static let disabledText = Color.colorLisDarkGrey
    }
}
