import SwiftUI
internal import CoreData

struct TaskHomeView: View {
    @State private var scope: TaskScope = .all
    @State private var query: String = ""

    @State private var showingEditor = false
    @State private var editingTask: Task? = nil
    @State private var showingSettings = false

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {

                // Segmented picker
                Picker("", selection: $scope) {
                    ForEach(TaskScope.allCases) { s in
                        Text(s.rawValue).tag(s)
                    }
                }
                .pickerStyle(.segmented)

                // Search field (visual pill). The actual search binding still comes from .searchable
                HStack(spacing: 8) {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(.secondary)
                    TextField("Search tasks", text: $query)
                        .textInputAutocapitalization(.sentences)
                        .disableAutocorrection(false)
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 12)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color(.secondarySystemBackground))
                )

                // The list / scroll of tasks
                TaskListView(scope: scope,
                             query: query,
                             openEditor: { task in
                    editingTask = task // task ó nil
                    showingEditor = true
                })
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .navigationTitle("Tasks")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingSettings = true
                    } label: {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 18, weight: .semibold))
                            .padding(10)
                            .background(
                                Circle()
                                    .fill(Color(.secondarySystemBackground))
                            )
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        editingTask = nil // crear nueva
                        showingEditor = true
                        
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 18, weight: .semibold))
                            .padding(10)
                            .background(
                                Circle()
                                    .fill(Color(.secondarySystemBackground))
                            )
                    }
                }
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }

            .sheet(isPresented: $showingEditor) {
                TaskEditorView(taskToEdit: editingTask)
                    .environment(\.managedObjectContext,
                                  PersistenceController.shared.container.viewContext)
            }
        }
    }
}
