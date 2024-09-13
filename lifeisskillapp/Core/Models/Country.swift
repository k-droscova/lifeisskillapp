//
//  CountryCode.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 13.09.2024.
//

import Foundation

struct Country: Codable, Identifiable, Hashable, CustomStringConvertible {
    let label: String
    let phone: String
    let code: String
    let phoneLength: PhoneLength? // Can be a single value or an array of values

    // Generated flag emoji from country code
    var flagEmoji: String {
        let base: UInt32 = 127397
        var flag = ""
        for scalar in code.uppercased().unicodeScalars {
            flag.unicodeScalars.append(UnicodeScalar(base + scalar.value)!)
        }
        return flag
    }

    var id: String { code } // for Identifiable
    var description: String { "\(flagEmoji) \(label) (+\(phone))" }
}

enum PhoneLength: Codable, Hashable {
    case single(Int)           // When phoneLength is a single value
    case range([Int])          // When phoneLength is an array

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let singleValue = try? container.decode(Int.self) {
            self = .single(singleValue)
        } else if let arrayValue = try? container.decode([Int].self) {
            self = .range(arrayValue)
        } else {
            throw BaseError(
                context: .database,
                message: "Could not decode phone length",
                code: .general(.jsonDecoding),
                logger: appDependencies.logger
            )
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .single(let value):
            try container.encode(value)
        case .range(let values):
            try container.encode(values)
        }
    }
}

extension Country {
    static let czechia = Country(label: "Czechia", phone: "420", code: "CZ", phoneLength: .single(9))

    static var countries: [Country] {
        guard let url = Bundle.main.url(forResource: "CountryCodes", withExtension: "json") else {
            return [czechia]
        }

        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let countries = try decoder.decode([Country].self, from: data)
            return countries
        } catch {
            return [czechia]
        }
    }

    static var defaultCountry: Country {
        countries.first(where: { $0.code == czechia.code }) ?? czechia
    }
}
