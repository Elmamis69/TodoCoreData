import SwiftUI
import CoreData

struct TaskEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var context

    var taskToEdit: Task?

    @State private var title: String = ""
    @State private var notes: String = ""
    @State private var dueDate: Date? = nil
    @State private var hasDueDate = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Details") {
                    TextField("Title", text: $title)
                    TextField("Notes", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
                Section("Due date") {
                    Toggle("Has due date", isOn: $hasDueDate)
                    if hasDueDate {
                        DatePicker(
                            "Due",
                            selection: Binding(
                                get: { dueDate ?? Date() },
                                set: { dueDate = $0 }
                            ),
                            displayedComponents: [.date, .hourAndMinute]
                        )
                    }
                }
            }
            .navigationTitle(taskToEdit == nil ? "New Task" : "Edit Task")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .onAppear { load() }
        }
    }

    private func load() {
        guard let t = taskToEdit else { return }
        title = t.title
        notes = t.notes ?? ""
        if let due = t.dueDate { hasDueDate = true; dueDate = due }
    }

    private func save() {
        let task = taskToEdit ?? Task(context: context)
        if taskToEdit == nil { task.id = UUID(); task.createdAt = Date() }
        task.title = title.trimmingCharacters(in: .whitespaces)
        task.notes = notes.trimmingCharacters(in: .whitespacesAndNewlines)
        task.updatedAt = Date()
        task.dueDate = hasDueDate ? dueDate : nil

        do {
            try context.save()
            if let due = task.dueDate {
                NotificationsService.shared.scheduleReminder(for: task.objectID, title: task.title, dueDate: due)
            }
            dismiss()
        } catch {
            print("Save error: \(error)")
        }
    }
}
