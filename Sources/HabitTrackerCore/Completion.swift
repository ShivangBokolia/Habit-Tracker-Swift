import Foundation
import SwiftData

/// One row per habit per day that has been explicitly toggled.
/// Absence of a row means not-done, mirroring the RN store's Map default.
@Model
public final class Completion {
    public var habitId: UUID
    public var day: String
    public var done: Bool

    public init(habitId: UUID, day: String, done: Bool) {
        self.habitId = habitId
        self.day = day
        self.done = done
    }
}