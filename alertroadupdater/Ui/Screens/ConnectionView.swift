import SwiftUI

struct ConnectionView: View {
    // MARK: - Constantes públicas
    var title: String
    @ObservedObject var documentsViewModel: DocumentsViewModel
    @ObservedObject var connectionViewModel: ConnectionViewModel
    @EnvironmentObject var networkMonitorViewModel: NetworkMonitorViewModel

    var onNetworkSelected: (String) -> Void

    @State private var selectedNetwork: String? = nil
    @State private var showDialog = false
    @State private var showLoadingDialog = false

    @EnvironmentObject var coordinator: NavigationCoordinator

    var deviceName: String? {
        documentsViewModel.getDeviceNameForSSID(selectedNetwork!)!
    }

    var body: some View {
        VStack(spacing: 16) {
            CustomNavigationBar(
                title: "connection_title".localized,
                showBackButton: true
            ) {
                coordinator.pop()
            }

            Spacer()

            Text("step_one".localized)
                .font(.headline)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading) // fuerza el ancho
                .padding(.horizontal, 16)
                .padding(.bottom, 4)

            HelpButton()

            Spacer()

            Text("step_two".localized)
                .font(.headline)
                .multilineTextAlignment(.leading)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 16)
                .padding(.bottom, 4)

            WifiNetworksView(documentsViewModel: documentsViewModel, selectedNetwork: $selectedNetwork, showDialog: $showDialog)

            WifiSettingsButton()

            HStack(alignment: .center, spacing: 12) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.yellow)
                    .font(.title2)

                Text("device_not_found".localized)
                    .font(.headline)
                    .foregroundColor(.black)
                    .multilineTextAlignment(.leading)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.yellow.opacity(0.2))
            .cornerRadius(12)
            .padding(.horizontal)
            .padding(.bottom, 4)

            Spacer()
        }
        .onAppear {
            coordinator.pushIfNeeded(.connection)
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .padding(.top, 8)
        .navigationBarHidden(true)
        .alert(isPresented: $showDialog) {
            Alert(
                title: Text("download_button".localized),
                message: Text(String(format: "step_documents".localized, deviceName ?? "")),
                primaryButton: .default(Text("accept_button".localized), action: startLoading),
                secondaryButton: .cancel(Text("cancel_button".localized))
            )
        }
        .overlay(
            Group {
                if showLoadingDialog {
                    ZStack {
                        Color.black.opacity(0.4)
                            .edgesIgnoringSafeArea(.all)

                        VStack(spacing: 20) {
                            ProgressView()
                                .scaleEffect(2) // 🔍 Más grande para mayor visibilidad
                                .tint(.white)   // ✅ Estilo blanco, más moderno
                                .padding()

                            Text("updating_documents".localized)
                                .multilineTextAlignment(.center)
                                .foregroundColor(.white)
                                .font(.headline)
                        }
                        .padding(30)
                        .background(Color.black.opacity(0.8)) // 🔳 Fondo más oscuro para contraste
                        .cornerRadius(12)
                    }
                }
            }
        )
    }

    private func startLoading() {
        showLoadingDialog = true
        showDialog = false

        guard networkMonitorViewModel.hasInternet else {
            showLoadingDialog = false
            // Muestra una alerta si no hay conexión
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                NetworkAlertManager.showNoInternetDialog()
            }
            return
        }

        guard let ssid = selectedNetwork,
              let deviceName = documentsViewModel.getDeviceNameForSSID(ssid) else {
            showLoadingDialog = false
            showDownloadErrorAlert()
            return
        }

        let deleteMessage = documentsViewModel.deleteAllLocalFiles()
        print(deleteMessage)

        documentsViewModel.downloadAllDocumentsBySSID(ssid: ssid) { result in
            DispatchQueue.main.async {
                showLoadingDialog = false

                switch result {
                case .success:
                    onNetworkSelected(deviceName)
                case .failure:
                    showDownloadErrorAlert()
                }
            }
        }

    }

    private func showNetworkErrorAlert() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootVC = windowScene.windows.first?.rootViewController else {
            return
        }

        let alert = UIAlertController(
            title: "no_internet_title".localized,
            message: "no_internet_message".localized,
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "accept_button".localized, style: .default))
        alert.addAction(UIAlertAction(title: "go_to_wifi_settings".localized, style: .cancel) { _ in
            if let settingsURL = URL(string: UIApplication.openSettingsURLString),
               UIApplication.shared.canOpenURL(settingsURL) {
                UIApplication.shared.open(settingsURL)
            }
        })

        rootVC.present(alert, animated: true)
    }

    private func showDownloadErrorAlert() {
        let alert = UIAlertController(
            title: "error_dialog_title".localized,
            message: "error_loading_documents".localized,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "accept_button".localized, style: .default))
        UIApplication.shared.windows.first?.rootViewController?.present(alert, animated: true)
    }
}


struct HelpButton: View {
    var body: some View {
        Button(action: {
            if let url = URL(string: "https://help.url") {
                UIApplication.shared.open(url)
            }
        }) {
            Text("help_button".localized)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
        }
        .padding(.horizontal, 16) // Márgenes laterales
    }
}

struct WifiNetworksView: View {
    @ObservedObject var documentsViewModel: DocumentsViewModel
    @Binding var selectedNetwork: String?
    @Binding var showDialog: Bool

    var body: some View {
        let wifiNetworks = documentsViewModel.getAllSSIDs()
        ScrollViewReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(wifiNetworks, id: \.self) { network in
                        HStack {
                            Image(systemName: "wifi")
                                .foregroundColor(.blue)

                            Text(network)
                                .font(.headline)
                                .foregroundColor(.black)

                            Spacer()
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .frame(height: 60) // 🔁 altura fija para cada tarjeta
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                        .onTapGesture {
                            selectedNetwork = network
                            showDialog = true
                        }
                    }
                }
                .padding([.horizontal, .bottom]) // padding sin .top
            }
            .frame(height: 60 * 2.5 + 10 * 2) // 🔁 muestra 2.5 celdas + 2 separaciones
        }
    }
}


struct WifiSettingsButton: View {
    var body: some View {
        Button(action: openWifiSettings) {
            Text("go_to_wifi_settings".localized)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
        }
        .padding(.horizontal, 16)
    }

    private func openWifiSettings() {
        if let url = URL(string: "App-Prefs:WIFI") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}

/* NO BORRAR - PRUEBAS */
// Está para cuando queramos avanzar sin descargar docs
/*
 struct WifiSettingsButton: View {
 @EnvironmentObject var coordinator: NavigationCoordinator // ✅ Esto sí se puede usar

 var body: some View {
 Button(action: {
 coordinator.navigate(to: .upload(deviceName:"alertroadV6")) // ✅ TEST directo sin descargas
 }) {
 Text("Ir a UploadView (TEST)")
 .frame(maxWidth: .infinity)
 .padding()
 .background(Color.green)
 .foregroundColor(.white)
 .cornerRadius(10)
 }
 .padding(.horizontal, 16)
 }
 }
 */
