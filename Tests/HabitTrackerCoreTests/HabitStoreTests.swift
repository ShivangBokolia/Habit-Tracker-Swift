import Testing
import Foundation
import SwiftData
@testable import HabitTrackerCore

// Serialized: concurrent in-memory ModelContainer creation across parallel
// tests has been observed to crash (SwiftData isn't safe for that).
@Suite("HabitStore", .serialized)
struct HabitStoreTests {

    func makeStore(today: DayKey = DayKey(rawValue: "2026-03-05")) throws -> HabitStore {
        let container = try ModelContainer(
            for: Habit.self, Completion.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let context = ModelContext(container)
        return HabitStore(context: context, today: { today })
    }

    @Test("addHabit creates an active habit dated today, visible in activeHabits")
    func addHabitCreatesActiveHabit() throws {
        let store = try makeStore(today: DayKey(rawValue: "2026-03-05"))

        try store.addHabit(name: "Meditate")

        #expect(store.activeHabits.count == 1)
        let habit = try #require(store.activeHabits.first)
        #expect(habit.name == "Meditate")
        #expect(habit.status == .active)
        #expect(habit.createdDay == "2026-03-05")
    }

    @Test("toggleDone marks today's completion done, then not-done again")
    func toggleDoneFlipsCompletion() throws {
        let store = try makeStore(today: DayKey(rawValue: "2026-03-05"))
        let habit = try store.addHabit(name: "Meditate")

        try store.toggleDone(habitId: habit.id)
        #expect(store.isDoneToday(habitId: habit.id) == true)

        try store.toggleDone(habitId: habit.id)
        #expect(store.isDoneToday(habitId: habit.id) == false)
    }

    @Test("a habit with no completion row is not-done")
    func absentCompletionIsNotDone() throws {
        let store = try makeStore(today: DayKey(rawValue: "2026-03-05"))
        let habit = try store.addHabit(name: "Meditate")

        #expect(store.isDoneToday(habitId: habit.id) == false)
    }

    @Test("archiveHabit removes the habit from activeHabits but preserves its history")
    func archiveHabitExcludesFromActiveHabitsButKeepsHistory() throws {
        let store = try makeStore(today: DayKey(rawValue: "2026-03-05"))
        let habit = try store.addHabit(name: "Meditate")
        try store.toggleDone(habitId: habit.id)

        try store.archiveHabit(id: habit.id)

        #expect(store.activeHabits.isEmpty)
        #expect(habit.status == .archived)
        #expect(habit.archivedDay == "2026-03-05")
        #expect(store.isDoneToday(habitId: habit.id) == true)
    }

    @Test("streak is zero with no habits")
    func streakIsZeroWithNoHabits() throws {
        let store = try makeStore(today: DayKey(rawValue: "2026-03-05"))

        #expect(store.streak == 0)
    }

    @Test("streak counts consecutive perfect days back from today")
    func streakCountsConsecutivePerfectDays() throws {
        var day = DayKey(rawValue: "2026-03-01")
        let container = try ModelContainer(
            for: Habit.self, Completion.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let context = ModelContext(container)
        let store = HabitStore(context: context, today: { day })
        let habit = try store.addHabit(name: "Meditate")

        // Perfect on 03-01, 03-02, 03-03; not done on 03-04 (today).
        try store.toggleDone(habitId: habit.id) // done on 03-01
        day = DayKey(rawValue: "2026-03-02")
        try store.toggleDone(habitId: habit.id)
        day = DayKey(rawValue: "2026-03-03")
        try store.toggleDone(habitId: habit.id)
        day = DayKey(rawValue: "2026-03-04")
        // left not-done today

        #expect(store.streak == 0)

        day = DayKey(rawValue: "2026-03-03")
        #expect(store.streak == 3)
    }

    @Test("a day with zero active habits is skipped, neither breaking nor extending the streak")
    func zeroActiveHabitDayIsSkipped() throws {
        var day = DayKey(rawValue: "2026-03-01")
        let container = try ModelContainer(
            for: Habit.self, Completion.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let context = ModelContext(container)
        let store = HabitStore(context: context, today: { day })

        // Habit A: active + done on 03-01, archived on 03-02 (no habits active that day).
        let habitA = try store.addHabit(name: "A")
        try store.toggleDone(habitId: habitA.id)
        day = DayKey(rawValue: "2026-03-02")
        try store.archiveHabit(id: habitA.id)

        // Habit B: created and done on 03-03 (today).
        day = DayKey(rawValue: "2026-03-03")
        let habitB = try store.addHabit(name: "B")
        try store.toggleDone(habitId: habitB.id)

        #expect(store.streak == 2)
    }

    @Test("archiving an incomplete habit rescues that day's streak (ADR 0001)")
    func archivingIncompleteHabitRescuesStreak() throws {
        var day = DayKey(rawValue: "2026-03-01")
        let container = try ModelContainer(
            for: Habit.self, Completion.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let context = ModelContext(container)
        let store = HabitStore(context: context, today: { day })

        let habitA = try store.addHabit(name: "A")
        try store.toggleDone(habitId: habitA.id)

        day = DayKey(rawValue: "2026-03-02")
        try store.toggleDone(habitId: habitA.id)
        let habitB = try store.addHabit(name: "B")
        // habitB never marked done on 03-02, then archived same day before day's end.
        try store.archiveHabit(id: habitB.id)

        #expect(store.streak == 2)
    }
}