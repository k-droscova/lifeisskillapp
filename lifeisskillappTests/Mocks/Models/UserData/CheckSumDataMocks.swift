//
//  CheckSumDataMocks.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 28.09.2024.
//

import lifeisskillapp

public extension CheckSumUserPointsData {
    static func mock(
        pointsProtect: String = "mockPointsProtect"
    ) -> CheckSumUserPointsData {
        return CheckSumUserPointsData(
            pointsProtect: pointsProtect
        )
    }
}

public extension CheckSumRankData {
    static func mock(
        rankProtect: String = "mockRankProtect"
    ) -> CheckSumRankData {
        return CheckSumRankData(
            rankProtect: rankProtect
        )
    }
}

public extension CheckSumMessagesData {
    static func mock(
        msgProtect: String = "mockMessageProtect"
    ) -> CheckSumMessagesData {
        return CheckSumMessagesData(
            msgProtect: msgProtect
        )
    }
}

public extension CheckSumEventsData {
    static func mock(
        eventsProtect: String = "mockEventsProtect"
    ) -> CheckSumEventsData {
        return CheckSumEventsData(
            eventsProtect: eventsProtect
        )
    }
}

public extension CheckSumPointsData {
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
