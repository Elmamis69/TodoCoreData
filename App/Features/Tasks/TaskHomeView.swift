import SwiftUI
internal import CoreData

struct TaskHomeView: View {
    @State private var scope: TaskScope = .all
    @State private var query: String = ""

    // editor
    @State private var showingEditor = false
    @State private var editingTask: Task? = nil

    var body: some View {
        NavigationStack {
            TaskListView(scope: scope, query: query) { task in
                // abrir editor para editar
                editingTask = task
                showingEditor = true
            }
            .searchable(text: $query, placement: .navigationBarDrawer(displayMode: .automatic),
                        prompt: "Search tasks")
            .navigationTitle("Tasks")
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Picker("", selection: $scope) {
                        ForEach(TaskScope.allCases) { s in
                            Text(s.rawValue).tag(s)
                        }
                    }
                    .pickerStyle(.segmented)
                    .frame(maxWidth: 320)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        editingTask = nil
                        showingEditor = true
                    } label: { Image(systemName: "plus") }
                }
            }
            .sheet(isPresented: $showingEditor) {
                TaskEditorView(taskToEdit: editingTask)
                    .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
            }
        }
    }
}
