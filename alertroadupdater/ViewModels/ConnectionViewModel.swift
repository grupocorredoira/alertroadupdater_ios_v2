import Foundation
import Combine
import Network

/// `ConnectionViewModel` maneja la lógica de conexión Wi-Fi y detección de dispositivos.
class ConnectionViewModel: ObservableObject {
    private let connectionManager: ConnectionManager
    private let documentsViewModel: DocumentsViewModel
    private var cancellables = Set<AnyCancellable>()

    @Published var matchedSSID: String? = nil
    @Published var isConnectedToDevice: Bool = false
    @Published var availableSSIDs: [String] = []

    init(connectionManager: ConnectionManager, documentsViewModel: DocumentsViewModel) {
        self.connectionManager = connectionManager
        self.documentsViewModel = documentsViewModel
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

    /// Detecta dispositivos compatibles según la lista de redes Wi-Fi disponibles.
    func detectCompatibleDevices() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            let availableSSIDs = self.connectionManager.getAvailableSSIDs()
            let documentSSIDs = self.documentsViewModel.getAllSSIDs()
            let matchedSSID = availableSSIDs.first { documentSSIDs.contains($0) }

            DispatchQueue.main.async {
                self.matchedSSID = matchedSSID
                self.availableSSIDs = availableSSIDs
            }
        }
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
