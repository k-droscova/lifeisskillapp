//
//  APIResponseError.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 04.07.2024.
//

import Foundation

/*public protocol APIResponseError: Codable {
    var apiCode: APIError? { get }
}

public struct EmptyResponseError: APIResponseError {
    public var apiCode: APIError? { nil }
}*/


public protocol APIResponseError: Codable, Error {
    var message: String? { get }
    var code: ErrorCodes? { get }
}

public struct InvalidAPIAuthorizationResponse: APIResponseError {
    public var message: String? { "" }
    public var code: ErrorCodes? { nil }
}

public struct EmptyResponseError: APIResponseError {
    public var message: String? { nil }
    public var code: ErrorCodes? { nil }
}

public struct InvalidCodeError: APIResponseError {
    public var message: String? { "" }
    public var code: ErrorCodes? { .api(.invalidPointCode) }
}

public struct LoggedInOnOtherDevice: APIResponseError {
    public var message: String? { "" }
    public var code: ErrorCodes? { .api(.loggedInOnOtherDevice) }
}

public struct InvalidRegistrationError: APIResponseError {
    public var message: String? { "" }
    public var code: ErrorCodes? { .api(.invalidRegistration) }
}
