//
//  Date.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 15.07.2024.
//

import Foundation

extension Date {

    enum Backend {
        
        /// Transform date string with `yyyy-MM-dd` format to Date
        static func fromBirthday(dateString: String) -> Date? {
            Formatters.Backend.birthdayFormatter.date(from: dateString)
        }
        
        /// Transform Date to `yyyy-MM-dd` format
        static func getBirthdayString(from date: Date) -> String {
            Formatters.Backend.birthdayFormatter.string(from: date)
        }
        
        /// Transform date string with `yyyy-MM-dd HH:mm:ss` format
        static func fromUserPointString(dateString: String) -> Date {
            Formatters.Backend.userPointDate.date(from: dateString) ?? Date()
        }
        
        /// Transform Date to `yyyy-MM-dd HH:mm:ss` format
        static func getUserPointString(from date: Date) -> String {
            Formatters.Backend.userPointDate.string(from: date)
        }
        
    }

    enum UI {
        
        /// Returns date string `dd. MM. yyyy`
        static func getDateString(from date: Date) -> String {
            Formatters.UI.date.string(from: date)
        }
        
        /// Returns date string with day and month `d. M.`
        static func getDayString(from date: Date) -> String {
            Formatters.UI.day.string(from: date)
        }
        
        /// Returns date string with year `YYYY`
        static func getYearString(from date: Date) -> String {
            Formatters.UI.year.string(from: date)
        }
        
        /// Returns time string with hour and minutes `HH:mm`
        static func getTimeString(from date: Date) -> String {
            Formatters.UI.time.string(from: date)
        }
        
        /// Returns true if user with this date of birth is considered minor
        static func isMinor(birthDate: Date) -> Bool {
            let calendar = Calendar.current
            let now = Date()
            let ageComponents = calendar.dateComponents([.year], from: birthDate, to: now)
            return (ageComponents.year ?? 0) < User.ageWhenConsideredNotMinor
        }
    }
}

extension TimeInterval {

    enum Backend {
        
        /// Parse duration string with `HH:mm:ss` format to TimeInterval
        static func parseDuration(_ durationString: String) -> TimeInterval? {
            let components = durationString.split(separator: ":").compactMap { Double($0) }
            guard components.count == 3 else { return nil }
            let hours = components[0] * 3600
            let minutes = components[1] * 60
            let seconds = components[2]
            return hours + minutes + seconds
        }
        
        /// Returns duration string with `HH:mm:ss` format
        static func getDurationString(from interval: TimeInterval) -> String {
            let formatter = Formatters.Backend.timeLong
            let date = Date(timeIntervalSince1970: interval)
            return formatter.string(from: date)
        }
    }
}

enum Formatters {

    // MARK: - Backend Formatters
    enum Backend {
        /// Locale for Backend
        static let localeIdentifier = "en_US_POSIX"

        /// Formatter for `HH:mm:ss` format
        static let timeLong: DateFormatter = {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "HH:mm:ss"
            dateFormatter.locale = Locale(identifier: localeIdentifier)
            return dateFormatter
        }()
        
        /// Formatter for `yyyy-MM-dd HH:mm:ss` format
        static let userPointDate: DateFormatter = {
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: localeIdentifier)
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            return dateFormatter
        }()
        
        /// Formatter for `yyyy-MM-dd` format
        static let birthdayFormatter: DateFormatter = {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            dateFormatter.locale = Locale(identifier: localeIdentifier)
            return dateFormatter
        }()
    }

    // MARK: - UI Formatters
    enum UI {
        /// Locale for UI
        static let localeIdentifier = "cs"

        /// Formatter for `d. M. yyyy` format
        static let date: DateFormatter = {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "d. M. yyyy"
            dateFormatter.locale = Locale(identifier: localeIdentifier)
            return dateFormatter
        }()
        
        /// Formatter for `d. M.` format
        static let day: DateFormatter = {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "d. M."
            dateFormatter.locale = Locale(identifier: localeIdentifier)
            return dateFormatter
        }()
        
        /// Formatter for `YYYY` format
        static let year: DateFormatter = {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "YYYY"
            dateFormatter.locale = Locale(identifier: localeIdentifier)
            return dateFormatter
        }()
        
        /// Formatter for `HH:mm` format
        static let time: DateFormatter = {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "HH:mm"
            dateFormatter.locale = Locale(identifier: localeIdentifier)
            return dateFormatter
        }()
    }
}
