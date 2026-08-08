import Foundation
import SwiftData

public final class HabitStore {
    private let context: ModelContext
    private let today: () -> DayKey

    public init(context: ModelContext, today: @escaping () -> DayKey = { DayKey.today() }) {
        self.context = context
        self.today = today
    }

    @discardableResult
    public func addHabit(name: String) throws -> Habit {
        let habit = Habit(name: name, createdDay: today().rawValue)
        context.insert(habit)
        try context.save()
        return habit
    }

    public var activeHabits: [Habit] {
        fetchAll(Habit.self).filter { $0.status == .active }
    }

    public func toggleDone(habitId: UUID) throws {
        let day = today()
        if let completion = try fetchCompletion(habitId: habitId, day: day) {
            completion.done.toggle()
        } else {
            context.insert(Completion(habitId: habitId, day: day.rawValue, done: true))
        }
        try context.save()
    }

    public func archiveHabit(id: UUID) throws {
        guard let habit = try fetchHabit(id: id) else { return }
        habit.status = .archived
        habit.archivedDay = today().rawValue
        try context.save()
    }

    private func fetchHabit(id targetId: UUID) throws -> Habit? {
        let descriptor = FetchDescriptor<Habit>(predicate: #Predicate { $0.id == targetId })
        return try context.fetch(descriptor).first
    }

    public func isDoneToday(habitId: UUID) -> Bool {
        let completion = try? fetchCompletion(habitId: habitId, day: today())
        return completion?.done ?? false
    }

    public var streak: Int {
        let allHabits = fetchAll(Habit.self)
        guard let earliestCreatedDay = allHabits.map(\.createdDay).min() else { return 0 }
        let allCompletions = fetchAll(Completion.self)
        let doneByHabitAndDay = Set(allCompletions.filter(\.done).map { HabitDay(habitId: $0.habitId, day: $0.day) })

        var count = 0
        var day = today()
        while day.rawValue >= earliestCreatedDay {
            let activeOnDay = allHabits.filter { habitsActiveOnDay(habit: $0, day: day) }
            if activeOnDay.isEmpty {
                day = day.adding(days: -1)
                continue
            }
            let isPerfectDay = activeOnDay.allSatisfy {
                doneByHabitAndDay.contains(HabitDay(habitId: $0.id, day: day.rawValue))
            }
            guard isPerfectDay else { break }
            count += 1
            day = day.adding(days: -1)
        }
        return count
    }

    private func habitsActiveOnDay(habit: Habit, day: DayKey) -> Bool {
        guard habit.createdDay <= day.rawValue else { return false }
        guard let archivedDay = habit.archivedDay else { return true }
        return day.rawValue < archivedDay
    }

    private struct HabitDay: Hashable {
        let habitId: UUID
        let day: String
    }

    private func fetchCompletion(habitId targetHabitId: UUID, day: DayKey) throws -> Completion? {
        let targetDay = day.rawValue
        let descriptor = FetchDescriptor<Completion>(
            predicate: #Predicate { $0.habitId == targetHabitId && $0.day == targetDay }
        )
        return try context.fetch(descriptor).first
    }

    private func fetchAll<T: PersistentModel>(_ type: T.Type) -> [T] {
        (try? context.fetch(FetchDescriptor<T>())) ?? []
    }
}