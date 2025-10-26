import SwiftUI
internal import CoreData

struct TaskRowView: View {
    @Environment(\.managedObjectContext) private var context

    @ObservedObject var task: Task
    var onEdit: () -> Void
    var onDelete: () -> Void

    private var dueText: String? {
        guard let due = task.dueDate else { return nil }
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

                // Edit button
                Button {
                    onEdit()
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

            HStack {
                Spacer()
                Button {
                    onDelete()
                } label: {
                    Image(systemName: "trash")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.red)
                        .padding(.vertical, 6)
                        .padding(.horizontal, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.red.opacity(0.08))
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color(.secondarySystemBackground))
        )
    }

    private func toggleCompleted() {
        let newValue = !task.isCompleted
        print("✅ toggle tap. was=\(task.isCompleted) -> now=\(newValue)")

        task.isCompleted = newValue
        task.updatedAt = Date()

        // si se completa, quita dueDate para que ya no reprograme sola
        if newValue { task.dueDate = nil }

        do {
            try context.save()
            print("✅ saved toggle. isCompleted=\(task.isCompleted)")
        } catch {
            print("❌ save error on toggle:", error.localizedDescription)
        }

        NotificationsService.shared.updateReminder(for: task)
    }
}
