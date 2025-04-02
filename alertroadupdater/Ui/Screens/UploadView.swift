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

    // 🆕 Estado global del diálogo
    @State private var activeUpload: (Document, Int)? = nil

    // MARK: - Computed properties
    var ssidSelected: String {
        let ssid = documentsViewModel.getSSIDForDeviceName(deviceName)
        //print("🔍 [ssidSelected] Para deviceName: '\(deviceName)', se encontró SSID: '\(ssid)'")
        return ssid
    }
    var password: String? {
        documentsViewModel.getPasswordForSSID(ssidSelected)
    }

    // MARK: - Timers, Publishers, etc.
    // TODO: revisar porque está ejecutando todos los métodos del body y solo tendría que verificar si se cumple
    // la condición o no
    let ssidCheckTimer = Timer.publish(every: 2, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 16) {
                if wifiManager.ssid == ssidSelected {
                    connectedView
                } else {
                    notConnectedView
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .topLeading)

            // 🆕 Diálogo de progreso a nivel global
            if let (document, progress) = activeUpload {
                UploadProgressDialog(
                    document: document,
                    progress: progress,
                    onCloseApp: { exit(0) },
                    onDismiss: { activeUpload = nil }
                )
            }
        }
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
            let actualFiles = uploadDocumentsViewModel.listAllDocumentsInLocalStorage()
            print("📁 Archivos en disco: \(actualFiles)")
        }
    }

    private var connectedView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Conectado a \(deviceName)")
                .font(.title2)
                .bold()
                .foregroundColor(.green)
                .frame(maxWidth: .infinity, alignment: .center)

            Text("Documentos disponibles para el dispositivo:")
                .font(.headline)
                .padding(.bottom, 4)

            // ✅ Pasamos las callbacks de subida y finalización a cada celda
                        FileSelectionListView(
                            uploadDocumentsViewModel: uploadDocumentsViewModel,
                            deviceName: deviceName,
                            onUploading: { doc, progress in activeUpload = (doc, progress) },
                            onUploadDone: { activeUpload = nil }
                        )
        }
    }

    private var notConnectedView: some View {
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
                passwordCopyView
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

    private var passwordCopyView: some View {
        HStack(spacing: 8) {
            Text(password ?? "")
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
    var onUploading: (Document, Int) -> Void
    var onUploadDone: () -> Void

    var body: some View {
        let documents = uploadDocumentsViewModel.getDocumentsStoredLocallyForDevice(deviceName: deviceName)

        return ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                if documents.isEmpty {
                    Text("No hay documentos almacenados localmente para este dispositivo.")
                        .foregroundColor(.red)
                } else {
                    ForEach(documents, id: \ .id) { document in
                        UploadDocumentRowView(
                            document: document,
                            uploadDocumentsViewModel: uploadDocumentsViewModel,
                            onUploading: onUploading,
                            onUploadDone: onUploadDone
                        )
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
    let uploadDocumentsViewModel: UploadDocumentsViewModel
    var onUploading: (Document, Int) -> Void
    var onUploadDone: () -> Void

    @State private var progress = 0
    @State private var errorMessage: String? = nil
    @State private var showSuccessDialog = false

    var body: some View {
        documentCard
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)
            .alert("Error", isPresented: .constant(errorMessage != nil), actions: { Button("OK") { errorMessage = nil } }, message: {
                Text(errorMessage ?? "")
            })
            .onReceive(uploadDocumentsViewModel.$uploadStates) { handleUploadState($0) }
    }

    /// Vista principal de la tarjeta
    private var documentCard: some View {
        VStack(alignment: .leading) {
            HStack {
                documentInfo
                Spacer()
                uploadButton
            }
            .padding()
        }
    }

    /// Información del documento (tipo, nombre del dispositivo y versión)
    private var documentInfo: some View {
        VStack(alignment: .leading) {
            Text(document.type).font(.headline)
            Text(document.deviceName).font(.subheadline)
            Text("Versión: \(document.version)")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
    }

    /// Botón de envío con estilo
    private var uploadButton: some View {
        Button("Enviar") {
            startUpload()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color.blue)
        .foregroundColor(.white)
        .cornerRadius(8)
        .disabled(uploadDocumentsViewModel.uploadStates[document.id] == .uploaded)
    }

    /// Lógica para iniciar la subida
    private func startUpload() {
        progress = 0
        uploadDocumentsViewModel.uploadDocument(document) { result in
            if case .failure(let error) = result {
                errorMessage = error.localizedDescription
                onUploadDone()
            }
        }
    }

    /// Gestión del estado de subida observado
    private func handleUploadState(_ states: [String: DocumentUploadStatus]) {
        guard let state = states[document.id] else { return }

        switch state {
        case .uploading(let p):
            progress = p
            onUploading(document, p)

        case .uploaded:
            progress = 100
            onUploadDone()

        case .available, .error:
            onUploadDone()
        }
    }
}

struct UploadProgressDialog: View {
    let document: Document
    let progress: Int
    let onCloseApp: () -> Void
    let onDismiss: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.4).ignoresSafeArea()

            VStack(spacing: 20) {
                if progress < 100 {
                    ProgressView(value: Float(progress) / 100.0)
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(2)
                        .padding()

                    Text("Enviando archivo...")
                        .font(.headline)
                        .foregroundColor(.white)

                    Text("\(progress)% completado")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))

                    Text("No cierres la app mientras se realiza el envío")
                        .font(.footnote)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.orange)
                } else {
                    VStack(spacing: 12) {
                        Text("✅ ¡Carga completada!")
                            .font(.title2)
                            .bold()
                            .foregroundColor(.green)

                        Text("El documento '\(document.type)' versión \(document.version) se ha enviado correctamente.")
                            .multilineTextAlignment(.center)
                            .foregroundColor(.white)

                        Button(action: onCloseApp) {
                            Text("Finalizar y cerrar la app")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.green)
                                .foregroundColor(.black)
                                .cornerRadius(8)
                        }

                        Button(action: onDismiss) {
                            Text("Cancelar")
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
            .padding(30)
            .background(Color.black.opacity(0.85))
            .cornerRadius(16)
            .padding(.horizontal, 40)
        }
    }
}
