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
    @ObservedObject var permissionsViewModel: PermissionsViewModel

    // MARK: - StateObject (propiedades propias de la vista)

    // MARK: - State
    @State private var showToast = false
    @State private var showPermissionDenied = false
    @State private var fileNames: [String] = []

    // 🆕 Estado global del diálogo
    @State private var activeUpload: (Document, Int)? = nil
    @EnvironmentObject var coordinator: NavigationCoordinator

    @Environment(\.scenePhase) private var scenePhase

    // MARK: - Computed properties
    var ssidSelected: String {
        let ssid = documentsViewModel.getSSIDForDeviceName(deviceName)
        return ssid
    }
    var password: String? {
        documentsViewModel.getPasswordForSSID(ssidSelected)
    }

    private var ipSelected: String {
        documentsViewModel.getIPForDeviceName(deviceName)
    }

    private var portSelected: UInt16 {
        documentsViewModel.getPortForDeviceName(deviceName)
    }

    // MARK: - Timers, Publishers, etc.
    // TODO: revisar porque está ejecutando todos los métodos del body y solo tendría que verificar si se cumple
    // la condición o no
    let ssidCheckTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()


    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 16) {
                CustomNavigationBar(
                    title: "upload_available".localized,
                    showBackButton: true
                ) {
                    coordinator.pop()
                }
                if wifiSSIDManager.ssid == ssidSelected {
                    connectedView
                } else {
                    notConnectedView
                }
            }
            .frame(maxWidth: .infinity, alignment: .topLeading)
            .padding(.top, 8)
            .navigationBarHidden(true)
            if let (document, progress) = activeUpload {
                UploadProgressDialog(
                    document: document,
                    progress: progress,
                    onCloseApp: { exit(0) },
                    onDismiss: { activeUpload = nil }
                )
            }
        }
        .onReceive(ssidCheckTimer) { _ in
            wifiSSIDManager.fetchSSID()
        }
        .onAppear {
            // ✅ Verificar permisos y obtener SSID si están disponibles
            permissionsViewModel.checkLocationPermissions()

            // ✅ Intentar obtener SSID si ya hay permisos
            if permissionsViewModel.hasLocationPermission && permissionsViewModel.isLocationServicesEnabled {
                wifiSSIDManager.fetchSSID()
            }

            loadFileNames()
            let actualFiles = uploadDocumentsViewModel.listAllDocumentsInLocalStorage()
            print("📁 Archivos en disco: \(actualFiles)")
            coordinator.pushIfNeeded(.upload(deviceName: deviceName))
            permissionsViewModel.requestLocalNetworkPermission(host: ipSelected, port: portSelected)
        }
        .onChange(of: scenePhase) { phase in
            if phase == .active {
                print("🔙 App volvió a primer plano: re-chequeando permisos de localización")

                // ✅ Verificar permisos usando el PermissionsViewModel
                permissionsViewModel.checkLocationPermissions()

                // ✅ Solo obtener SSID si hay permisos disponibles
                if permissionsViewModel.hasLocationPermission && permissionsViewModel.isLocationServicesEnabled {
                    wifiSSIDManager.fetchSSID()
                }
            }
        }
        // ✅ Observar cambios en los permisos para obtener SSID automáticamente
        .onChange(of: permissionsViewModel.hasLocationPermission) { hasPermission in
            if hasPermission && permissionsViewModel.isLocationServicesEnabled {
                print("✅ Permisos concedidos - obteniendo SSID")
                wifiSSIDManager.fetchSSID()
            }
        }
        .onChange(of: permissionsViewModel.isLocationServicesEnabled) { isEnabled in
            if isEnabled && permissionsViewModel.hasLocationPermission {
                print("✅ Servicios de localización habilitados - obteniendo SSID")
                wifiSSIDManager.fetchSSID()
            }
        }
        // ✅ Alertas centralizadas desde PermissionsViewModel (eliminar la anterior)
        .alert("Servicios de localización deshabilitados", isPresented: $permissionsViewModel.showLocationServicesEnabledAlert) {
            Button("Abrir Configuración") {
                permissionsViewModel.openAppSettings()
            }
            Button("cancel_button".localized, role: .cancel) {}
        } message: {
            Text("Para obtener información de la red WiFi, necesitas habilitar los servicios de localización en Configuración > Privacidad y Seguridad > Servicios de Localización")
        }
        .alert("permission_required".localized, isPresented: $permissionsViewModel.showLocationPermissionAlert) {
            Button("go_to_settings".localized) {
                permissionsViewModel.openAppSettings()
            }
            Button("cancel_button".localized, role: .cancel) {}
        } message: {
            Text("permission_location".localized)
        }
        .alert(isPresented: $permissionsViewModel.showLocalNetworkAlert) {
            Alert(
                title: Text("Permiso de red local requerido"),
                message: Text(permissionsViewModel.localNetworkError ?? "No se pudo acceder a la red local"),
                dismissButton: .default(Text("Aceptar"))
            )
        }
    }

    private var connectedView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("connect_to_device".localized + " \(deviceName)")
                .font(.title2)
                .bold()
                .foregroundColor(.green)
                .frame(maxWidth: .infinity, alignment: .center)

            Text("documents_to_send".localized)
                .font(.headline)
                .padding(.bottom, 4)
                .frame(maxWidth: .infinity, alignment: .center)

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
            Text("connect_to_network".localized)
                .font(.headline)
                .padding(.top)

            Text(ssidSelected)
                .font(.title3)
                .bold()
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top)

            Text("copy_password".localized)
                .font(.headline)
                .padding(.top)

            if let password = password {
                passwordCopyView(password: password)
            } else {
                Text("unknown_password".localized)
                    .font(.title3)
                    .bold()
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top)
            }

            WifiSettingsButton()

            Spacer()
        }
        .toast(message: "password_copied".localized, icon: "checkmark.circle", isShowing: $showToast)
        .padding()
    }

    private func passwordCopyView(password: String) -> some View {
        HStack(spacing: 8) {
            Text(password)
                .font(.title3)
                .bold()

            Button(action: {
                UIPasteboard.general.string = password
                withAnimation { showToast = true }
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    withAnimation { showToast = false }
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
                    Text("no_files".localized)
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
            .alert("Error", isPresented: .constant(errorMessage != nil)) {
                Button("Ir a Ajustes") {
                    if let url = URL(string: "App-Prefs:root=WIFI"),
                       UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url)
                    }
                    errorMessage = nil
                }
                Button("Cancelar", role: .cancel) {
                    errorMessage = nil
                }
            } message: {
                Text(errorMessage ?? "")
            }
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
            Text("\("document_version".localized): \(document.version.isEmpty ? "última" : document.version)")
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
        showSuccessDialog = true // 👉 Muestra el diálogo desde el inicio de la subida
        uploadDocumentsViewModel.uploadDocument(document) { result in
            if case .failure(let error) = result {
                errorMessage = error.localizedDescription
                showSuccessDialog = false // 👉 Oculta el diálogo en caso de error
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
            showSuccessDialog = true // 👉 Muestra el mensaje de subida completada

        case .available, .error:
            showSuccessDialog = false
            onUploadDone()
        }
    }
}

struct UploadProgressDialog: View {
    let document: Document
    let progress: Int
    let onCloseApp: () -> Void
    let onDismiss: () -> Void

    @EnvironmentObject var coordinator: NavigationCoordinator

    var body: some View {
        ZStack {
            Color.black.opacity(0.4).ignoresSafeArea()

            VStack(spacing: 20) {
                if progress < 100 {
                    ProgressView(value: Float(progress) / 100.0)
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(2)
                        .padding()

                    Text("sending_file".localized)
                        .font(.headline)
                        .foregroundColor(.white)

                    Text(String(format: "progress_completed".localized, progress))
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))

                    Text("dont_close_app".localized)
                        .font(.footnote)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.orange)
                } else {
                    VStack(spacing: 16) {
                        Text("upload_completed".localized)
                            .font(.title2)
                            .bold()
                            .foregroundColor(.green)

                        Text(String(format: "document_success".localized, document.type, document.version))
                            .multilineTextAlignment(.center)
                            .foregroundColor(.white)

                        Button(action: onCloseApp) {
                            Text("finish_and_close".localized)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.green)
                                .foregroundColor(.black)
                                .cornerRadius(8)
                        }

                        BackToHomeButton(onDismiss: onDismiss)
                    }
                }
            }
            .padding(30)
            .background(Color.black.opacity(0.80))
            .cornerRadius(16)
            .padding(.horizontal, 40)
        }
    }
}

struct BackToHomeButton: View {
    let onDismiss: () -> Void
    @EnvironmentObject var coordinator: NavigationCoordinator

    var body: some View {
        Button(action: {
            onDismiss()
            coordinator.popTo(.welcome)
        }) {
            HStack {
                Image(systemName: "house.fill")
                Text("go_to_home".localized)
            }
            .padding()
            .foregroundColor(.gray)
        }
    }
}
