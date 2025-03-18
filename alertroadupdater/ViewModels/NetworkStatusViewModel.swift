import Foundation
import Combine
import Network

/// `NetworkStatusViewModel` gestiona el estado de la red, como conexión a Wi-Fi e Internet.
class NetworkStatusViewModel: ObservableObject {
    private let networkStatusRepository: NetworkStatusRepository
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue.global(qos: .background)

    @Published var isWifiEnabled: Bool = false
    @Published var hasInternet: Bool = false

    init(networkStatusRepository: NetworkStatusRepository) {
        self.networkStatusRepository = networkStatusRepository

        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isWifiEnabled = path.usesInterfaceType(.wifi)
                self?.hasInternet = path.status == .satisfied
            }
        }
        monitor.start(queue: queue)
    }
}

