import Foundation
import Network
import SystemConfiguration.CaptiveNetwork

class ConnectionManager {
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue.global(qos: .background)

    init() {
        monitor.start(queue: queue)
    }

    func getCurrentSSID() -> String? {
        if let interfaces = CNCopySupportedInterfaces() as? [String] {
            for interface in interfaces {
                if let info = CNCopyCurrentNetworkInfo(interface as CFString) as NSDictionary? {
                    return info["SSID"] as? String
                }
            }
        }
        return nil
    }

    func isConnectedToWiFi() -> Bool {
        return monitor.currentPath.usesInterfaceType(.wifi)
    }

    func openWiFiSettings() {
        if let url = URL(string: "App-Prefs:root=WIFI"), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
}
