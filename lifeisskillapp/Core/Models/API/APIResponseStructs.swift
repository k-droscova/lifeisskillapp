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
    
    public init(appId: String, versionCode: Int) {
        self.appId = appId
        self.versionCode = versionCode
    }
}

public typealias LoginUserData = LoginAPIResponse

public struct LoginAPIResponse: DataProtocol {
    let user: LoggedInUser
    
    enum CodingKeys: String, CodingKey {
        case userId, email, nick, rights, rightsCoded, token, userRank, userPoints, sex, distance, mainCategory, fullActivation, activationStatus
        case name, surname, mobil, zip, birthday, nameParent, surnameParent, emailParent, mobilParent, relation
    }
    
    public init(user: LoggedInUser) {
        self.user = user
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
        let activationStatus = try container.decode(UserActivationStatus.self, forKey: .activationStatus)
        
        // Decode optional strings, only set them if they are non-empty
        let name = try container.decodeNonEmptyString(forKey: .name)
        let surname = try container.decodeNonEmptyString(forKey: .surname)
        let mobil = try container.decodeNonEmptyString(forKey: .mobil)
        let postalCode = try container.decodeNonEmptyString(forKey: .zip)
        let birthdayString = try container.decodeIfPresent(String.self, forKey: .birthday)
        let birthday: Date? = Date.Backend.fromBirthday(dateString: birthdayString ?? "")
        
        // Decode optional parent information fields, only set them if they are non-empty
        let nameParent = try container.decodeNonEmptyString(forKey: .nameParent)
        let surnameParent = try container.decodeNonEmptyString(forKey: .surnameParent)
        let emailParent = try container.decodeNonEmptyString(forKey: .emailParent)
        let mobilParent = try container.decodeNonEmptyString(forKey: .mobilParent)
        let relation = try container.decodeNonEmptyString(forKey: .relation)
        
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
            activationStatus: activationStatus,
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
        try container.encode(user.activationStatus, forKey: .activationStatus)
        
        // Only encode optional fields if they are not nil
        try container.encodeIfPresent(user.name, forKey: .name)
        try container.encodeIfPresent(user.surname, forKey: .surname)
        try container.encodeIfPresent(user.mobil, forKey: .mobil)
        try container.encodeIfPresent(user.postalCode, forKey: .zip)
        if let birthday = user.birthday {
            try container.encodeIfPresent(Date.Backend.getBirthdayString(from: birthday), forKey: .birthday)
        }
        try container.encodeIfPresent(user.nameParent, forKey: .nameParent)
        try container.encodeIfPresent(user.surnameParent, forKey: .surnameParent)
        try container.encodeIfPresent(user.emailParent, forKey: .emailParent)
        try container.encodeIfPresent(user.mobilParent, forKey: .mobilParent)
        try container.encodeIfPresent(user.relation, forKey: .relation)
    }
    
    internal init(from: LoggedInUser) {
        self.user = from
    }
}

public struct CheckSumUserPointsData: DataProtocol {
    let pointsProtect: String
    
    public init(pointsProtect: String) {
        self.pointsProtect = pointsProtect
    }
}

public struct CheckSumRankData: DataProtocol {
    let rankProtect: String
    
    public init(rankProtect: String) {
        self.rankProtect = rankProtect
    }
}

public struct CheckSumMessagesData: DataProtocol {
    let msgProtect: String
    
    public init(msgProtect: String) {
        self.msgProtect = msgProtect
    }
}

public struct CheckSumEventsData: DataProtocol {
    let eventsProtect: String
    
    public init(eventsProtect: String) {
        self.eventsProtect = eventsProtect
    }
}

public struct CheckSumPointsData: DataProtocol {
    let pointsProtect: String
    let clusterProtect: String?
    
    public init(pointsProtect: String, clusterProtect: String?) {
        self.pointsProtect = pointsProtect
        self.clusterProtect = clusterProtect
    }
}

public struct UserCategoryData: DataProtocol {
    let main: UserCategory
    let data: [UserCategory]
    
    enum CodingKeys: String, CodingKey {
        case main = "userMainCategory"
        case data = "allUserCategoryList"
    }
    
    public init(from decoder: Decoder) throws {
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
    
    public init(main: UserCategory, data: [UserCategory]) {
        self.main = main
        self.data = data
    }
}

public struct UserPointData: DataProtocol {
    let checkSum: String
    let data: [UserPoint]
    
    enum CodingKeys: String, CodingKey {
        case data = "listPoints"
        case checkSum = "userPointsProtect"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        checkSum = try container.decode(String.self, forKey: .checkSum)
        data = try container.decode([UserPoint].self, forKey: .data)
    }
    
    public init(checkSum: String, data: [UserPoint]) {
        self.checkSum = checkSum
        self.data = data
    }
}

public struct GenericPointData: DataProtocol {
    let checkSum: String
    let data: [GenericPoint]
    
    enum CodingKeys: String, CodingKey {
        case data = "pointsList"
        case checkSum = "pointsProtect"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        checkSum = try container.decode(String.self, forKey: .checkSum)
        data = try container.decode([GenericPoint].self, forKey: .data)
    }
    
    public init(checkSum: String, data: [GenericPoint]) {
        self.checkSum = checkSum
        self.data = data
    }
}

public struct UserRankData: DataProtocol {
    let checkSum: String
    let data: [UserRank]
    
    enum CodingKeys: String, CodingKey {
        case checkSum = "rankProtect"
        case data = "catData"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        checkSum = try container.decode(String.self, forKey: .checkSum)
        data = try container.decode([UserRank].self, forKey: .data)
    }
    
    public init(checkSum: String, data: [UserRank]) {
        self.checkSum = checkSum
        self.data = data
    }
}

public struct ForgotPasswordData: DataProtocol {
    let pin: String
    let message: String
    let userEmail: String
    
    enum CodingKeys: String, CodingKey {
        case pin = "pin"
        case message = "msg"
        case userEmail = "email"
    }
    
    public init(pin: String, message: String, userEmail: String) {
        self.pin = pin
        self.message = message
        self.userEmail = userEmail
    }
    
    public init(from decoder: Decoder) throws {
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

public struct ForgotPasswordConfirmation: DataProtocol {
    let message: Bool
    
    enum CodingKeys: String, CodingKey {
        case message = "Was Changed"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        message = try container.decode(Bool.self, forKey: .message)
    }
    
    public init(message: Bool) {
        self.message = message
    }
}

public struct UsernameAvailabilityResponse: DataProtocol {
    let isAvailable: Bool
    
    enum CodingKeys: String, CodingKey {
        case isAvailable = "isNickAvailable"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        isAvailable = try container.decode(Bool.self, forKey: .isAvailable)
    }
    
    public init(isAvailable: Bool) {
        self.isAvailable = isAvailable
    }
}

public struct EmailAvailabilityResponse: DataProtocol {
    let isAvailable: Bool
    
    enum CodingKeys: String, CodingKey {
        case isAvailable = "isEmailAvailable"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        isAvailable = try container.decode(Bool.self, forKey: .isAvailable)
    }
    
    public init(isAvailable: Bool) {
        self.isAvailable = isAvailable
    }
}

public struct RegistrationResponse: DataProtocol {
    let message: String
    
    enum CodingKeys: String, CodingKey {
        case message = "newUser"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        message = try container.decode(String.self, forKey: .message)
    }
    
    public init(message: String) {
        self.message = message
    }
}

public struct SignatureAPIResponse: DataProtocol {
    let signature: String
    
    enum CodingKeys: String, CodingKey {
        case signature = "token"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        signature = try container.decode(String.self, forKey: .signature)
    }
    
    public init(signature: String) {
        self.signature = signature
    }
}

public struct CompleteRegistrationAPIResponse: DataProtocol {
    let completionStatus: Bool
    let needParentActivation: Bool
    
    enum CodingKeys: String, CodingKey {
        case completionStatus = "userProfileUpdated"
        case needParentActivation = "needParentActivation"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        completionStatus = try container.decode(Bool.self, forKey: .completionStatus)
        needParentActivation = try container.decode(Bool.self, forKey: .needParentActivation)
    }
    
    public init(completionStatus: Bool, needParentActivation: Bool) {
        self.completionStatus = completionStatus
        self.needParentActivation = needParentActivation
    }
}

public struct ParentEmailActivationReponse: DataProtocol {
    let status: Bool
    
    enum CodingKeys: String, CodingKey {
        case status = "parentLinkSent"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        status = try container.decode(Bool.self, forKey: .status)
    }
    
    public init(status: Bool) {
        self.status = status
    }
}
