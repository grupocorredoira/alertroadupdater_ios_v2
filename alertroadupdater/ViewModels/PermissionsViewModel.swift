import Foundation
import Combine
import CoreLocation

class PermissionsViewModel: NSObject, ObservableObject {
    @Published var locationGranted = false
    @Published var showPermissionSheet = false

    private let locationManager = CLLocationManager()

    override init() {
        super.init()
        locationManager.delegate = self
        checkPermissions()
    }

    func checkPermissions() {
        let status = CLLocationManager.authorizationStatus()
        locationGranted = (status == .authorizedWhenInUse || status == .authorizedAlways)
        showPermissionSheet = !locationGranted
    }

    func requestPermission() {
        locationManager.requestWhenInUseAuthorization()
    }
}

extension PermissionsViewModel: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkPermissions()
    }
}
