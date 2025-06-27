import Foundation
import Combine
import UserNotifications

@MainActor
final class SettingsViewModel: ObservableObject {
    @Published var notificationsEnabled: Bool = false

    private let notificationsRepository: NotificationsRepository
    @Published var showPermissionBottomSheet = false

    init(notificationsRepository: NotificationsRepository = NotificationsRepository()) {
        self.notificationsRepository = notificationsRepository
        self.notificationsEnabled = notificationsRepository.isNotificationsEnabled()
        print("🔔 Notificaciones activadas al iniciar SettingsViewModel: \(self.notificationsEnabled)")
    }

    func toggleNotifications(_ enable: Bool) {
        print("🟡 Intentando \(enable ? "activar" : "desactivar") notificaciones...")

        if enable {
            // ⚠️ Comprobamos el estado actual del sistema
            UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in
                switch settings.authorizationStatus {
                case .authorized, .provisional:
                    print("✅ Permiso ya concedido, procedemos a suscribir")
                    self?.subscribeToNotifications()
                case .notDetermined:
                    print("🟠 Permiso aún no solicitado, solicitando...")
                    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
                        if let error = error {
                            print("❌ Error solicitando permiso: \(error.localizedDescription)")
                            return
                        }

                        if granted {
                            print("🔐 Permiso concedido tras solicitud")
                            self?.subscribeToNotifications()
                        } else {
                            print("🔕 Usuario rechazó el permiso de notificaciones")
                        }
                    }
                case .denied:
                    print("⛔️ Permiso denegado previamente. No se puede activar.")
                    DispatchQueue.main.async {
                            self?.showPermissionBottomSheet = true
                        }
                @unknown default:
                    print("⚠️ Estado de permiso desconocido")
                }
            }
        } else {
            // 🔴 Desactivamos directamente
            notificationsRepository.setNotificationsEnabled(false) { [weak self] success in
                if success {
                    DispatchQueue.main.async {
                        self?.notificationsEnabled = false
                        print("✅ Notificaciones desactivadas correctamente.")
                    }
                } else {
                    print("❌ Error al desactivar notificaciones.")
                }
            }
        }
    }

    private func subscribeToNotifications() {
        notificationsRepository.setNotificationsEnabled(true) { [weak self] success in
            if success {
                DispatchQueue.main.async {
                    self?.notificationsEnabled = true
                    print("✅ Notificaciones activadas correctamente.")
                }
            } else {
                print("❌ Error al activar notificaciones.")
            }
        }
    }
}
