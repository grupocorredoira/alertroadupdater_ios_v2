import SwiftUI
import NetworkExtension
import CoreLocation

struct UploadView: View {
    // MARK: - Constantes públicas
    var title: String = "Cargar archivos"
    var deviceName: String

    // MARK: - Dependencias externas (observed, environment)
    @ObservedObject var documentsViewModel: DocumentsViewModel
    @ObservedObject var uploadDocumentsViewModel : UploadDocumentsViewModel
    @ObservedObject var wifiSSIDManager: WiFiSSIDManager

    // MARK: - StateObject (propiedades propias de la vista)
    @StateObject private var wifiManager = WiFiSSIDManager()

    // MARK: - State
    @State private var showToast = false
    @State private var showPermissionDenied = false
    @State private var fileNames: [String] = []

    // MARK: - Computed properties
    var ssidSelected: String {
        let ssid = documentsViewModel.getSSIDForDeviceName(deviceName)
        print("🔍 [ssidSelected] Para deviceName: '\(deviceName)', se encontró SSID: '\(ssid)'")
        return ssid
    }
    var password: String? {
        documentsViewModel.getPasswordForSSID(ssidSelected)
    }

    // MARK: - Timers, Publishers, etc.
    let ssidCheckTimer = Timer.publish(every: 2, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {

            if wifiManager.ssid == ssidSelected {
                Text("Conectado a \(deviceName)")
                    .font(.title2)
                    .bold()
                    .foregroundColor(.green)
                    .frame(maxWidth: .infinity, alignment: .center)

                Text("Documentos disponibles para el dispositivo:")
                    .font(.headline)
                    .padding(.bottom, 4)

                FileSelectionListView(uploadDocumentsViewModel: uploadDocumentsViewModel, deviceName: deviceName)
            } else {
                VStack {
                    Text("Conéctate a la red WiFi:")
                        .font(.headline)
                        .padding(.top)

                    Text(ssidSelected)
                        .font(.title3)
                        .bold()
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top)

                    Text("Copia la siguiente contraseña:")
                        .font(.headline)
                        .padding(.top)

                    if let password = password {
                        HStack(spacing: 8) {
                            Text(password)
                                .font(.title3)
                                .bold()

                            Button(action: {
                                UIPasteboard.general.string = password
                                withAnimation {
                                    showToast = true
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                    withAnimation {
                                        showToast = false
                                    }
                                }
                            }) {
                                Image(systemName: "doc.on.doc")
                                    .foregroundColor(.blue)
                                    .font(.title3)
                            }
                            .buttonStyle(BorderlessButtonStyle())
                        }
                        .padding(.top)
                        .frame(maxWidth: .infinity, alignment: .center)
                    } else {
                        Text("Contraseña no disponible")
                            .font(.title3)
                            .bold()
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.top)
                    }

                    Spacer()

                    WifiSettingsButton()
                }
                .toast(message: "Contraseña copiada", icon: "checkmark.circle", isShowing: $showToast)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .onReceive(ssidCheckTimer) { _ in
            wifiManager.fetchSSID()
        }
        .alert(isPresented: $showPermissionDenied) {
            Alert(title: Text("Permisos requeridos"),
                  message: Text("Debes permitir acceso a la localización para detectar la red Wi-Fi."),
                  dismissButton: .default(Text("Aceptar")))
        }
        .onAppear {
            wifiSSIDManager.requestLocationPermission()
            loadFileNames()
            print("📲 [onAppear] deviceName: \(deviceName)")
            print("📶 [onAppear] wifiManager.ssid: \(wifiManager.ssid ?? "nil")")
            print("🧩 [onAppear] ssidSelected: \(ssidSelected)")

            // 🚨 Lista de archivos reales en disco
            let actualFiles = uploadDocumentsViewModel.listAllDocumentsInLocalStorage()
            print("📁 Archivos en disco: \(actualFiles)")
        }

    }

    private func loadFileNames() {
        let fileManager = FileManager.default
        if let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
            do {
                let files = try fileManager.contentsOfDirectory(atPath: documentsURL.path)
                fileNames = files
                print("📄 Archivos locales encontrados:", files)
            } catch {
                print("❌ Error al leer archivos locales: \(error.localizedDescription)")
            }
        }
    }
}

/// Caja que contenedora de cada tarjeta
struct FileSelectionListView: View {
    @ObservedObject var uploadDocumentsViewModel: UploadDocumentsViewModel
    var deviceName: String

    init(uploadDocumentsViewModel: UploadDocumentsViewModel, deviceName: String) {
        self.uploadDocumentsViewModel = uploadDocumentsViewModel
        self.deviceName = deviceName
        print("📂 FileSelectionListView init con deviceName:", deviceName)
    }

    var body: some View {
        let documents = uploadDocumentsViewModel.getDocumentsStoredLocallyForDevice(deviceName: deviceName)

        return ScrollView { // ✅ Envuelve en ScrollView
            VStack(alignment: .leading, spacing: 10) {
                if documents.isEmpty {
                    Text("No hay documentos almacenados localmente para este dispositivo.")
                        .foregroundColor(.red)
                } else {
                    ForEach(documents, id: \.id) { document in
                        UploadDocumentRowView(document: document)
                    }
                }
            }
            .padding()
        }
    }
}

/// Tarjeta de cada documento
struct UploadDocumentRowView: View {
    let document: Document

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(document.type)
                    .font(.headline)

                Text(document.deviceName)
                    .font(.subheadline)

                Text("Versión: \(document.version)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }

            Spacer()

            Button(action: {
            }) {
                Text("Enviar")
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.blue)
                    .cornerRadius(8)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.gray.opacity(0.2))
        .cornerRadius(8)
    }
}
