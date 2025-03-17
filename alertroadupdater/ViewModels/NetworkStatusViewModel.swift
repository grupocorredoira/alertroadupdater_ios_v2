import Foundation
import Combine

class NetworkStatusViewModel: ObservableObject {
    private let networkStatusRepository: NetworkStatusRepository

    @Published var isWifiEnabled: Bool = false
    @Published var hasInternet: Bool = false

    private var cancellables = Set<AnyCancellable>()

    init(networkStatusRepository: NetworkStatusRepository) {
        self.networkStatusRepository = networkStatusRepository

        networkStatusRepository.isWifiEnabled
            .combineLatest(networkStatusRepository.hasInternet)
            .sink { [weak self] isWifiEnabled, hasInternet in
                self?.isWifiEnabled = isWifiEnabled
                self?.hasInternet = isWifiEnabled && hasInternet
            }
            .store(in: &cancellables)
    }
}

struct NetworkStatus {
    let isWifiEnabled: Bool
    let hasInternet: Bool
}
