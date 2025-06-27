import UIKit
import Firebase
import FirebaseAuth

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        FirebaseApp.configure()

        // ✅ Asigna el delegado para notificaciones
                UNUserNotificationCenter.current().delegate = self

                // ✅ Pide permiso para notificaciones
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if let error = error {
                print("❌ Error al pedir permisos de notificaciones: \(error.localizedDescription)")
            } else {
                print("🔐 Permiso notificaciones: \(granted ? "Concedido" : "Denegado")")
                NotificationsRepository().updatePermissionStatus(granted: granted)
            }
        }


                // ✅ Registra para notificaciones remotas
                application.registerForRemoteNotifications()

        return true
    }

    // ✅ Necesario para verificación por SMS
    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        /// TODO - WARNING: solved. Lo dejamos así, es que hay que hacer algo con el return, pero no hace falta
        Auth.auth().canHandleNotification(userInfo)
        completionHandler(.noData)
    }

    // ✅ También necesario para gestionar el URL Scheme (REVERSED_CLIENT_ID)
    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return Auth.auth().canHandle(url)
    }

    // ✅ Registra el token de APNs en Firebase Messaging
        func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
            Messaging.messaging().apnsToken = deviceToken
            print("📱 APNs token registrado correctamente")
        }

        // ✅ Error al registrar APNs
        func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
            print("❌ Error al registrar para notificaciones push: \(error.localizedDescription)")
        }

        // (Opcional) Para mostrar notificaciones cuando la app está en primer plano
        func userNotificationCenter(_ center: UNUserNotificationCenter,
                                    willPresent notification: UNNotification,
                                    withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
            print("🔔 Notificación en primer plano recibida")
            completionHandler([.banner, .sound])
        }
}
