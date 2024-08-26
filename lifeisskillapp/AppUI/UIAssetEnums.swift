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
    case camera = "xmark"
    case list = "list.bullet"
    case map = "map"
    
    var Image: Image {
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
    
    enum CornerIcons: String {
        private static let basePath = "Icons/CornerIcons/"
        
        case backPink = "back_pink"
        case backBlack = "back"
        case changeUserData = "changeUserData"
        case flashOn = "flashOn"
        case flashOff = "flashOff"
        case message = "message"
        case prizes = "prizes"
        case settings = "settings"
        
        var fullPath: String {
            CornerIcons.basePath + self.rawValue
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
        case defaultImage = "howTo1"
        
        var fullPath: String {
            ForgotPassword.basePath + self.rawValue
        }
    }
}

enum CustomColors {
    enum TabBar {
        case background, unselectedItem, selectedItem, selectedBackground
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
        case foreground, background
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
        case foreground, shadow
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
        case statusOn, statusOff, foreground
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
        case foreground, invalidPoint, shadow
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
}

enum CustomSizes {
    enum ListCard {
        case verticalPadding, cornerRadius, shadowRadius, shadowX, shadowY
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
        case cornerRadius, shadowRadius, paddingVertical, paddingHorizontal
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
        case horizontalPadding, referenceUserNameTextHeight
        var size: CGFloat {
            switch self {
            case .horizontalPadding:
                24
            case .referenceUserNameTextHeight:
                24 // MARK: should always equal to the lineHeight of the selcted font for userName Text used in top left corner of home and rank screens
            }
        }
    }
    
    enum OnboardingPageView {
        case verticalSpacing, horizontalPadding, frameHeight
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
        case verticalSpacing, horizontalPadding, frameHeight
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
