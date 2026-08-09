import SwiftUI
import HabitTrackerCore

struct HomeScreen: View {
    var viewModel: HomeViewModel
    @State private var newHabitName = ""
    @State private var habitPendingRemoval: Habit?

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
                        let done = viewModel.isDoneToday(habitId: habit.id)
                        Text(habit.name)
                            .strikethrough(done)
                            .foregroundStyle(done ? .secondary : .primary)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                viewModel.toggleDone(habitId: habit.id)
                            }
                            .swipeActions {
                                Button("Remove", role: .destructive) {
                                    habitPendingRemoval = habit
                                }
                            }
                    }
                }
            }
            .navigationTitle("Habit Tracker")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Text("🔥 \(viewModel.streak)")
                }
            }
            .alert(
                "Remove '\(habitPendingRemoval?.name ?? "")'?",
                isPresented: Binding(
                    get: { habitPendingRemoval != nil },
                    set: { isPresented in if !isPresented { habitPendingRemoval = nil } }
                ),
                presenting: habitPendingRemoval
            ) { habit in
                Button("Remove", role: .destructive) {
                    viewModel.archiveHabit(habitId: habit.id)
                    habitPendingRemoval = nil
                }
                Button("Cancel", role: .cancel) {
                    habitPendingRemoval = nil
                }
            } message: { _ in
                Text("Its history will be kept.")
            }
        }
    }
}