import SwiftUI
import HabitTrackerCore

struct HomeScreen: View {
    var viewModel: HomeViewModel
    @State private var newHabitName = ""
    @State private var habitPendingRemoval: Habit?

    private var trimmedNewHabitName: String {
        newHabitName.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                streakHeader
                List {
                    Section {
                        addHabitRow
                    }
                    Section {
                        if viewModel.activeHabits.isEmpty {
                            ContentUnavailableView(
                                "No Habits Yet",
                                systemImage: "checkmark.circle",
                                description: Text("Add a habit above to start your streak.")
                            )
                            .listRowSeparator(.hidden)
                        } else {
                            ForEach(viewModel.activeHabits, id: \.id) { habit in
                                habitRow(for: habit)
                            }
                        }
                    }
                }
                .listStyle(.plain)
            }
            .navigationTitle("Habit Tracker")
            .alert(
                "Remove '\(habitPendingRemoval?.name ?? "")'?",
                isPresented: Binding(
                    get: { habitPendingRemoval != nil },
                    set: { isPresented in if !isPresented { habitPendingRemoval = nil } }
                ),
                presenting: habitPendingRemoval
            ) { habit in
                Button("Remove", role: .destructive) {
                    withAnimation {
                        viewModel.archiveHabit(habitId: habit.id)
                    }
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

    private var streakHeader: some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Text("🔥")
                .font(.system(size: 32))
            Text("\(viewModel.streak)")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .contentTransition(.numericText())
                .animation(.default, value: viewModel.streak)
            Text("day streak")
                .font(.headline)
                .foregroundStyle(.secondary)
            Spacer()
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
    }

    private var addHabitRow: some View {
        HStack(spacing: 12) {
            TextField("New habit", text: $newHabitName)
                .textFieldStyle(.plain)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color(.secondarySystemBackground), in: .capsule)
            Button(action: addHabit) {
                Image(systemName: "plus.circle.fill")
                    .font(.title)
                    .foregroundStyle(trimmedNewHabitName.isEmpty ? Color.secondary : Color.mint)
            }
            .disabled(trimmedNewHabitName.isEmpty)
        }
        .listRowSeparator(.hidden)
    }

    private func addHabit() {
        let trimmed = trimmedNewHabitName
        guard !trimmed.isEmpty else { return }
        withAnimation {
            viewModel.addHabit(name: trimmed)
        }
        newHabitName = ""
    }

    private func habitRow(for habit: Habit) -> some View {
        let done = viewModel.isDoneToday(habitId: habit.id)
        return HStack(spacing: 12) {
            Image(systemName: done ? "checkmark.circle.fill" : "circle")
                .font(.title3)
                .foregroundStyle(done ? Color.mint : Color.secondary)
            Text(habit.name)
                .foregroundStyle(done ? .secondary : .primary)
        }
        .animation(.default, value: done)
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation {
                viewModel.toggleDone(habitId: habit.id)
            }
        }
        .swipeActions {
            Button("Remove", role: .destructive) {
                habitPendingRemoval = habit
            }
        }
    }
}
