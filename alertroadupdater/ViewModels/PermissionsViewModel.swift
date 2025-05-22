import CoreLocation
import SwiftUI

class PermissionsViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    private var locationManager = CLLocationManager()

    @Published var hasLocationPermission = false

    override init() {
        super.init()
        locationManager.delegate = self
    }

    func checkPermissions() {
        let status = locationManager.authorizationStatus
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

