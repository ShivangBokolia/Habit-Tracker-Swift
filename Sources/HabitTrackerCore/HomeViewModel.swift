import Foundation
import Observation
import SwiftData

@Observable
public final class HomeViewModel {
    private let store: HabitStore

    // HabitStore reads through SwiftData fetches that live outside this
    // object's own storage, so Observation can't see them. Every computed
    // property below reads this to register a dependency, and every method
    // that mutates the store bumps it to invalidate observing views.
    private var refreshToken = 0

    public init(context: ModelContext, today: @escaping () -> DayKey = { DayKey.today() }) {
        self.store = HabitStore(context: context, today: today)
    }

    public var activeHabits: [Habit] {
        _ = refreshToken
        return store.activeHabits
    }

    public var streak: Int {
        _ = refreshToken
        return store.streak
    }

    public func addHabit(name: String) {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        _ = try? store.addHabit(name: trimmed)
        refreshToken += 1
    }

    public func isDoneToday(habitId: UUID) -> Bool {
        _ = refreshToken
        return store.isDoneToday(habitId: habitId)
    }

    public func toggleDone(habitId: UUID) {
        try? store.toggleDone(habitId: habitId)
        refreshToken += 1
    }
}