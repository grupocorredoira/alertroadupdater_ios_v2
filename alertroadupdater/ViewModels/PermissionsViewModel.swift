import CoreLocation
import SwiftUI

class PermissionsViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()

    // MARK: - Published Properties
    @Published var hasLocationPermission = false
    @Published var isLocationServicesEnabled = false
    @Published var showLocationPermissionAlert = false
    @Published var showLocationServicesEnabledAlert = false

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
}
