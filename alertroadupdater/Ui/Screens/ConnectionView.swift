import SwiftUI

struct ConnectionView: View {
    var title: String
    @ObservedObject var connectionViewModel: ConnectionViewModel
    //@ObservedObject var documentsViewModel: DocumentsViewModel
    @ObservedObject var networkStatusViewModel: NetworkStatusViewModel
    //@ObservedObject var permissionsViewModel: PermissionsViewModel

    @State private var isDetecting = false
    @State private var detectionError: String? = nil
    @State private var triggerDetection = false

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

            WifiNetworksView()

            WifiSettingsButton()
            //EnableWifiButton(isWifiEnabled: networkStatusViewModel.isWifiEnabled)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
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

/*
 struct EnableWifiButton: View {
 var isWifiEnabled: Bool

 var body: some View {
 Button(action: {
 if let url = URL(string: "App-Prefs:root=WIFI") {
 UIApplication.shared.open(url)
 }
 }) {
 Text(isWifiEnabled ? "Wi-Fi Activado" : "Activar Wi-Fi")
 .frame(maxWidth: .infinity)
 .padding()
 .background(isWifiEnabled ? Color.gray : Color.green)
 .foregroundColor(.white)
 .cornerRadius(10)
 }
 .disabled(isWifiEnabled)
 .padding(.horizontal, 16) // Márgenes laterales
 }
 }

 struct DetectDeviceButton: View {
 var isWifiEnabled: Bool
 var matchedSSID: String?
 //var allPermissionsGranted: Bool
 //var onRequestPermissions: () -> Void
 var onStartDetection: () -> Void

 var body: some View {
 Button(action: {
 //if allPermissionsGranted {
 onStartDetection()
 /*} else {
  onRequestPermissions()
  }*/
 }) {
 Text(matchedSSID == nil ? "Detectar dispositivo" : "Dispositivo detectado")
 .frame(maxWidth: .infinity)
 .padding()
 .background(isWifiEnabled && matchedSSID == nil ? Color.green : Color.gray)
 .foregroundColor(.white)
 .cornerRadius(10)
 }
 .disabled(!isWifiEnabled || matchedSSID != nil)
 .padding(.horizontal, 16) // Márgenes laterales
 }
 }

 struct DeviceInfoCard: View {
 var deviceName: String
 var ssid: String

 var body: some View {
 VStack {
 Text("Dispositivo: \(deviceName)")
 .font(.headline)
 .padding(.bottom, 2)
 Text("Red Wi-Fi: \(ssid)")
 .font(.subheadline)
 .foregroundColor(.gray)
 }
 .frame(maxWidth: .infinity)
 .padding()
 .background(Color.white)
 .cornerRadius(10)
 .shadow(radius: 5)
 .padding(.horizontal, 16) // Márgenes laterales
 }
 }

 struct NextButton: View {
 var matchedSSID: String?
 var documentsViewModel: DocumentsViewModel

 @State private var isProcessing = false

 var body: some View {
 Button(action: {
 guard let ssid = matchedSSID else { return }
 isProcessing = true
 documentsViewModel.downloadError = nil // ✅ Se asigna explícitamente a `nil`

 DispatchQueue.global(qos: .background).async {
 documentsViewModel.deleteAllLocalFiles()

 documentsViewModel.downloadAllDocumentsBySSID(ssid: ssid) { result in
 DispatchQueue.main.async {
 isProcessing = false
 }
 }
 }
 }) {
 Text("Siguiente")
 .frame(maxWidth: .infinity)
 .padding()
 .background(matchedSSID != nil ? Color.blue : Color.gray)
 .foregroundColor(.white)
 .cornerRadius(10)
 }
 .disabled(matchedSSID == nil)
 .overlay {
 if isProcessing {
 ProgressView("Descargando documentos...")
 }
 }
 .padding(.horizontal, 16) // Márgenes laterales
 }
 }


 struct DetectionDialog: View {
 var onTimeout: () -> Void
 var onDismiss: () -> Void

 @State private var timer: Int = 5

 var body: some View {
 VStack {
 Text("Detectando dispositivos...")
 .font(.title2)
 .bold()
 .padding(.bottom, 10)

 ProgressView()
 .padding()

 Text("Espere \(timer) segundos")
 .font(.subheadline)

 Button(action: onDismiss) {
 Text("Cancelar")
 .foregroundColor(.red)
 }
 }
 .padding()
 .background(Color.white)
 .cornerRadius(10)
 .shadow(radius: 5)
 .onAppear {
 Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { t in
 if timer > 0 {
 timer -= 1
 } else {
 t.invalidate()
 onTimeout()
 }
 }
 }
 }
 }
*/
