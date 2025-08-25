import CoreLocation
import SwiftUI
import Network

class PermissionsViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()

    // MARK: - Published Properties
    @Published var hasLocationPermission = false
    @Published var isLocationServicesEnabled = false
    @Published var showLocationPermissionAlert = false
    @Published var showLocationServicesEnabledAlert = false

    @Published var showLocalNetworkAlert: Bool = false
        @Published var localNetworkError: String? = nil

    override init() {
        super.init()
        locationManager.delegate = self
        checkLocationServicesEnabled()
    }

    // MARK: - Public Properties
    var locationAuthorizationStatus: CLAuthorizationStatus {
        locationManager.authorizationStatus
    }

    // MARK: - Public Methods
    func checkLocationServicesEnabled() {
        isLocationServicesEnabled = CLLocationManager.locationServicesEnabled()
        showLocationServicesEnabledAlert = !isLocationServicesEnabled

        // 📍 Log del estado
        print("📡 Localización del sistema: \(isLocationServicesEnabled ? "ACTIVADA ✅" : "DESACTIVADA ❌")")
    }

    func checkLocationPermissions() {
        checkLocationServicesEnabled()

        let status = locationAuthorizationStatus
        if status == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        } else {
            hasLocationPermission = (status == .authorizedWhenInUse || status == .authorizedAlways)
            showLocationPermissionAlert = (status == .denied || status == .restricted)
        }
    }

    func requestLocationPermission() {
        checkLocationServicesEnabled()

        guard isLocationServicesEnabled else {
            showLocationServicesEnabledAlert = true
            return
        }

        let status = locationAuthorizationStatus
        if status == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        } else {
            hasLocationPermission = (status == .authorizedWhenInUse || status == .authorizedAlways)
            showLocationPermissionAlert = (status == .denied || status == .restricted)
        }
    }

    func openAppSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString),
           UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }

    // MARK: - CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        DispatchQueue.main.async {
            self.hasLocationPermission = (status == .authorizedWhenInUse || status == .authorizedAlways)
            self.showLocationPermissionAlert = (status == .denied || status == .restricted)
        }
    }

    // MARK: - Method para solicitar permiso de envío antes de abrir el socket
    func requestLocalNetworkPermission(host: String, port: UInt16) {
        print("❌ entro a requestLocalNetworkPermission")
            guard let nwPort = NWEndpoint.Port(rawValue: port) else {
                DispatchQueue.main.async {
                    self.localNetworkError = "Puerto inválido"
                    self.showLocalNetworkAlert = true
                }
                return
            }

            let connection = NWConnection(host: NWEndpoint.Host(host), port: nwPort, using: .tcp)

            connection.stateUpdateHandler = { state in
                switch state {
                case .ready:
                    print("✅ Permiso concedido: acceso a \(host):\(port)")
                    connection.cancel()
                case .failed(let error):
                    print("❌ Error permiso red local: \(error.localizedDescription)")
                    DispatchQueue.main.async {
                        self.localNetworkError = error.localizedDescription
                        self.showLocalNetworkAlert = true
                    }
                    connection.cancel()
                default:
                    break
                }
            }

            connection.start(queue: .global())
        }
    
}
