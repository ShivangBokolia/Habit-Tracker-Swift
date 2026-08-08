import SwiftUI
import SwiftData
import HabitTrackerCore

@main
struct HabitTrackerApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [Habit.self, Completion.self])
    }
}