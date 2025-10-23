import SwiftUI
internal import CoreData

struct TaskRowView: View {
    @ObservedObject var task: Task
    var onTap: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            // Toggle complete
            Button(action: toggleCompleted) {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .imageScale(.large)
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 4) {
                Text(task.title ?? "") // si title es non-optional en el modelo
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
        let newValue = !task.isCompleted
        print("✅ toggle tap. was=\(task.isCompleted) -> now=\(newValue)")

        task.isCompleted = newValue
        task.updatedAt = Date()

        // Opcional: desactiva futuras reprogramaciones si estaba completa
        if newValue { task.dueDate = nil }

        do {
            try task.managedObjectContext?.save()
            print("✅ saved toggle. isCompleted=\(task.isCompleted)")
        } catch {
            print("❌ save error on toggle:", error.localizedDescription)
        }

        // Lógica centralizada de notifs (cancela si completed o sin dueDate)
        NotificationsService.shared.updateReminder(for: task)
    }
}
