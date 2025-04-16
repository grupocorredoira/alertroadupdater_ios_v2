import SwiftUI
import CoreLocation

struct WelcomeView: View {
    //@ObservedObject var loginViewModel: LoginViewModel
    //@ObservedObject var usersHandler: UsersHandler
    @EnvironmentObject var coordinator: NavigationCoordinator
    @State private var showPaymentDialog: Bool = false
    @State private var isCheckingUser: Bool = false
    @State private var snackbarMessage: String?
    @ObservedObject var wifiSSIDManager: WiFiSSIDManager
    @State private var showPermissionDenied = false
    @ObservedObject var permissionsViewModel: PermissionsViewModel // ✅ ESTA ES LA BUENA
    var title: String = "Alert Road"

    var body: some View {
        VStack(spacing: 16) {
            // Barra de navegación arriba del todo

            TopAppBarComponentWithLogoAndMenu(
                showMenu: true,
                onMenuClick: {
                    coordinator.navigate(to: .settings)
                }
            )

            Spacer()

            Text("¡Bienvenido!")
                .font(.largeTitle)
                .bold()

            Text("Teléfono registrado: \(PreferencesManager.shared.getPhoneNumberWithPrefix())")
                .font(.footnote)
                .multilineTextAlignment(.center)
                .padding(.bottom, 16)

            Button(action: {
                handleStartButtonTap()
                isCheckingUser = true
                coordinator.navigate(to: .connection)
            }) {
                Text("Empezar")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding(.horizontal, 16)

            Spacer()
            Spacer()
        }
        .padding(.top, 8)
        .navigationBarHidden(true)
        .alert(isPresented: $showPermissionDenied) {
            Alert(title: Text("Permisos requeridos"),
                  message: Text("Debes permitir acceso a la localización para detectar la red Wi-Fi."),
                  dismissButton: .default(Text("Aceptar")))
        }
        .onAppear {
            wifiSSIDManager.requestLocationPermission()
            coordinator.pushIfNeeded(.welcome)
        }
    }

    private func handleStartButtonTap() {
        let status = CLLocationManager.authorizationStatus()

        if status == .authorizedWhenInUse || status == .authorizedAlways {
            coordinator.navigate(to: .connection)
        } else if status == .notDetermined {
            permissionsViewModel.checkPermissions()

            // Escucha el cambio de permisos en segundo plano
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                if permissionsViewModel.hasLocationPermission {
                    coordinator.navigate(to: .connection)
                } else {
                    snackbarMessage = "Se necesitan permisos de ubicación para continuar"
                }
            }
        } else {
            snackbarMessage = "Se necesitan permisos de ubicación para continuar"
        }
    }
}
