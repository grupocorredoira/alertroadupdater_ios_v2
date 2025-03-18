import SwiftUI

struct ConnectionScreen: View {
    @ObservedObject var connectionViewModel: ConnectionViewModel
    @ObservedObject var documentsViewModel: DocumentsViewModel
    @ObservedObject var networkStatusViewModel: NetworkStatusViewModel
    //@ObservedObject var permissionsViewModel: PermissionsViewModel

    @State private var isDetecting = false
    @State private var detectionError: String? = nil
    @State private var triggerDetection = false

    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                TopAppBarComponent(title: "Conectar al dispositivo", onBackClick: {})

                ScrollView {
                    VStack(spacing: 16) {
                        // Paso 1: Ayuda para encender el Wi-Fi del dispositivo
                        StepTitleComponent(text: "Paso 1: Asegúrate de que el dispositivo está encendido.")
                        HelpButton()

                        // Paso 2: Activar Wi-Fi en el teléfono
                        StepTitleComponent(text: "Paso 2: Activa el Wi-Fi en tu iPhone.")
                        EnableWifiButton(isWifiEnabled: networkStatusViewModel.isWifiEnabled)

                        // Paso 3: Detectar el dispositivo
                        StepTitleComponent(text: "Paso 3: Detectar el dispositivo.")
/*
                        DetectDeviceButton(
                            isWifiEnabled: networkStatusViewModel.isWifiEnabled,
                            matchedSSID: connectionViewModel.matchedSSID,
                            //allPermissionsGranted: permissionsViewModel.locationGranted,
                            /*onRequestPermissions: {
                                triggerDetection = true
                                permissionsViewModel.requestLocationPermission()
                            },*/
                            onStartDetection: {
                                isDetecting = true
                                connectionViewModel.detectCompatibleDevices()
                            }
                        )
 */

                        // Dispositivo detectado
                        if let matchedSSID = connectionViewModel.matchedSSID {
                            if let deviceName = documentsViewModel.getDeviceNameForSSID(matchedSSID) {
                                DeviceInfoCard(deviceName: deviceName, ssid: matchedSSID)
                            } else {
                                ErrorSnackbarComponent(message: "No se pudo obtener el nombre del dispositivo.")
                            }
                        }
                    }
                    .padding()
                }

                // Botón "Siguiente"
                if connectionViewModel.matchedSSID != nil {
                    NextButton(
                        matchedSSID: connectionViewModel.matchedSSID,
                        documentsViewModel: documentsViewModel
                    )
                }
            }
            /*.overlay {
                if isDetecting {
                    DetectionDialog(
                        onTimeout: {
                            let availableSSIDs = connectionViewModel.getAvailableSSIDs() // ✅ Método llamado correctamente
                            detectionError = availableSSIDs.isEmpty ? "No se encontraron redes disponibles." : "No se detectó el dispositivo."
                            isDetecting = false
                        },
                        onDismiss: { isDetecting = false }
                    )
                }
            }*/
        }
        /*.onAppear {
            permissionsViewModel.checkPermissions()
            connectionViewModel.resetDetectionState()
        }
        .onChange(of: permissionsViewModel.locationGranted) { newValue in
            if newValue && triggerDetection {
                isDetecting = true
                connectionViewModel.detectCompatibleDevices()
                triggerDetection = false
            }
        }*/
    }
}

struct HelpButton: View {
    var body: some View {
        Button(action: {
            if let url = URL(string: "https://help.url") {
                UIApplication.shared.open(url)
            }
        }) {
            Text("Abrir ayuda")
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
        }
    }
}

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
