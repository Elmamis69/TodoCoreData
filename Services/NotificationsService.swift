import Foundation
import UserNotifications
import CoreData

final class NotificationsService: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationsService()
    private override init() {}

    func configure() {
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        center.requestAuthorization(options: [.alert, .badge, .sound]) { _, err in
            if let err = err { print("Notification auth error: \(err)") }
        }
    }

    func scheduleReminder(for objectID: NSManagedObjectID, title: String, dueDate: Date) {
        let center = UNUserNotificationCenter.current()
        let id = objectID.uriRepresentation().absoluteString
        center.removePendingNotificationRequests(withIdentifiers: [id])

        let content = UNMutableNotificationContent()
        content.title = "Task due"
        content.body = title
        content.sound = .default

        let comps = Calendar.current.dateComponents([.year,.month,.day,.hour,.minute], from: dueDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: false)
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        center.add(request) { if let err = $0 { print("schedule error: \(err)") } }
    }

    func removeReminder(for objectID: NSManagedObjectID) {
        let id = objectID.uriRepresentation().absoluteString
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .list, .sound])
    }
}
