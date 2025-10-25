import SwiftUI
internal import CoreData

struct TaskListView: View {
    @Environment(\.managedObjectContext) private var context

    private let scope: TaskScope
    private let query: String
    private let onEdit: (Task) -> Void

    @FetchRequest private var tasks: FetchedResults<Task>

    init(scope: TaskScope, query: String, onEdit: @escaping (Task) -> Void) {
        self.scope = scope
        self.query = query
        self.onEdit = onEdit

        let sorts = [
            NSSortDescriptor(keyPath: \Task.isCompleted, ascending: true),
            NSSortDescriptor(keyPath: \Task.dueDate, ascending: true),
            NSSortDescriptor(keyPath: \Task.createdAt, ascending: true)
        ]
        let predicate = TaskListView.makePredicate(scope: scope, query: query)

        _tasks = FetchRequest(entity: Task.entity(),
                              sortDescriptors: sorts,
                              predicate: predicate,
                              animation: .default)
    }

    var body: some View {
        Group {
            if tasks.isEmpty {
                ContentUnavailableView(
                    "No tasks \(scope == .all ? "" : "for \(scope.rawValue.lowercased())")",
                    systemImage: "checklist",
                    description: Text(query.isEmpty ? "Tap + to add your first task." : "Try a different search.")
                )
                .padding(.top, 80)
            } else {
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(tasks) { task in
                            TaskRowView(task: task) {
                                onEdit(task)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                    .padding(.bottom, 32)
                }
            }
        }
    }


    private func delete(offsets: IndexSet) {
        withAnimation {
            let toDelete = offsets.map { tasks[$0] }
            toDelete.forEach { NotificationsService.shared.updateReminder(for: $0) }
            toDelete.forEach(context.delete)
            try? context.save()
        }
    }
}

extension TaskListView {
    static func makePredicate(scope: TaskScope, query: String) -> NSPredicate? {
        var subs: [NSPredicate] = []

        switch scope {
        case .all:
            break
        case .pending:
            subs.append(NSPredicate(format: "isCompleted == NO"))
        case .overdue:
            subs.append(NSPredicate(format: "isCompleted == NO"))
            subs.append(NSPredicate(format: "dueDate < %@", NSDate()))
        }

        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty {
            subs.append(NSPredicate(format: "(title CONTAINS[cd] %@) OR (notes CONTAINS[cd] %@)", trimmed, trimmed))
        }

        if subs.isEmpty { return nil }
        return NSCompoundPredicate(andPredicateWithSubpredicates: subs)
    }
}
