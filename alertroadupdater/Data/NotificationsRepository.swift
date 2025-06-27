import Foundation
import FirebaseMessaging

final class NotificationsRepository {
    private let topic = "alert_road_updates"
    private let userDefaultsKey = "notificationsEnabled"

    func isNotificationsEnabled() -> Bool {
        return UserDefaults.standard.bool(forKey: userDefaultsKey)
    }

    func setNotificationsEnabled(_ enabled: Bool, completion: @escaping (Bool) -> Void) {
        if enabled {
            Messaging.messaging().subscribe(toTopic: topic) { error in
                if error == nil {
                    UserDefaults.standard.set(true, forKey: self.userDefaultsKey)
                    completion(true)
                } else {
                    completion(false)
                }
            }
        } else {
            Messaging.messaging().unsubscribe(fromTopic: topic) { error in
                if error == nil {
                    UserDefaults.standard.set(false, forKey: self.userDefaultsKey)
                    completion(true)
                } else {
                    completion(false)
                }
            }
        }
    }

    func updatePermissionStatus(granted: Bool) {
        UserDefaults.standard.set(granted, forKey: userDefaultsKey)
        print("💾 Estado de permiso notificaciones actualizado desde AppDelegate: \(granted)")
    }

}
