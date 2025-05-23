import SwiftUI
import CoreLocation
import SystemConfiguration.CaptiveNetwork // ✅ Este es el framework correcto

class WiFiSSIDManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private var locationManager = CLLocationManager()

    @Published var ssid: String? = nil
    @Published var hasPermission: Bool = false

    override init() {
        super.init()
        locationManager.delegate = self
    }

    func requestLocationPermission() {
        let status = locationManager.authorizationStatus
        print("📍 Estado de permisos de ubicación: \(status.rawValue)")

        if status == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        } else if status == .authorizedWhenInUse || status == .authorizedAlways {
            hasPermission = true
            fetchSSID()
        } else {
            hasPermission = false
        }
    }

    func fetchSSID() {
        //print("📶 Intentando obtener el SSID actual...")
        guard hasPermission else {
            print("❌ No hay permisos de ubicación para obtener el SSID")
            return
        }

        if let ssid = getCurrentSSID() {
            DispatchQueue.main.async {
                self.ssid = ssid
                //print("✅ SSID obtenido: \(ssid)")
            }
        } else {
            print("⚠️ No se pudo obtener el SSID.")
        }
    }

    public func getCurrentSSID() -> String? {
        if let interfaces = CNCopySupportedInterfaces() as? [String] {
            for interface in interfaces {
                //print("🔍 Comprobando interfaz: \(interface)")
                if let info = CNCopyCurrentNetworkInfo(interface as CFString) as NSDictionary? {
                    if let ssid = info[kCNNetworkInfoKeySSID as String] as? String {
                        return ssid
                    }
                }
            }
        }
        return nil
    }

    // ✅ Se actualiza al cambiar el permiso
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print("🔄 Permisos de ubicación cambiaron a: \(status.rawValue)")
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            hasPermission = true
            fetchSSID()
        } else {
            hasPermission = false
        }
    }
}
