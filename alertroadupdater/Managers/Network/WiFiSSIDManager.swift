import SwiftUI
import SystemConfiguration.CaptiveNetwork

class WiFiSSIDManager: NSObject, ObservableObject {
    @Published var ssid: String? = nil
    
    // Referencia externa al PermissionsViewModel
    var permissionsViewModel: PermissionsViewModel?
    
    override init() {
        super.init()
    }
    
    // MARK: - Public Methods
    func fetchSSID() {
        guard let permissionsVM = permissionsViewModel else {
            print("❌ PermissionsViewModel no está configurado")
            return
        }
        
        guard permissionsVM.isLocationServicesEnabled else {
            print("❌ Los servicios de localización están deshabilitados en el sistema")
            return
        }
        
        guard permissionsVM.hasLocationPermission else {
            print("❌ No hay permisos de ubicación para obtener el SSID")
            return
        }
        
        if let currentSSID = getCurrentSSID() {
            DispatchQueue.main.async {
                self.ssid = currentSSID
                print("✅ SSID obtenido: \(currentSSID)")
            }
        } else {
            DispatchQueue.main.async {
                self.ssid = nil
            }
            print("⚠️ No se pudo obtener el SSID")
        }
    }
    
    // MARK: - Private Methods
    private func getCurrentSSID() -> String? {
        if let interfaces = CNCopySupportedInterfaces() as? [String] {
            for interface in interfaces {
                if let info = CNCopyCurrentNetworkInfo(interface as CFString) as NSDictionary? {
                    if let ssid = info[kCNNetworkInfoKeySSID as String] as? String {
                        return ssid
                    }
                }
            }
        }
        return nil
    }
}
