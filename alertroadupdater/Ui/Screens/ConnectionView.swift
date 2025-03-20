import SwiftUI

struct ConnectionView: View {
    var title: String
    @ObservedObject var connectionViewModel: ConnectionViewModel
    //@ObservedObject var documentsViewModel: DocumentsViewModel
    @ObservedObject var networkStatusViewModel: NetworkStatusViewModel
    //@ObservedObject var permissionsViewModel: PermissionsViewModel

    @State private var selectedNetwork: String? = nil
    @State private var showDialog = false
    @State private var isLoading = false
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

            WifiNetworksView(selectedNetwork: $selectedNetwork, showDialog: $showDialog)

            WifiSettingsButton()
            //EnableWifiButton(isWifiEnabled: networkStatusViewModel.isWifiEnabled)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .fullScreenCover(isPresented: $navigateToUploadView) {
            UploadView()
        }
        .alert(isPresented: $showDialog) {
            if isLoading {
                return Alert(title: Text("Cargando..."),
                             message: Text("Por favor, espera"),
                             dismissButton: nil)
            } else {
                return Alert(
                    title: Text("Hola"),
                    message: Text("Esto es un texto largo"),
                    primaryButton: .default(Text("Aceptar"), action: startLoading),
                    secondaryButton: .cancel()
                )
            }
        }
    }

    private func startLoading() {
        isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            isLoading = false
            showDialog = false
            navigateToUploadView = true
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
    let wifiNetworks = ["red1", "red2"/*, "red3", "red4", "red5"*/]

    @Binding var selectedNetwork: String?
    @Binding var showDialog: Bool

    var body: some View {
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
                            selectedNetwork = network // ✅ Ahora actualiza el valor en `ConnectionView`
                            showDialog = true // ✅ Activa el diálogo correctamente
                        }
                    }
                }
                .padding()
            }
            .overlay(
                VStack {
                    Spacer()
                    ScrollView(.vertical, showsIndicators: true) { EmptyView() }
                        .frame(width: 0)
                }
            )
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
