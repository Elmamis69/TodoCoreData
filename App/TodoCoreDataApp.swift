//
//  TodoCoreDataApp.swift
//  TodoCoreData
//
//  Created by Adrian Felix on 22/10/25.
//

import SwiftUI
import CoreData

@main
struct TodoCoreDataApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
