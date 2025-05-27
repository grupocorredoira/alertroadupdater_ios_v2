import SwiftUI
import CoreLocation
import FirebaseAuth

struct WelcomeView: View {
    @EnvironmentObject var coordinator: NavigationCoordinator
    @State private var showPaymentDialog: Bool = false
    @State private var isCheckingUser: Bool = false
    @State private var snackbarMessage: String?
    @ObservedObject var wifiSSIDManager: WiFiSSIDManager
    @State private var showPermissionDenied = false
    @ObservedObject var permissionsViewModel: PermissionsViewModel
    @ObservedObject var documentsViewModel: DocumentsViewModel
    @StateObject private var purchaseViewModel = PurchaseViewModel()
    @EnvironmentObject var networkMonitorViewModel: NetworkMonitorViewModel
    @State private var showNetworkAlert = false

    var body: some View {
        VStack(spacing: 16) {
            TopAppBarViewWithLogoAndMenu(
                showMenu: true,
                onMenuClick: {
                    coordinator.navigate(to: .settings)
                }
            )

            Spacer()

            Text("welcome_title".localized)
                .font(.largeTitle)
                .bold()

            Text(String(format: "registered_phone".localized, PreferencesManager.shared.getPhoneNumberWithPrefix()))
                .font(.footnote)
                .multilineTextAlignment(.center)
                .padding(.bottom, 16)

            if purchaseViewModel.needsToPay {
                Text("Periodo finalizado. Para continuar necesitas realizar el pago del servicio")
                    .font(.callout)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                Button(action: {
                    if networkMonitorViewModel.hasInternet {
                        Task {
                            await purchaseViewModel.makePurchase()
                        }
                    } else {
                        showNetworkAlert = true
                    }
                }) {
                    Text(purchaseViewModel.isPurchasing ? "Comprando..." : "Comprar servicio")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(purchaseViewModel.purchaseButtonColor)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding(.horizontal, 16)
                .disabled(purchaseViewModel.isPurchasing)

            } else {
                Button(action: {
                    if networkMonitorViewModel.hasInternet {
                        handleStartButtonTap()
                        isCheckingUser = true
                    } else {
                        showNetworkAlert = true
                    }
                }) {
                    Text("start_button".localized)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding(.horizontal, 16)
            }

            Spacer()
            Spacer()
        }
        .padding(.top, 8)
        .navigationBarHidden(true)
        .alert(isPresented: $showPermissionDenied) {
            Alert(
                title: Text("permission_required".localized),
                message: Text("permission_location".localized),
                dismissButton: .default(Text("accept_button".localized))
            )
        }
        .onAppear {
            // ✅ Guardar número si aún no está guardado
            if PreferencesManager.shared.getPhoneNumberWithPrefix().isEmpty,
               let phone = Auth.auth().currentUser?.phoneNumber {
                print("📲 Guardando número de usuario autenticado:", phone)
                PreferencesManager.shared.savePhoneNumberWithPrefix(phone)
            }
            wifiSSIDManager.requestLocationPermission()
            coordinator.pushIfNeeded(.welcome)
            documentsViewModel.refreshDocuments()
            Task {
                await purchaseViewModel.start()
                await purchaseViewModel.refreshPaymentStatus()
            }
        }
        .onChange(of: showNetworkAlert) { show in
            if show {
                NetworkAlertManager.showNoInternetDialog()
                showNetworkAlert = false
            }
        }
    }


    private func handleStartButtonTap() {
        let status = permissionsViewModel.locationAuthorizationStatus

        if status == .authorizedWhenInUse || status == .authorizedAlways {
            coordinator.navigate(to: .connection)
        } else if status == .notDetermined {
            permissionsViewModel.checkPermissions()

            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                if permissionsViewModel.hasLocationPermission {
                    coordinator.navigate(to: .connection)
                } else {
                    snackbarMessage = "permission_location".localized
                }
            }
        } else {
            snackbarMessage = "permission_location".localized
        }
    }
}
