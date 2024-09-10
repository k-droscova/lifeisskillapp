//
//  Date.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 15.07.2024.
//

import Foundation

extension Date {
    
    // MARK: - Backend
    
    /// Transform date string with `yyyy-MM-dd` format to Date
    func fromBirthday(dateString: String) -> Date? {
        Formatters.birthdayFormatter.date(from: dateString)
    }
    
    /// Transform Date to`yyyy-MM-dd` format
    func getBirthdayString() -> String {
        Formatters.birthdayFormatter.string(from: self)
    }
    
    /// Transform date string with `yyyy-MM-dd HH:mm:ss` format
    func fromUserPointString(dateString: String) -> Date {
        Formatters.userPointDate.date(from: dateString) ?? Date()
    }
    
    /// Transform Date to `yyyy-MM-dd HH:mm:ss` format
    func getUserPointString() -> String {
        Formatters.userPointDate.string(from: self)
    }
    
    // MARK: - UI
    
    /// Returns date string `dd. MM. yyyy`
    func getDateString() -> String {
        Formatters.date.string(from: self)
    }
    
    /// Returns date string with day and month `%d. %d.`
    func getDayString() -> String {
        Formatters.day.string(from: self)
    }
    
    /// Returns date string with year `%d`
    func getYearString() -> String {
        Formatters.year.string(from: self)
    }
    
    /// Returns time string with hour and minutes `%d:%d`
    func getTimeString() -> String {
        Formatters.time.string(from: self)
    }
    
    /// Returns true if user with this date of birth is considered minor in the game
    func isMinor() -> Bool {
        let calendar = Calendar.current
        let now = Date()
        let ageComponents = calendar.dateComponents([.year], from: self, to: now)
        return (ageComponents.year ?? 0) < User.ageWhenConsideredNotMinor // if optional is nil then defaults to true
    }
}

extension TimeInterval {
    
    // MARK: - For Backend
    
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
    func getDurationString() -> String {
        let formatter = Formatters.timeLong
        let date = Date(timeIntervalSince1970: self)
        return formatter.string(from: date)
    }
}

enum Formatters {
    
    // MARK: - For backendend
    // uses en_US_POSIX as locale to maintain consistency for API communication
    
    static let timeLong: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        return dateFormatter
    }()
    
    static let userPointDate: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        return dateFormatter
    }()
    
    static let birthdayFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        return dateFormatter
    }()
    
    // MARK: - For UI
    // uses CS locale
    
    static let date: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d. M. yyyy"
        dateFormatter.locale = Locale(identifier: "cs")
        
        return dateFormatter
    }()
    
    static let day: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d. M."
        dateFormatter.locale = Locale(identifier: "cs")
        return dateFormatter
    }()
    
    static let year: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY"
        dateFormatter.locale = Locale(identifier: "cs")
        
        return dateFormatter
    }()
    
    static let time: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        dateFormatter.locale = Locale(identifier: "cs")
        
        return dateFormatter
    }()
}
