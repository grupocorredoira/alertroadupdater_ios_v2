import CoreLocation
import SwiftUI

class PermissionsViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()

    @Published var hasLocationPermission = false

    override init() {
        super.init()
        locationManager.delegate = self
    }

    // Acceso seguro al estado actual de permisos
    var locationAuthorizationStatus: CLAuthorizationStatus {
        locationManager.authorizationStatus
    }

    func checkPermissions() {
        let status = locationAuthorizationStatus
        if status == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        } else {
            hasLocationPermission = (status == .authorizedWhenInUse || status == .authorizedAlways)
        }
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        hasLocationPermission = (status == .authorizedWhenInUse || status == .authorizedAlways)
    }
}
