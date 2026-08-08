import Foundation
import Observation
import SwiftData

@Observable
public final class HomeViewModel {
    private let store: HabitStore

    public init(context: ModelContext, today: @escaping () -> DayKey = { DayKey.today() }) {
        self.store = HabitStore(context: context, today: today)
    }

    public var activeHabits: [Habit] {
        store.activeHabits
    }

    public var streak: Int {
        store.streak
    }

    public func addHabit(name: String) {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        _ = try? store.addHabit(name: trimmed)
    }
}