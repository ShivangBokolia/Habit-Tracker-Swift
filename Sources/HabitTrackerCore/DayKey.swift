import Foundation

/// A "yyyy-MM-dd" local calendar day, matching CONTEXT.md's Day definition
/// (local midnight-to-midnight, no custom rollover cutoff).
public struct DayKey: RawRepresentable, Hashable, Comparable, Codable, Sendable {
    public let rawValue: String

    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    public init(date: Date, calendar: Calendar = .current) {
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        self.rawValue = String(format: "%04d-%02d-%02d", components.year!, components.month!, components.day!)
    }

    public static func today(calendar: Calendar = .current) -> DayKey {
        DayKey(date: Date(), calendar: calendar)
    }

    public func adding(days: Int, calendar: Calendar = .current) -> DayKey {
        let parts = rawValue.split(separator: "-").compactMap { Int($0) }
        var components = DateComponents()
        components.year = parts[0]
        components.month = parts[1]
        components.day = parts[2]
        let date = calendar.date(from: components)!
        let shifted = calendar.date(byAdding: .day, value: days, to: date)!
        return DayKey(date: shifted, calendar: calendar)
    }

    public static func < (lhs: DayKey, rhs: DayKey) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}