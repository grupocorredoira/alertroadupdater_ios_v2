import SwiftUI

struct ConnectionView: View {
    @StateObject private var viewModel = ConnectionViewModel()
    @State private var isDetecting = false
    @State private var detectionError: String? = nil
    @State private var showPermissionSheet = false

    var body: some View {
        NavigationStack {
            VStack {
                // Barra superior
                TopAppBarComponent(title: "Conectar dispositivo", onBackClick: {
                    // Acción de volver atrás
                })

                ScrollView {
                    VStack(spacing: 16) {
                        // Paso 1: Ayuda para encender el Wi-Fi del dispositivo
                        StepTitleComponent(text: "Paso 1: Enciende el Wi-Fi del dispositivo")
                        HelpButton()

                        // Paso 2: Encender el Wi-Fi del teléfono
                        StepTitleComponent(text: "Paso 2: Asegúrate de que el Wi-Fi está activado")
                        EnableWifiButton(isWifiEnabled: viewModel.isWifiEnabled)

                        // Paso 3: Detectar dispositivo
                        StepTitleComponent(text: "Paso 3: Detectar dispositivo")
                        DetectDeviceButton(
                            isWifiEnabled: viewModel.isWifiEnabled,
                            matchedSSID: viewModel.matchedSSID,
                            allPermissionsGranted: viewModel.permissionsGranted,
                            onRequestPermissions: {
                                showPermissionSheet = true
                            },
                            onStartDetection: {
                                isDetecting = true
                                viewModel.detectCompatibleDevices()
                            }
                        )

                        // Mostrar mensaje de error si no hay conexión
                        if !viewModel.hasInternet {
                            Text("No hay conexión a Internet")
                                .foregroundColor(.red)
                                .padding()
                        }

                        // Mostrar tarjeta con dispositivo detectado
                        if let matchedSSID = viewModel.matchedSSID, let deviceName = viewModel.deviceName {
                            DeviceInfoCard(deviceName: deviceName, ssid: matchedSSID)
                        }
                    }
                    .padding()
                }

                // Botón para continuar
                if viewModel.matchedSSID != nil {
                    NextButton(
                        matchedSSID: viewModel.matchedSSID!,
                        deviceName: viewModel.deviceName!
                    )
                }
            }
            /*.overlay(
                // Mostrar cuadro de detección mientras se escanean dispositivos
                isDetecting ? DetectionDialog(onTimeout: {
                    detectionError = "No se encontró ningún dispositivo."
                    isDetecting = false
                }) : nil
            )
            .sheet(isPresented: $showPermissionSheet) {
                PermissionBottomSheet(
                    onDismiss: { showPermissionSheet = false },
                    onGrantPermission: { viewModel.requestPermissions() }
                )
            }*/
        }
    }
}

struct HelpButton: View {
    var body: some View {
        Button(action: {
            if let url = URL(string: "https://link.help.switch.on.wifi") {
                UIApplication.shared.open(url)
            }
        }) {
            Text("Ver ayuda")
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
        }
    }
}

struct EnableWifiButton: View {
    var isWifiEnabled: Bool

    var body: some View {
        Button(action: {
            print("Abriendo configuración de Wi-Fi...")
        }) {
            Text(isWifiEnabled ? "Wi-Fi activado" : "Activar Wi-Fi")
                .padding()
                .frame(maxWidth: .infinity)
                .background(isWifiEnabled ? Color.green : Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
        }
    }
}


struct DetectDeviceButton: View {
    var isWifiEnabled: Bool
    var matchedSSID: String?
    var allPermissionsGranted: Bool
    var onRequestPermissions: () -> Void
    var onStartDetection: () -> Void

    var body: some View {
        Button(action: {
            if allPermissionsGranted {
                onStartDetection()
            } else {
                onRequestPermissions()
            }
        }) {
            Text(matchedSSID == nil ? "Detectar dispositivo" : "Dispositivo encontrado")
                .padding()
                .frame(maxWidth: .infinity)
                .background(isWifiEnabled ? Color.blue : Color.gray)
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
            Text("Wi-Fi: \(ssid)")
                .font(.subheadline)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 2)
    }
}

struct NextButton: View {
    var matchedSSID: String
    var deviceName: String

    var body: some View {
        NavigationLink(destination: UploadView(deviceName: deviceName)) {
            Text("Siguiente")
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(10)
        }
        .padding(.top, 16)
    }
}
