import Testing
import Foundation
import SwiftData
@testable import HabitTrackerCore

// Serialized: concurrent in-memory ModelContainer creation across parallel
// tests has been observed to crash (SwiftData isn't safe for that).
@Suite("HomeViewModel", .serialized)
struct HomeViewModelTests {

    func makeViewModel(today: DayKey = DayKey(rawValue: "2026-03-05")) throws -> (HomeViewModel, ModelContext) {
        let container = try ModelContainer(
            for: Habit.self, Completion.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let context = ModelContext(container)
        return (HomeViewModel(context: context, today: { today }), context)
    }

    @Test("addHabit adds a trimmed, non-empty name to activeHabits")
    func addHabitTrimsAndAdds() throws {
        let (viewModel, _) = try makeViewModel()

        viewModel.addHabit(name: "  Meditate  ")

        #expect(viewModel.activeHabits.map(\.name) == ["Meditate"])
    }

    @Test("addHabit is a no-op for empty or whitespace-only input")
    func addHabitNoOpsOnEmptyInput() throws {
        let (viewModel, _) = try makeViewModel()

        viewModel.addHabit(name: "")
        viewModel.addHabit(name: "   ")

        #expect(viewModel.activeHabits.isEmpty)
    }

    @Test("streak reflects the underlying store's streak")
    func streakReflectsStore() throws {
        let today = DayKey(rawValue: "2026-03-05")
        let (viewModel, context) = try makeViewModel(today: today)
        #expect(viewModel.streak == 0)

        viewModel.addHabit(name: "Meditate")
        let habit = try #require(viewModel.activeHabits.first)
        let store = HabitStore(context: context, today: { today })
        try store.toggleDone(habitId: habit.id)

        #expect(viewModel.streak == 1)
    }
}