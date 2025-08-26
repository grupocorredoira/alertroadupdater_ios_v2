import Foundation
import FirebaseMessaging

final class NotificationsRepository {
    private let topic = "alert_road_updates"
    private let userDefaultsKey = "notificationsEnabled"
    
    func isNotificationsEnabled() -> Bool {
        let enabled = UserDefaults.standard.bool(forKey: userDefaultsKey)
        print("🔍 isNotificationsEnabled -> \(enabled)")
        return enabled
    }
    
    func setNotificationsEnabled(_ enabled: Bool, completion: @escaping (Bool) -> Void) {
        if enabled {
            Messaging.messaging().subscribe(toTopic: topic) { error in
                if let error = error {
                    print("❌ Error al suscribirse al topic: \(error.localizedDescription)")
                    completion(false)
                } else {
                    print("✅ Suscripción al topic completada con éxito.")
                    UserDefaults.standard.set(true, forKey: self.userDefaultsKey)
                    completion(true)
                }
            }
        } else {
            Messaging.messaging().unsubscribe(fromTopic: topic) { error in
                if let error = error {
                    print("❌ Error al cancelar la suscripción: \(error.localizedDescription)")
                    completion(false)
                } else {
                    print("✅ Cancelación de suscripción al topic completada con éxito.")
                    UserDefaults.standard.set(false, forKey: self.userDefaultsKey)
                    completion(true)
                }
            }
        }
    }
    
    func updatePermissionStatus(granted: Bool) {
        UserDefaults.standard.set(granted, forKey: userDefaultsKey)
        print("💾 Estado de permiso notificaciones actualizado desde AppDelegate: \(granted)")
    }
}
