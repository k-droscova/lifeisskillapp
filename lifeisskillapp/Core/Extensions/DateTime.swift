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
        return Formatters.year.string(from: self)
    }

    /// Returns time string with hour and minutes `%d:%d`
    func getTimeString() -> String {
        return Formatters.time.string(from: self)
    }

    /// Returns time string with hour, minutes and seconds `%d:%d:%d`
    func getLongTimeString() -> String {
        return Formatters.timeLong.string(from: self)
    }

    /// Returns date string `dd. MM. yyyy`
    func getDateString() -> String {
        return Formatters.date.string(from: self)
    }

    /// Checks user top age limit
    func isUserYoungerThanEighteen() -> Bool {
        let currentDate = Date()
        let calendar = Calendar.current

        let ageComponents = calendar.dateComponents([.year], from: self, to: currentDate)

        // swiftlint:disable force_unwrapping
        return ageComponents.year! < 18
    }

    /// Checks user bottom age limit
    func isUserOlderThanSix() -> Bool {
        let currentDate = Date()
        let calendar = Calendar.current

        let ageComponents = calendar.dateComponents([.year], from: self, to: currentDate)

        // swiftlint:disable force_unwrapping
        return ageComponents.year! >= 6
    }

    /// Transform date string with `yyyy-MM-dd HH:mm:ss` format
    func fromPointList(dateString: String) -> Date {
        return Formatters.pointListDate.date(from: dateString) ?? Date()
    }

    /// Transform date string with `dd.MM.yyyy HH:mm` format
    func fromEventsList(dateString: String) -> Date {
        return Formatters.eventsListDate.date(from: dateString) ?? Date()
    }

    /// `dd. MM. yyyy`
    func getEventsDate() -> String {
        return Formatters.date.string(from: self)
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
