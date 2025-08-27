import Foundation
import Network
import SystemConfiguration.CaptiveNetwork
import UIKit


/// `ConnectionManager` maneja la obtención del SSID y la apertura de ajustes de Wi-Fi en iOS.
class ConnectionManager: ObservableObject {
    static let shared = ConnectionManager()
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue.global(qos: .background)
    
    init() {
        monitor.start(queue: queue)
    }
    
    /// Obtiene el SSID de la red Wi-Fi actual.
    func getCurrentSSID() -> String? {
        guard let interfaces = CNCopySupportedInterfaces() as? [String] else { return nil }
        for interface in interfaces {
            if let info = CNCopyCurrentNetworkInfo(interface as CFString) as NSDictionary? {
                return info["SSID"] as? String
            }
        }
        return nil
    }
    
    /// Verifica si está conectado a Wi-Fi.
    func isConnectedToWiFi() -> Bool {
        return monitor.currentPath.usesInterfaceType(.wifi)
    }
    
    /// Obtiene las redes Wi-Fi disponibles.
    func getAvailableSSIDs() -> [String] {
        // En iOS, no se puede obtener la lista de redes Wi-Fi disponibles por restricciones de seguridad.
        return []
    }
    
    /// Simula la conexión a un SSID en iOS (solo apertura de ajustes).
    func connectToSSID(ssid: String, completion: @escaping (Bool) -> Void) {
        DeviceSystemSettingsManager.openWifiSettings()
        completion(false) // No hay forma de conectar automáticamente en iOS sin abrir ajustes.
    }
}

