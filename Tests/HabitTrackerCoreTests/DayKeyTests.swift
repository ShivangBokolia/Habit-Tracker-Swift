import Testing
import Foundation
@testable import HabitTrackerCore

@Suite("DayKey")
struct DayKeyTests {

    @Test("formats a date as yyyy-MM-dd using local calendar components")
    func formatsDate() {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "America/Los_Angeles")!
        var components = DateComponents()
        components.year = 2026
        components.month = 3
        components.day = 5
        components.hour = 23
        components.minute = 30
        let date = calendar.date(from: components)!

        let key = DayKey(date: date, calendar: calendar)

        #expect(key.rawValue == "2026-03-05")
    }

    @Test("zero-pads single digit month and day")
    func zeroPads() {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        var components = DateComponents()
        components.year = 2026
        components.month = 1
        components.day = 9
        let date = calendar.date(from: components)!

        let key = DayKey(date: date, calendar: calendar)

        #expect(key.rawValue == "2026-01-09")
    }

    @Test("compares chronologically")
    func compares() {
        let earlier = DayKey(rawValue: "2026-01-09")
        let later = DayKey(rawValue: "2026-01-10")

        #expect(earlier < later)
        #expect(!(later < earlier))
    }

    @Test("adding a negative day count moves to the previous day, including across month boundaries")
    func addingDaysCrossesMonthBoundary() {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        let key = DayKey(rawValue: "2026-03-01")

        let previous = key.adding(days: -1, calendar: calendar)

        #expect(previous.rawValue == "2026-02-28")
    }
}