import Foundation

enum TaskScope: String, CaseIterable, Identifiable {
    case all = "All"
    case pending = "Pending"
    case overdue = "Overdue"

    var id: String { rawValue }
}
