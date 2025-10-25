import SwiftUI
internal import CoreData

struct TaskRowView: View {
    @ObservedObject var task: Task
    var onTap: () -> Void

    private var dueText: String? {
        guard let due = task.dueDate else { return nil }
        // Ej: "Due: Today, 5:30 PM" o "Due: 23 Oct 2025"
        let formatter = DateFormatter()
        formatter.locale = .current

        let cal = Calendar.current
        if cal.isDateInToday(due) {
            formatter.dateFormat = "'Today,' h:mm a"
        } else if cal.isDateInTomorrow(due) {
            formatter.dateFormat = "'Tomorrow,' h:mm a"
        } else {
            formatter.dateFormat = "d MMM yyyy"
        }

        return "Due: " + formatter.string(from: due)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {

            HStack(alignment: .top, spacing: 12) {
                // Complete toggle
                Button(action: toggleCompleted) {
                    Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(task.isCompleted ? .primary : .secondary)
                        .accessibilityLabel(task.isCompleted ? "Mark as not done" : "Mark as done")
                }
                .buttonStyle(.plain)

                VStack(alignment: .leading, spacing: 4) {
                    Text(task.title ?? "")
                        .font(.headline)
                        .strikethrough(task.isCompleted)
                        .foregroundStyle(task.isCompleted ? .secondary : .primary)

                    if let dueText {
                        Text(dueText)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    if let notes = task.notes, !notes.isEmpty {
                        Text(notes)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            .lineLimit(3)
                    }
                }

                Spacer()

                // Botón editar (abre sheet)
                Button {
                    onTap()
                } label: {
                    Image(systemName: "pencil")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(.secondary)
                        .padding(6)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.secondary.opacity(0.1))
                        )
                }
                .buttonStyle(.plain)
            }

            // Línea gris clarita si no está completada
            if !task.isCompleted {
                Divider()
                    .overlay(Color.secondary.opacity(0.2))
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color(.secondarySystemBackground))
        )
        .contentShape(Rectangle())
        .onTapGesture { onTap() }
    }

    private func toggleCompleted() {
        let newValue = !task.isCompleted
        print("✅ toggle tap. was=\(task.isCompleted) -> now=\(newValue)")

        task.isCompleted = newValue
        task.updatedAt = Date()

        // si se completa, limpiamos dueDate para que ya no reprograme
        if newValue { task.dueDate = nil }

        do {
            try task.managedObjectContext?.save()
            print("✅ saved toggle. isCompleted=\(task.isCompleted)")
        } catch {
            print("❌ save error on toggle:", error.localizedDescription)
        }

        NotificationsService.shared.updateReminder(for: task)
    }
}
