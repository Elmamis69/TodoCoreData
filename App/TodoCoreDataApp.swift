import SwiftUI

@main
struct TodoCoreDataApp: App {
    let persistenceController = PersistenceController.shared

    init() {
        NotificationsService.shared.configure()
    }

    var body: some Scene {
        WindowGroup {
            TaskListView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
