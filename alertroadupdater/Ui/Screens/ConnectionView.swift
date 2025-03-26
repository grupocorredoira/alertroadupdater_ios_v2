import SwiftUI

struct ConnectionView: View {
    var title: String
    @ObservedObject var documentsViewModel: DocumentsViewModel
    @ObservedObject var connectionViewModel: ConnectionViewModel
    @ObservedObject var networkStatusViewModel: NetworkStatusViewModel

    var onNetworkSelected: (String) -> Void

    @State private var selectedNetwork: String? = nil
    @State private var showDialog = false
    @State private var showLoadingDialog = false
    @State private var navigateToUploadView = false

    var deviceName: String? {
        documentsViewModel.getDeviceNameForSSID(selectedNetwork!)!
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Spacer()

            Text("Paso 1: Asegúrate de que el Wi-Fi del dispositivo Alert Road está encendido.")
                .font(.headline)
                .padding(.bottom, 4)
            HelpButton()

            Text("Paso 2: ¿Alguna de estas redes aparece en tus ajustes de Wi-Fi? Seleccionala")
                .font(.headline)
                .padding(.bottom, 4)

            // ✅ Ahora `WifiNetworksView` no maneja `showLoadingDialog`, solo `showDialog`
            WifiNetworksView(documentsViewModel: documentsViewModel, selectedNetwork: $selectedNetwork, showDialog: $showDialog)

            WifiSettingsButton()

            HStack(alignment: .center, spacing: 12) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.yellow)
                    .font(.title2) // Ajusta el tamaño si quieres que sea más visible

                Text("Si no aparece ninguna de estas redes, por favor, revisa el paso 1")
                    .font(.headline)
                    .foregroundColor(.black)
                    .multilineTextAlignment(.leading)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.yellow.opacity(0.2))
            .cornerRadius(12)
            .padding(.horizontal)
            .padding(.bottom, 4)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .alert(isPresented: $showDialog) {
            Alert(
                title: Text("Descargar"),
                message: Text("La red \(selectedNetwork ?? "") pertenece al dispositivo \(deviceName ?? ""). ¿Deseas descargar los documentos asociados a este dispositivo?"),
                primaryButton: .default(Text("Aceptar"), action: startLoading),
                secondaryButton: .cancel()
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

                            Text("Descargando...\nPor favor, espera")
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

        guard networkStatusViewModel.hasInternet else {
            showLoadingDialog = false
            // Muestra una alerta si no hay conexión
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                showNetworkErrorAlert()
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
                    onNetworkSelected(deviceName) // ✅ ahora sí solo se llama una vez
                case .failure:
                    showDownloadErrorAlert()
                }
            }
        }

    }

    private func showNetworkErrorAlert() {
        let alert = UIAlertController(title: "Sin conexión", message: "No hay conexión a Internet. Por favor, vuelve a conectarte antes de continuar.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        UIApplication.shared.windows.first?.rootViewController?.present(alert, animated: true)
    }

    private func showDownloadErrorAlert() {
        let alert = UIAlertController(title: "Error de descarga", message: "No se han podido descargar los documentos. Verifica tu conexión y vuelve a intentarlo.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
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
            Text("Ver cómo hacerlo")
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
                            Image(systemName: "wifi") // Icono de Wi-Fi
                                .foregroundColor(.blue)

                            Text(network)
                                .font(.headline)
                                .foregroundColor(.black)

                            Spacer()
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                        .onTapGesture {
                            selectedNetwork = network
                            showDialog = true // ✅ Ahora solo maneja `showDialog`
                        }
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Conexión")
        .navigationBarTitleDisplayMode(.inline)
    }
}


struct WifiSettingsButton: View {
    var body: some View {
        Button(action: openWifiSettings) {
            Text("Abrir Ajustes de Wi-Fi")
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
