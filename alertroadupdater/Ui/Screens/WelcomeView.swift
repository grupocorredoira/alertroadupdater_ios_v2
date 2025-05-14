import SwiftUI
import CoreLocation

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

    var body: some View {
        VStack(spacing: 16) {
            TopAppBarComponentWithLogoAndMenu(
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
                    Task {
                        await purchaseViewModel.makePurchase()
                    }
                }) {
                    Text(purchaseViewModel.isPurchasing ? "Comprando..." : "Comprar servicio")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding(.horizontal, 16)
                .disabled(purchaseViewModel.isPurchasing)
            } else {
                Button(action: {
                    handleStartButtonTap()
                    isCheckingUser = true
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

            //TODO - BORRAR, solo testing
            Button(action: {
                handleStartButtonTap()
                isCheckingUser = true
            }) {
                Text("start_button".localized)
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
            Alert(
                title: Text("permission_required".localized),
                message: Text("permission_location".localized),
                dismissButton: .default(Text("accept_button".localized))
            )
        }
        .onAppear {
            wifiSSIDManager.requestLocationPermission()
            coordinator.pushIfNeeded(.welcome)
            documentsViewModel.refreshDocuments()
            Task {
                await purchaseViewModel.start()
            }
        }
    }

    private func handleStartButtonTap() {
        let status = CLLocationManager.authorizationStatus()

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
