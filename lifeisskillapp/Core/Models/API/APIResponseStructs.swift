//
//  RegisterAppAPIResponse.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 07.07.2024.
//

import Foundation

public struct RegisterAppAPIResponse: DataProtocol {
    let appId: String
    let versionCode: Int
}

typealias LoginUserData = LoginAPIResponse

public struct LoginAPIResponse: DataProtocol {
    let user: LoggedInUser
    
    enum CodingKeys: String, CodingKey {
        case userId, email, nick, rights, rightsCoded, token, userRank, userPoints, sex, distance, mainCategory, fullActivation
        case name, surname, mobil, zip, birthday, nameParent, surnameParent, emailParent, mobilParent, relation
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let userId = try container.decode(String.self, forKey: .userId)
        let email = try container.decode(String.self, forKey: .email)
        let nick = try container.decode(String.self, forKey: .nick)
        let rights = try container.decode(Int.self, forKey: .rights)
        let rightsCoded = try container.decode(String.self, forKey: .rightsCoded)
        let token = try container.decode(String.self, forKey: .token)
        let userRank = try container.decode(Int.self, forKey: .userRank)
        let userPoints = try container.decode(Int.self, forKey: .userPoints)
        let sex = try container.decode(UserGender.self, forKey: .sex)
        let distance = try container.decode(Int.self, forKey: .distance)
        let mainCategory = try container.decode(String.self, forKey: .mainCategory)
        let fullActivation = try container.decode(Bool.self, forKey: .fullActivation)
        
        // Decode optional strings, only set them if they are non-empty
        let name = try container.decodeIfPresent(String.self, forKey: .name).flatMap { $0.isEmpty ? nil : $0 }
        let surname = try container.decodeIfPresent(String.self, forKey: .surname).flatMap { $0.isEmpty ? nil : $0 }
        let mobil = try container.decodeIfPresent(String.self, forKey: .mobil).flatMap { $0.isEmpty ? nil : $0 }
        let postalCode = try container.decodeIfPresent(String.self, forKey: .zip).flatMap { $0.isEmpty ? nil : $0 }
        
        // Decode the birthday string and convert it to a Date using your date formatter
        let birthdayString = try container.decodeIfPresent(String.self, forKey: .birthday)
        let birthday: Date? = birthdayString.flatMap { $0.isEmpty ? nil : Formatters.birthdayFormatter.date(from: $0) }
        
        // Decode optional parent information fields, only set them if they are non-empty
        let nameParent = try container.decodeIfPresent(String.self, forKey: .nameParent).flatMap { $0.isEmpty ? nil : $0 }
        let surnameParent = try container.decodeIfPresent(String.self, forKey: .surnameParent).flatMap { $0.isEmpty ? nil : $0 }
        let emailParent = try container.decodeIfPresent(String.self, forKey: .emailParent).flatMap { $0.isEmpty ? nil : $0 }
        let mobilParent = try container.decodeIfPresent(String.self, forKey: .mobilParent).flatMap { $0.isEmpty ? nil : $0 }
        let relation = try container.decodeIfPresent(String.self, forKey: .relation).flatMap { $0.isEmpty ? nil : $0 }
        
        // Initialize LoggedInUser
        self.user = LoggedInUser(
            userId: userId,
            email: email,
            nick: nick,
            sex: sex,
            rights: rights,
            rightsCoded: rightsCoded,
            token: token,
            userRank: userRank,
            userPoints: userPoints,
            distance: distance,
            mainCategory: mainCategory,
            fullActivation: fullActivation,
            name: name,
            surname: surname,
            mobil: mobil,
            postalCode: postalCode,
            birthday: birthday,
            nameParent: nameParent,
            surnameParent: surnameParent,
            emailParent: emailParent,
            mobilParent: mobilParent,
            relation: relation
        )
    }
    
    // MARK: - Encoder
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(user.userId, forKey: .userId)
        try container.encode(user.email, forKey: .email)
        try container.encode(user.nick, forKey: .nick)
        try container.encode(user.rights, forKey: .rights)
        try container.encode(user.rightsCoded, forKey: .rightsCoded)
        try container.encode(user.token, forKey: .token)
        try container.encode(user.userRank, forKey: .userRank)
        try container.encode(user.userPoints, forKey: .userPoints)
        try container.encode(user.sex, forKey: .sex)
        try container.encode(user.distance, forKey: .distance)
        try container.encode(user.mainCategory, forKey: .mainCategory)
        try container.encode(user.fullActivation, forKey: .fullActivation)
        
        // Only encode optional fields if they are not nil
        if let name = user.name {
            try container.encode(name, forKey: .name)
        }
        
        if let surname = user.surname {
            try container.encode(surname, forKey: .surname)
        }
        
        if let mobil = user.mobil {
            try container.encode(mobil, forKey: .mobil)
        }
        
        if let postalCode = user.postalCode {
            try container.encode(postalCode, forKey: .zip)
        }
        
        if let birthday = user.birthday {
            // Format birthday as string before encoding
            let birthdayString = Formatters.birthdayFormatter.string(from: birthday)
            try container.encode(birthdayString, forKey: .birthday)
        }
        
        if let nameParent = user.nameParent {
            try container.encode(nameParent, forKey: .nameParent)
        }
        
        if let surnameParent = user.surnameParent {
            try container.encode(surnameParent, forKey: .surnameParent)
        }
        
        if let emailParent = user.emailParent {
            try container.encode(emailParent, forKey: .emailParent)
        }
        
        if let mobilParent = user.mobilParent {
            try container.encode(mobilParent, forKey: .mobilParent)
        }
        
        if let relation = user.relation {
            try container.encode(relation, forKey: .relation)
        }
    }
    
    internal init(from: LoggedInUser) {
        self.user = from
    }
}

public struct CheckSumUserPointsData: DataProtocol {
    let pointsProtect: String
}

public struct CheckSumRankData: DataProtocol {
    let rankProtect: String
}

public struct CheckSumMessagesData: DataProtocol {
    let msgProtect: String
}

public struct CheckSumEventsData: DataProtocol {
    let eventsProtect: String
}

public struct CheckSumPointsData: DataProtocol {
    let pointsProtect: String
    let clusterProtect: String?
}

struct UserCategoryData: DataProtocol {
    let main: UserCategory
    let data: [UserCategory]
    
    enum CodingKeys: String, CodingKey {
        case main = "userMainCategory"
        case data = "allUserCategoryList"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        // Decode the main category ID
        let mainCategoryID = try container.decode(String.self, forKey: .main)
        // Decode the list of all user categories
        let allUserCategories = try container.decode([UserCategory].self, forKey: .data)
        // Find the main category from the list
        guard let mainCategory = allUserCategories.first(where: { $0.id == mainCategoryID }) else {
            throw DecodingError.dataCorruptedError(forKey: .main, in: container, debugDescription: "Main category ID does not match any category in the list")
        }
        // Assign the found main category and the list of categories
        self.main = mainCategory
        self.data = allUserCategories
    }
    
    internal init(main: UserCategory, data: [UserCategory]) {
        self.main = main
        self.data = data
    }
}

struct UserPointData: DataProtocol {
    let checkSum: String
    let data: [UserPoint]
    
    enum CodingKeys: String, CodingKey {
        case data = "listPoints"
        case checkSum = "userPointsProtect"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        checkSum = try container.decode(String.self, forKey: .checkSum)
        data = try container.decode([UserPoint].self, forKey: .data)
    }
    
    internal init(checkSum: String, data: [UserPoint]) {
        self.checkSum = checkSum
        self.data = data
    }
}

struct GenericPointData: DataProtocol {
    let checkSum: String
    let data: [GenericPoint]
    
    enum CodingKeys: String, CodingKey {
        case data = "pointsList"
        case checkSum = "pointsProtect"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        checkSum = try container.decode(String.self, forKey: .checkSum)
        data = try container.decode([GenericPoint].self, forKey: .data)
    }
    
    internal init(checkSum: String, data: [GenericPoint]) {
        self.checkSum = checkSum
        self.data = data
    }
}

struct UserRankData: DataProtocol {
    let checkSum: String
    let data: [UserRank]
    
    enum CodingKeys: String, CodingKey {
        case checkSum = "rankProtect"
        case data = "catData"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        checkSum = try container.decode(String.self, forKey: .checkSum)
        data = try container.decode([UserRank].self, forKey: .data)
    }
    
    internal init(checkSum: String, data: [UserRank]) {
        self.checkSum = checkSum
        self.data = data
    }
}

struct ForgotPasswordData: DataProtocol {
    let pin: String
    let message: String
    let userEmail: String
    
    enum CodingKeys: String, CodingKey {
        case pin = "pin"
        case message = "msg"
        case userEmail = "email"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Decode the base64-encoded pin
        let base64Pin = try container.decode(String.self, forKey: .pin)
        if let pinData = Data(base64Encoded: base64Pin),
           let decodedPin = String(data: pinData, encoding: .utf8) {
            pin = decodedPin
        } else {
            throw DecodingError.dataCorruptedError(forKey: .pin, in: container, debugDescription: "Pin is not valid Base64 encoded string.")
        }
        
        message = try container.decode(String.self, forKey: .message)
        userEmail = try container.decode(String.self, forKey: .userEmail)
    }
}

struct ForgotPasswordConfirmation: DataProtocol {
    let message: Bool
    
    enum CodingKeys: String, CodingKey {
        case message = "Was Changed"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        message = try container.decode(Bool.self, forKey: .message)
    }
}

struct UsernameAvailabilityResponse: DataProtocol {
    let isAvailable: Bool
    
    enum CodingKeys: String, CodingKey {
        case isAvailable = "isNickAvailable"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        isAvailable = try container.decode(Bool.self, forKey: .isAvailable)
    }
}

struct EmailAvailabilityResponse: DataProtocol {
    let isAvailable: Bool
    
    enum CodingKeys: String, CodingKey {
        case isAvailable = "isEmailAvailable"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        isAvailable = try container.decode(Bool.self, forKey: .isAvailable)
    }
}

struct RegistrationResponse: DataProtocol {
    let message: String
    
    enum CodingKeys: String, CodingKey {
        case message = "newUser"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        message = try container.decode(String.self, forKey: .message)
    }
}

struct SignatureAPIResponse: DataProtocol {
    let signature: String
    
    enum CodingKeys: String, CodingKey {
        case signature = "token"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        signature = try container.decode(String.self, forKey: .signature)
    }
}

struct CompleteRegistrationAPIResponse: DataProtocol {
    let completionStatus: Bool
    let needParentActivation: Bool
    
    enum CodingKeys: String, CodingKey {
        case completionStatus = "userProfileUpdated"
        case needParentActivation = "needParentActivation"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        completionStatus = try container.decode(Bool.self, forKey: .completionStatus)
        needParentActivation = try container.decode(Bool.self, forKey: .needParentActivation)
    }
}
