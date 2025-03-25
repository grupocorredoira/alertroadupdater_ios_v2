import Foundation
import Combine
import Network

/// `ConnectionViewModel` maneja la lógica de conexión Wi-Fi y detección de dispositivos.
class ConnectionViewModel: ObservableObject {
    private let connectionManager: ConnectionManager
    private var cancellables = Set<AnyCancellable>()

    @Published var matchedSSID: String? = nil
    @Published var isConnectedToDevice: Bool = false
    @Published var availableSSIDs: [String] = []

    // Inicializador público que toma ConnectionManager como parámetro
    public init(connectionManager: ConnectionManager) {
        self.connectionManager = connectionManager
    }

    /// Inicia la monitorización de la conexión a un SSID específico.
    func startMonitoringConnection(ssid: String?) {
        Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                let currentSSID = self.connectionManager.getCurrentSSID()
                self.isConnectedToDevice = (currentSSID == ssid)
            }
            .store(in: &cancellables)
    }

    /// Abre la configuración de Wi-Fi en iOS.
    func openWifiSettings() {
        connectionManager.openWiFiSettings()
    }

    /// Conecta al dispositivo detectado.
    func connectToDevice(ssid: String) {
        connectionManager.connectToSSID(ssid: ssid) { [weak self] isConnected in
            DispatchQueue.main.async {
                self?.isConnectedToDevice = isConnected
            }
        }
    }

    /// Resetea el estado de detección.
    func resetDetectionState() {
        matchedSSID = nil
        isConnectedToDevice = false
        availableSSIDs = []
    }
}

