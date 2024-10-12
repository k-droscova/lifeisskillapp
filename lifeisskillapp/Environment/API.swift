//
//  API.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 07.07.2024.
//

import Foundation

struct APIUrl {
    static let base: String = Bundle.main.infoDictionary?["API_BASE_URL"] as! String
    static var baseURL: URL { URL(string: base)! }
    static var detailUrl: String = Bundle.main.infoDictionary?["API_DETAIL_URL"] as! String
    static var qrUrl: String = Bundle.main.infoDictionary?["API_QR_URL"] as! String
    static let gdprUrl: String = "https://www.lifeisskill.cz/articledetail/LIS_A-44011"
    static let rulesUrl: String = "https://www.lifeisskill.cz/articledetail/LIS_A-06811"
}

struct API {
    static let baseDate: Date = Date(timeIntervalSince1970: .init())
}

struct APIHeader {
    private static var apiKey: String {
        Bundle.main.infoDictionary?["API_KEY"] as? String ?? ""
    }
    
    private static var authorizationToken: String {
        Bundle.main.infoDictionary?["AUTH_TOKEN"] as? String ?? ""
    }
    
    static var authorizationHeader: [String: String] { ["Authorization": "Bearer \(authorizationToken)"] }
    static var apiKeyHeader: [String: String] { ["Api-Key": apiKey] }
    static func apiTokenHeader(token: String) -> [String: String] { ["User-Token": token] }
}
