import Foundation
import Network
import Combine

class NetworkStatusRepository: ObservableObject {
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue.global(qos: .background)

    @Published var isWiFiEnabled: Bool = false
    @Published var hasInternet: Bool = false

    init() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isWiFiEnabled = path.usesInterfaceType(.wifi)
                self?.hasInternet = path.status == .satisfied
            }
        }
        monitor.start(queue: queue)
    }
}
