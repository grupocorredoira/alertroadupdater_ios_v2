import Foundation
import Combine

/// ConnectionViewModel se encarga de manejar la lógica relacionada con la conexión Wi-Fi.
/// Se apoya en DocumentsViewModel para obtener los datos necesarios (SSID y contraseñas).
class ConnectionViewModel: ObservableObject {

    private let connectionManager: ConnectionManager
    private let documentsViewModel: DocumentsViewModel
    private var cancellables = Set<AnyCancellable>()

    @Published var matchedSSID: String? = nil
    @Published var isConnectedToDevice: Bool = false

    init(connectionManager: ConnectionManager, documentsViewModel: DocumentsViewModel) {
        self.connectionManager = connectionManager
        self.documentsViewModel = documentsViewModel
    }

    /// Verifica si está conectado al SSID del dispositivo en cuestión.
    func startMonitoringConnection(ssid: String?) {
        Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                do {
                    let currentSSID = self.connectionManager.getCurrentSSID()
                    self.isConnectedToDevice = (currentSSID == ssid)
                } catch {
                    print("Error while monitoring connection: \(error.localizedDescription)")
                    self.isConnectedToDevice = false
                }
            }
            .store(in: &cancellables)
    }

    /// Abre la configuración de Wi-Fi.
    func openWifiSettings() {
        connectionManager.openWifiSettings()
    }

    /// Detecta un dispositivo coincidente buscando entre los SSIDs disponibles y los datos del DocumentsViewModel.
    func detectCompatibleDevices() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            do {
                let availableSSIDs = self.connectionManager.getAvailableSSIDs().map { $0.trimmingCharacters(in: .whitespaces) }
                print("Available SSIDs: \(availableSSIDs)")

                let documentSSIDs = self.documentsViewModel.getAllSSIDs().map { $0.trimmingCharacters(in: .whitespaces) }
                print("Document SSIDs: \(documentSSIDs)")

                let matchedSSID = availableSSIDs.first { documentSSIDs.contains($0) }

                DispatchQueue.main.async {
                    self.matchedSSID = matchedSSID
                    print("Matched SSID: \(String(describing: matchedSSID))")
                }
            } catch {
                print("Error detectando dispositivo: \(error.localizedDescription)")
            }
        }
    }

    /// Conecta al dispositivo detectado.
    func connectToDevice(ssid: String, password: String) {
        connectionManager.connectToExistingWifi(ssid: ssid, password: password) { [weak self] isConnected in
            guard let self = self else { return }
            print("Connected to SSID: \(ssid), Status: \(isConnected)")
            DispatchQueue.main.async {
                self.isConnectedToDevice = isConnected
            }
        }
    }

    /// Devuelve la contraseña de un SSID utilizando DocumentsViewModel.
    func getPasswordForSSID(ssid: String) -> String? {
        return documentsViewModel.getPasswordForSSID(ssid: ssid)
    }

    /// Resetea el estado de detección.
    func resetDetectionState() {
        matchedSSID = nil
        isConnectedToDevice = false
    }

    /// Obtiene los SSIDs disponibles en el entorno.
    func getAvailableSSIDs() -> [String] {
        return connectionManager.getAvailableSSIDs()
    }
}
