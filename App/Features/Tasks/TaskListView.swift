import SwiftUI
import CoreData

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
            offsets.map { tasks[$0] }.forEach(context.delete)
            try? context.save()
        }
    }
}

struct TaskRowView: View {
    @ObservedObject var task: Task
    var onTap: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Button(action: toggleCompleted) {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .imageScale(.large)
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .font(.headline)
                    .strikethrough(task.isCompleted)
                if let due = task.dueDate {
                    Text(due, style: .date)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                if let notes = task.notes, !notes.isEmpty {
                    Text(notes)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
            }
            Spacer()
        }
        .contentShape(Rectangle())
        .onTapGesture { onTap() }
    }

    private func toggleCompleted() {
        task.isCompleted.toggle()
        task.updatedAt = Date()
        try? task.managedObjectContext?.save()
    }
}
