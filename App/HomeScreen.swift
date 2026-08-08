import SwiftUI
import HabitTrackerCore

struct HomeScreen: View {
    var viewModel: HomeViewModel
    @State private var newHabitName = ""

    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack {
                        TextField("New habit", text: $newHabitName)
                            .textFieldStyle(.roundedBorder)
                        Button("Add") {
                            let trimmed = newHabitName.trimmingCharacters(in: .whitespacesAndNewlines)
                            guard !trimmed.isEmpty else { return }
                            viewModel.addHabit(name: trimmed)
                            newHabitName = ""
                        }
                    }
                }
                Section {
                    ForEach(viewModel.activeHabits, id: \.id) { habit in
                        Text(habit.name)
                    }
                }
            }
            .navigationTitle("Habit Tracker")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Text("🔥 \(viewModel.streak)")
                }
            }
        }
    }
}