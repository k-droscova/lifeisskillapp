//
//  APIResponseStructMocks.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 28.09.2024.
//

@testable import lifeisskillapp

extension RegisterAppAPIResponse {
    static func mock(
        appId: String = "mockAppId",
        versionCode: Int = 1
    ) -> RegisterAppAPIResponse {
        return RegisterAppAPIResponse(
            appId: appId,
            versionCode: versionCode
        )
    }
}

extension LoginAPIResponse {
    static func mock(
        user: LoggedInUser = .mock()
    ) -> LoginAPIResponse {
        return LoginAPIResponse(user: user)
    }
}

extension ForgotPasswordData {
    static func mock(
        pin: String = "mockPin",
        message: String = "mockMessage",
        userEmail: String = "mockEmail@example.com"
    ) -> ForgotPasswordData {
        return ForgotPasswordData(
            pin: pin,
            message: message,
            userEmail: userEmail
        )
    }
}

extension ForgotPasswordConfirmation {
    static func mock(
        message: Bool = true
    ) -> ForgotPasswordConfirmation {
        return ForgotPasswordConfirmation(
            message: message
        )
    }
}

extension UsernameAvailabilityResponse {
    static func mock(
        isAvailable: Bool = true
    ) -> UsernameAvailabilityResponse {
        return UsernameAvailabilityResponse(
            isAvailable: isAvailable
        )
    }
}

extension EmailAvailabilityResponse {
    static func mock(
        isAvailable: Bool = true
    ) -> EmailAvailabilityResponse {
        return EmailAvailabilityResponse(
            isAvailable: isAvailable
        )
    }
}

extension RegistrationResponse {
    static func mock(
        message: String = "mockNewUser"
    ) -> RegistrationResponse {
        return RegistrationResponse(
            message: message
        )
    }
}

extension UserCategoryData {
    static func mock(
        main: UserCategory = .mock(id: "mainCategory", name: "Main"),
        data: [UserCategory] = [
            .mock(id: "mainCategory", name: "Main"),
            .mock(id: "category1", name: "Category 1"),
            .mock(id: "category2", name: "Category 2")
        ]
    ) -> UserCategoryData {
        return UserCategoryData(
            main: main,
            data: data
        )
    }
}

extension UserPointData {
    static func mock(
        checkSum: String = "mockCheckSum",
        data: [UserPoint] = [
            .mock(id: "point1", pointName: "Sport Point", pointType: .sport, codeSource: .qr),
            .mock(id: "point2", pointName: "Environment Point", pointType: .environment, codeSource: .nfc),
            .mock(id: "point3", pointName: "Culture Point", pointType: .culture, codeSource: .virtual),
            .mock(id: "point4", pointName: "Tourist Point", pointType: .tourist, codeSource: .text),
            .mock(id: "point5", pointName: "Energy Sponsor Point", pointType: .energySponsor, codeSource: .qr),
            .mock(id: "point6", pointName: "Virtual Point", pointType: .virtual, codeSource: .virtual),
            .mock(id: "point7", pointName: "Gastro Point", pointType: .gastro, codeSource: .nfc)
        ]
    ) -> UserPointData {
        return UserPointData(
            checkSum: checkSum,
            data: data
        )
    }
}

extension GenericPointData {
    static func mock(
        checkSum: String = "mockCheckSum",
        data: [GenericPoint] = [
            .mock(
                id: "genericPoint1",
                pointName: "Sport Point",
                pointLat: 50.0755, // Prague coordinates
                pointLng: 14.4378,
                pointType: .sport
            ),
            .mock(
                id: "genericPoint2",
                pointName: "Culture Point",
                pointLat: 50.088, // Slight variation in location
                pointLng: 14.4208,
                pointType: .culture
            ),
            .mock(
                id: "genericPoint3",
                pointName: "Environment Point",
                pointLat: 50.0914,
                pointLng: 14.4265,
                pointType: .environment
            ),
            .mock(
                id: "genericPoint4",
                pointName: "Tourist Point",
                pointLat: 50.0753,
                pointLng: 14.4147,
                pointType: .tourist
            ),
            .mock(
                id: "genericPoint5",
                pointName: "Energy Sponsor Point",
                pointLat: 50.0856,
                pointLng: 14.4381,
                pointType: .energySponsor
            ),
            .mock(
                id: "genericPoint6",
                pointName: "Virtual Point",
                pointLat: 50.0777,
                pointLng: 14.4039,
                pointType: .virtual
            ),
            .mock(
                id: "genericPoint7",
                pointName: "Gastro Point",
                pointLat: 50.0809,
                pointLng: 14.4466,
                pointType: .gastro
            )
        ]
    ) -> GenericPointData {
        return GenericPointData(
            checkSum: checkSum,
            data: data
        )
    }
}

extension UserRankData {
    static func mock(
        checkSum: String = "mockCheckSum",
        data: [UserRank] = [
            .mock(catUserRank: 1, listUserRank: [
                .mock(userId: "user1", nick: "User 1", order: "1", points: "1500"),
                .mock(userId: "user2", nick: "User 2", order: "2", points: "1000"),
                .mock(userId: "user3", nick: "User 3", order: "3", points: "500")
            ]),
            .mock(catUserRank: 2, listUserRank: [
                .mock(userId: "user4", nick: "User 4", order: "1", points: "800"),
                .mock(userId: "user1", nick: "User 1", order: "2", points: "700")
            ])
        ]
    ) -> UserRankData {
        return UserRankData(
            checkSum: checkSum,
            data: data
        )
    }
}

extension SignatureAPIResponse {
    static func mock(
        signature: String = "mockSignature"
    ) -> SignatureAPIResponse {
        return SignatureAPIResponse(signature: signature)
    }
}

extension CompleteRegistrationAPIResponse {
    static func mock(
        completionStatus: Bool = true,
        needParentActivation: Bool = false
    ) -> CompleteRegistrationAPIResponse {
        return CompleteRegistrationAPIResponse(
            completionStatus: completionStatus,
            needParentActivation: needParentActivation
        )
    }
}

extension ParentEmailActivationReponse {
    static func mock(
        status: Bool = true
    ) -> ParentEmailActivationReponse {
        return ParentEmailActivationReponse(status: status)
    }
}

extension CheckSumUserPointsData {
    static func mock(
        pointsProtect: String = "mockPointsProtect"
    ) -> CheckSumUserPointsData {
        return CheckSumUserPointsData(
            pointsProtect: pointsProtect
        )
    }
}

extension CheckSumRankData {
    static func mock(
        rankProtect: String = "mockRankProtect"
    ) -> CheckSumRankData {
        return CheckSumRankData(
            rankProtect: rankProtect
        )
    }
}

extension CheckSumMessagesData {
    static func mock(
        msgProtect: String = "mockMessageProtect"
    ) -> CheckSumMessagesData {
        return CheckSumMessagesData(
            msgProtect: msgProtect
        )
    }
}

extension CheckSumEventsData {
    static func mock(
        eventsProtect: String = "mockEventsProtect"
    ) -> CheckSumEventsData {
        return CheckSumEventsData(
            eventsProtect: eventsProtect
        )
    }
}

extension CheckSumPointsData {
    static func mock(
        pointsProtect: String = "mockPointsProtect",
        clusterProtect: String? = "mockClusterProtect"
    ) -> CheckSumPointsData {
        return CheckSumPointsData(
            pointsProtect: pointsProtect,
            clusterProtect: clusterProtect
        )
    }
}
