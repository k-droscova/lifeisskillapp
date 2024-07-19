//
//  Date.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 15.07.2024.
//

import Foundation

extension Date {
    /// Returns date string with day and month `%d. %d.`
    func getDayString() -> String {
        let components = Calendar.current.dateComponents([.day, .month], from: self)
        let day = String(components.day ?? 1) + ". " + String(components.month ?? 1) + "."
        
        return day
    }
    
    /// Returns date string with year `%d`
    func getYearString() -> String {
        Formatters.year.string(from: self)
    }
    
    /// Returns time string with hour and minutes `%d:%d`
    func getTimeString() -> String {
        Formatters.time.string(from: self)
    }
    
    /// Returns time string with hour, minutes and seconds `%d:%d:%d`
    func getLongTimeString() -> String {
        Formatters.timeLong.string(from: self)
    }
    
    /// Returns date string `dd. MM. yyyy`
    func getDateString() -> String {
        Formatters.date.string(from: self)
    }
    
    /// Checks user top age limit
    func isUserYoungerThanEighteen() -> Bool {
        let currentDate = Date()
        let calendar = Calendar.current
        
        let ageComponents = calendar.dateComponents([.year], from: self, to: currentDate)
        
        return ageComponents.year! < 18
    }
    
    /// Checks user bottom age limit
    func isUserOlderThanSix() -> Bool {
        let currentDate = Date()
        let calendar = Calendar.current
        
        let ageComponents = calendar.dateComponents([.year], from: self, to: currentDate)
        
        return ageComponents.year! >= 6
    }
    
    /// Transform date string with `yyyy-MM-dd HH:mm:ss` format
    func fromPointList(dateString: String) -> Date {
        Formatters.pointListDate.date(from: dateString) ?? Date()
    }
    
    func toPointListString() -> String {
        Formatters.pointListDate.string(from: self)
    }
    
    /// Transform date string with `dd.MM.yyyy HH:mm` format
    func fromEventsList(dateString: String) -> Date {
        Formatters.eventsListDate.date(from: dateString) ?? Date()
    }
    
    /// `dd. MM. yyyy`
    func getEventsDate() -> String {
        Formatters.date.string(from: self)
    }
}

extension TimeInterval {
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
    static let year: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY"
        dateFormatter.locale = Locale(identifier: "cs")
        
        return dateFormatter
    }()
    
    static let time: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        
        return dateFormatter
    }()
    
    static let timeLong: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss"
        
        return dateFormatter
    }()
    
    static let date: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        
        return dateFormatter
    }()
    
    static let pointListDate: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        return dateFormatter
    }()
    
    static let eventsListDate: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy HH:mm"
        
        return dateFormatter
    }()
}
