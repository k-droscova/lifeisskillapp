//
//  UserGameDataMocks.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 28.09.2024.
//

@testable import lifeisskillapp
import Foundation

// MARK: - Models

extension UserCategory {
    static func mock(
        id: String = "mockCategoryID",
        name: String = "mockCategoryName",
        detail: String = "mockCategoryDetail",
        isPublic: Bool = true
    ) -> UserCategory {
        return UserCategory(
            id: id,
            name: name,
            detail: detail,
            isPublic: isPublic
        )
    }
}

extension RankedUser {
    static func mock(
        userId: String = "mockUserID",
        email: String = "mockEmail@example.com",
        nick: String = "mockNick",
        sex: UserGender = .male,
        order: String = "1",
        points: String = "100",
        lastTime: String = "2024-09-30T12:00:00Z",
        psc: String = "mockPSC",
        emailr: String = "mockSecondaryEmail@example.com",
        mobil: String = "1234567890",
        mobilr: String = "0987654321"
    ) -> RankedUser {
        return RankedUser(
            userId: userId,
            email: email,
            nick: nick,
            sex: sex,
            order: order,
            points: points,
            lastTime: lastTime,
            psc: psc,
            emailr: emailr,
            mobil: mobil,
            mobilr: mobilr
        )
    }
}

extension UserRank {
    static func mock(
        catId: String = "mockCategoryID",
        catUserRank: Int = 1,
        listUserRank: [RankedUser] = [.mock(), .mock()]
    ) -> UserRank {
        return UserRank(
            catId: catId,
            catUserRank: catUserRank,
            listUserRank: listUserRank
        )
    }
}

extension GenericPoint {
    static func mock(
        id: String = "mockPointID",
        pointName: String = "mockPointName",
        pointLat: Double = 50.0755,
        pointLng: Double = 14.4378,
        pointAlt: Double = 300.0,
        pointValue: Int = 100,
        pointType: PointType = .tourist,
        cluster: String = "mockCluster",
        pointSpec: Int = 0,
        sponsorId: String = "mockSponsorID",
        hasDetail: Bool = false,
        active: Bool = true,
        param: PointParam? = nil
    ) -> GenericPoint {
        return GenericPoint(
            pointLat: pointLat,
            pointLng: pointLng,
            pointAlt: pointAlt,
            pointName: pointName,
            pointValue: pointValue,
            pointType: pointType,
            id: id,
            cluster: cluster,
            pointSpec: pointSpec,
            sponsorId: sponsorId,
            hasDetail: hasDetail,
            active: active,
            param: param
        )
    }
}

extension UserPoint {
    static func mock(
        id: String = "mockPointID",
        recordKey: String = "mockRecordKey",
        pointTime: Date = Date(),
        pointName: String = "mockPointName",
        pointValue: Int = 50,
        pointType: PointType = .tourist,
        pointSpec: Int = 1,
        pointLat: Double = 50.0755,
        pointLng: Double = 14.4378,
        pointAlt: Double = 300.0,
        accuracy: Double = 5.0,
        codeSource: CodeSource = .qr,
        pointCategory: [String] = ["mockCategory"],
        duration: TimeInterval? = nil,
        doesPointCount: Bool = true
    ) -> UserPoint {
        return UserPoint(
            id: id,
            recordKey: recordKey,
            pointTime: pointTime,
            pointName: pointName,
            pointValue: pointValue,
            pointType: pointType,
            pointSpec: pointSpec,
            pointLat: pointLat,
            pointLng: pointLng,
            pointAlt: pointAlt,
            accuracy: accuracy,
            codeSource: codeSource,
            pointCategory: pointCategory,
            duration: duration,
            doesPointCount: doesPointCount
        )
    }
}
