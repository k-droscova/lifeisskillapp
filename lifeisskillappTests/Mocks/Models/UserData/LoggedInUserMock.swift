//
//  LoggedInUserMock.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 28.09.2024.
//

@testable import lifeisskillapp
import Foundation

extension LoggedInUser {
    static func mock(
        userId: String = "mockUserId",
        email: String = "mockEmail@example.com",
        nick: String = "mockNick",
        sex: UserGender = .male,
        rights: Int = 1,
        rightsCoded: String = "mockRightsCoded",
        token: String = "mockToken",
        userRank: Int = 10,
        userPoints: Int = 100,
        distance: Int = 50,
        mainCategory: String = "mockMainCategory",
        fullActivation: Bool = true,
        activationStatus: UserActivationStatus = .fullyActivated,
        name: String? = "John",
        surname: String? = "Doe",
        mobil: String? = "+1234567890",
        postalCode: String? = "12345",
        birthday: Date? = Date(),
        nameParent: String? = "Jane",
        surnameParent: String? = "Doe",
        emailParent: String? = "parent@example.com",
        mobilParent: String? = "+0987654321",
        relation: String? = "Parent"
    ) -> LoggedInUser {
        return LoggedInUser(
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
}
