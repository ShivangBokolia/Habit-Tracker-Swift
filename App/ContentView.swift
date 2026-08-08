import SwiftUI
import SwiftData
import HabitTrackerCore

struct ContentView: View {
    @Environment(\.modelContext) private var context
    @State private var viewModel: HomeViewModel?

    var body: some View {
        Group {
            if let viewModel {
                HomeScreen(viewModel: viewModel)
            } else {
                ProgressView()
            }
        }
        .task {
            if viewModel == nil {
                viewModel = HomeViewModel(context: context)
            }
        }
    }
}