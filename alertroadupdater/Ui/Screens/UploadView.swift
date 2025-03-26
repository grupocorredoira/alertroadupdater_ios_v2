import SwiftUI
import NetworkExtension
import CoreLocation

struct UploadView: View {
    var title: String = "Cargar archivos"
    var deviceName: String

    @StateObject private var wifiManager = WiFiSSIDManager()
    @ObservedObject var uploadDocumentsViewModel : UploadDocumentsViewModel
    @ObservedObject var documentsViewModel: DocumentsViewModel

    var ssidSelected: String {
        let ssid = documentsViewModel.getSSIDForDeviceName(deviceName)
        print("🔍 [ssidSelected] Para deviceName: '\(deviceName)', se encontró SSID: '\(ssid)'")
        return ssid
    }

    var password: String? {
        documentsViewModel.getPasswordForSSID(ssidSelected)
    }

    @State private var showToast = false

    let ssidCheckTimer = Timer.publish(every: 2, on: .main, in: .common).autoconnect()

    @ObservedObject var wifiSSIDManager: WiFiSSIDManager
    @State private var showPermissionDenied = false

    @State private var fileNames: [String] = []

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {

            if wifiManager.ssid == ssidSelected {
                // ✅ Coincide con la red esperada
                Text("Dispositivo conectado \(deviceName)")
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
                                Image(systemName: "doc.on.doc") // 📋 Icono de copiar
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
                // ✅ Aquí aplicamos el toast
                .toast(message: "Contraseña copiada", icon: "checkmark.circle", isShowing: $showToast)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .onReceive(ssidCheckTimer) { _ in
            wifiManager.fetchSSID()
            print("🔁 [Timer] wifiManager.ssid: \(wifiManager.ssid ?? "nil") | ssidSelected: \(ssidSelected ?? "nil") | deviceName: \(deviceName)")
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
            print("🧩 [onAppear] ssidSelected: \(ssidSelected ?? "nil")")
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

/*struct FileSelectionView: View {
 let sampleFiles = ["Documento A", "Documento B", "Documento C"]

 var body: some View {
 VStack(alignment: .leading, spacing: 10) {
 ForEach(sampleFiles, id: \.self) { file in
 HStack {
 Image(systemName: "doc.fill")
 .foregroundColor(.blue)

 Text(file)
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
 }*/

struct UploadDocumentRowView: View {
    let document: Document

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(document.type)
                    .font(.headline)

                Text("Versión: \(document.version)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }

            Spacer()

            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
                .font(.title2)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.gray.opacity(0.2))
        .cornerRadius(8)
    }
}

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

        return VStack(alignment: .leading, spacing: 10) {
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








/*
 struct UploadView: View {
 @ObservedObject var connectionViewModel: ConnectionViewModel
 @ObservedObject var documentsViewModel: DocumentsViewModel
 @ObservedObject var uploadDocumentsViewModel: UploadDocumentsViewModel

 var deviceName: String?

 @State private var snackbarMessage: String?
 @State private var showUploadDialog: Bool = false
 @State private var showSuccessDialog: Bool = false
 @State private var uploadError: String?

 var body: some View {
 NavigationView {
 VStack {
 TopAppBarComponent(title: "Subir archivos") {
 // Acción para retroceder
 }

 if connectionViewModel.isConnectedToDevice {
 Text("Conectado a \(deviceName ?? "Desconocido")")
 .font(.title)
 .bold()
 .foregroundColor(.green)
 .multilineTextAlignment(.center)
 .padding(.top, 16)

 Spacer()

 Text("Archivos para subir:")
 .font(.headline)

 List {
 ForEach(uploadDocumentsViewModel.getDocumentsStoredLocallyForDevice(deviceName: deviceName)) { document in
 UploadDocumentRow(
 document: document,
 uploadDocumentsViewModel: uploadDocumentsViewModel,
 onUploadError: { errorMessage in
 self.uploadError = errorMessage
 self.showUploadDialog = false
 },
 onUploadSuccess: {
 self.showSuccessDialog = true
 }
 )
 }
 }
 } else {
 Text("No conectado al dispositivo")
 .foregroundColor(.red)
 .bold()

 Button(action: {
 connectionViewModel.openWifiSettings()
 }) {
 Text("Ir a configuración de Wi-Fi")
 .padding()
 .background(Color.blue)
 .foregroundColor(.white)
 .cornerRadius(8)
 }
 .padding(.top, 16)
 }

 Spacer()
 }
 .padding()
 }
 .alert("Error de subida", isPresented: Binding<Bool>(
 get: { uploadError != nil },
 set: { if !$0 { uploadError = nil } }
 )) {
 Button("Aceptar", role: .cancel) { uploadError = nil }
 } message: {
 Text(uploadError ?? "")
 }
 .alert("Subida completa", isPresented: $showSuccessDialog) {
 Button("Cerrar", role: .cancel) { showSuccessDialog = false }
 } message: {
 Text("Todos los archivos han sido subidos correctamente.")
 }
 }
 }

 // 📌 **Componente para cada archivo en la lista**
 struct UploadDocumentRow: View {
 let document: Document
 @ObservedObject var uploadDocumentsViewModel: UploadDocumentsViewModel
 var onUploadError: (String) -> Void
 var onUploadSuccess: () -> Void

 @State private var progress: Double = 0.0
 @State private var isUploading: Bool = false

 var body: some View {
 HStack {
 VStack(alignment: .leading) {
 Text(document.type)
 .font(.headline)
 Text("Versión: \(document.version)")
 .font(.subheadline)
 .foregroundColor(.gray)
 }

 Spacer()

 if isUploading {
 ProgressView(value: progress, total: 100)
 .progressViewStyle(CircularProgressViewStyle())
 } else {
 Button("Subir") {
 isUploading = true
 uploadDocumentsViewModel.uploadDocument(document) { result in
 isUploading = false
 switch result {
 case .success:
 onUploadSuccess()
 case .failure(let error):
 onUploadError(error.localizedDescription)
 }
 }
 }
 .padding()
 .background(Color.green)
 .foregroundColor(.white)
 .cornerRadius(8)
 }
 }
 .padding()
 }
 }
 */
