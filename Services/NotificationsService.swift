// Services/NotificationsService.swift
import Foundation
import UserNotifications
internal import CoreData

final class NotificationsService: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationsService()
    private override init() {}

    private func id(for objectID: NSManagedObjectID) -> String {
        objectID.uriRepresentation().absoluteString
    }

    func configure() {
        let c = UNUserNotificationCenter.current()
        c.delegate = self
        c.requestAuthorization(options: [.alert, .badge, .sound]) { granted, err in
            if let err = err { print("🔔 Auth error:", err) }
            print("🔔 Granted:", granted)
        }
    }

    // 🔧 Punto único de verdad
    func updateReminder(for task: Task) {
        let identifier = id(for: task.objectID)
        let center = UNUserNotificationCenter.current()

        // Si está completada o no tiene dueDate → cancelar y salir
        guard !task.isCompleted, let due = task.dueDate else {
            center.removePendingNotificationRequests(withIdentifiers: [identifier])
            center.removeDeliveredNotifications(withIdentifiers: [identifier])
            print("🔔 cancelled id=\(identifier)")
            return
        }

        // (Re)programar
        center.removePendingNotificationRequests(withIdentifiers: [identifier])

        let content = UNMutableNotificationContent()
        content.title = "Task due"
        content.body = task.title ?? ""
        content.sound = .default

        let comps = Calendar.current.dateComponents([.year,.month,.day,.hour,.minute,.second], from: due)
        let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: false)
        let req = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        center.add(req) { err in
            if let err = err { print("🔔 schedule error:", err) }
            else { print("🔔 scheduled id=\(identifier) at \(due)") }
        }
    }

    // opcionales si quieres llamadas directas
    func scheduleReminder(for objectID: NSManagedObjectID, title: String, dueDate: Date) { /* puedes borrar este si usas updateReminder */ }
    func removeReminder(for objectID: NSManagedObjectID) { /* idem */ }

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .list, .sound])
    }
}
