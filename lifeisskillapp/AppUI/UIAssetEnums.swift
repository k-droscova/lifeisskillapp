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
}

enum CustomImages: String {
    case scanningFrame = "frame"
    
    enum Screens: String {
        case home = "Ilustrations/home"
        case login = "Ilustrations/login"
        case helpDesk = "Ilustrations/helpDesk"
        case howTo1 = "Ilustrations/howTo1"
        case howTo2 = "Ilustrations/howTo2"
        case messagesNews = "Ilustrations/messages_news"
        case rank = "Ilustrations/ranking"
        case signUp = "Ilustrations/signUp"
    }
    
    enum CornerIcons: String {
        case backPink = "Icons/CornerIcons/back_pink"
        case backBlack = "Icons/CornerIcons/back"
        case changeUserData =
        "Icons/CornerIcons/changeUserData"
        case flashOn = "Icons/CornerIcons/flashOn"
        case flashOff = "Icons/CornerIcons/flashOff"
        case message = "Icons/CornerIcons/message"
        case prizes = "Icons/CornerIcons/prizes"
        case settings = "Icons/CornerIcons/settings"
    }
    
    enum MapIcons: String {
        case culture = "Icons/Map/culture"
        case ecology = "Icons/Map/ecology"
        case sport = "Icons/Map/sport"
    }
    
    enum Notifications: String {
        case emailOn = "Icons/Notifications/Email/On"
        case emailOff = "Icons/Notifications/Email/Off"
        case phoneOn = "Icons/Notifications/Phone/On"
        case phoneOff = "Icons/Notifications/Phone/Off"
    }
    
    enum Rankings: String {
        case first = "Icons/Rankings/firstPlace"
        case second = "Icons/Rankings/secondPlace"
        case third = "Icons/Rankings/thirdPlace"
    }
    
    enum TabBar {
        enum Home: String {
            case pink = "Icons/TabBar/Home/Pink"
            case black = "Icons/TabBar/Home/Black"
        }
        enum Map: String {
            case pink = "Icons/TabBar/Map/Pink"
            case black = "Icons/TabBar/Map/Black"
        }
        enum News: String {
            case pink = "Icons/TabBar/News/Pink"
            case black = "Icons/TabBar/News/Black"
        }
        enum Profile: String {
            case pink = "Icons/TabBar/Profile/Pink"
            case black = "Icons/TabBar/Profile/Black"
        }
        enum Rank: String {
            case pink = "Icons/TabBar/Rank/Pink"
            case black = "Icons/TabBar/Rank/Black"
        }
    }
    
    enum Avatar: String {
        case male = "pointListBoy"
        case female = "pointListGirl"
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
}
