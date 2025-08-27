import UIKit

struct DeviceSystemSettingsManager {

    /// 📱 Abre la app **Ajustes** en la pantalla principal
    static func openGeneralSettings() {
        if let url = URL(string: "App-Prefs:root=INTERNET_TETHERING"), // ⚠️ hack para saltar al menú raíz
           UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        } else if let url = URL(string: UIApplication.openSettingsURLString),
                  UIApplication.shared.canOpenURL(url) {
            // fallback → abre ajustes de la app si no se puede abrir los generales
            UIApplication.shared.open(url)
        }
    }

    /// 📡 Abre los **ajustes de Wi-Fi**
    static func openWifiSettings() {
        if let url = URL(string: "App-Prefs:root=WIFI"),
           UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }

    /// ⚙️ Abre los **ajustes de la aplicación actual**
    static func openAppSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString),
           UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
}
