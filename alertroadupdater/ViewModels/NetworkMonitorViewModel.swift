import Foundation
import Network
import Combine

class NetworkMonitorViewModel: ObservableObject {
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")
    
    @Published var hasInternet: Bool = true
    
    init() {
        monitor.pathUpdateHandler = { [weak self] path in
            guard let self = self else { return }
            
            if path.status == .satisfied {
                // 🔍 Aquí hacemos una petición real a Internet
                self.testInternetConnection { success in
                    DispatchQueue.main.async {
                        self.hasInternet = success
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.hasInternet = false
                }
            }
        }
        monitor.start(queue: queue)
    }
    
    private func testInternetConnection(completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: AppConstants.linkToTestInternet) else {
            completion(false)
            return
        }
        var request = URLRequest(url: url)
        request.timeoutInterval = 5
        
        URLSession.shared.dataTask(with: request) { _, response, error in
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                completion(true)  // ✅ Internet OK
            } else {
                completion(false) // ❌ Sin Internet real
            }
        }.resume()
    }
    
    deinit {
        monitor.cancel()
    }
}
