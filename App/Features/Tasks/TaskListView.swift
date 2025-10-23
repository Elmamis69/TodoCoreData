import SwiftUI
internal import CoreData

struct TaskListView: View {
    @Environment(\.managedObjectContext) private var context

    @FetchRequest(
        sortDescriptors: [
            NSSortDescriptor(keyPath: \Task.isCompleted, ascending: true),
            NSSortDescriptor(keyPath: \Task.dueDate, ascending: true),
            NSSortDescriptor(keyPath: \Task.createdAt, ascending: true)
        ],
        animation: .default
    ) private var tasks: FetchedResults<Task>

    @State private var showingEditor = false
    @State private var editingTask: Task? = nil

    var body: some View {
        NavigationStack {
            Group {
                if tasks.isEmpty {
                    ContentUnavailableView("No tasks yet",
                                           systemImage: "checklist",
                                           description: Text("Tap + to add your first task."))
                } else {
                    List {
                        ForEach(tasks) { task in
                            TaskRowView(task: task) {
                                editingTask = task
                                showingEditor = true
                            }
                        }
                        .onDelete(perform: delete)
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("Tasks")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        editingTask = nil
                        showingEditor = true
                    } label: { Image(systemName: "plus") }
                }
            }
            .sheet(isPresented: $showingEditor) {
                TaskEditorView(taskToEdit: editingTask)
                    .environment(\.managedObjectContext, context)
            }
        }
    }

    private func delete(offsets: IndexSet) {
        withAnimation {
            let toDelete = offsets.map { tasks[$0] }
            toDelete.forEach { NotificationsService.shared.updateReminder(for: $0) } // esto cancela
            toDelete.forEach(context.delete)
            try? context.save()
        }
    }

}
