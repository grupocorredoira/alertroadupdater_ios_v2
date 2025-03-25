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

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Spacer()

            Text("Paso 1: Asegúrate de que el Wi-Fi del dispositivo Alert Road está encendido.")
                .font(.headline)
                .padding(.bottom, 4)
            HelpButton()

            Text("Paso 2: ¿Alguna de estas redes aparece en tus ajustes de Wi-Fi?")
                .font(.headline)
                .padding(.bottom, 4)

            // ✅ Ahora `WifiNetworksView` no maneja `showLoadingDialog`, solo `showDialog`
            WifiNetworksView(documentsViewModel: documentsViewModel, selectedNetwork: $selectedNetwork, showDialog: $showDialog)

            WifiSettingsButton()
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .alert(isPresented: $showDialog) {
            Alert(
                title: Text("Descargar"),
                message: Text("¿Deseas descargar los documentos asociados a la red \(selectedNetwork ?? "")"),
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
        showLoadingDialog = true // ✅ Abre el diálogo de carga antes de cerrar el anterior
        showDialog = false // ✅ Cierra el primer diálogo inmediatamente

        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            showLoadingDialog = false // ✅ Cierra la carga
            if let ssid = selectedNetwork {
                            onNetworkSelected(ssid) // ✅ Llama a NavGraph para cambiar de pantalla
                        }
        }
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
