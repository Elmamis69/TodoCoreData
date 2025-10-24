import SwiftUI
internal import CoreData

@main
struct TodoCoreDataApp: App {
    let persistenceController = PersistenceController.shared

    init() {
        NotificationsService.shared.configure()
    }

    var body: some Scene {
        WindowGroup {
            TaskHomeView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
