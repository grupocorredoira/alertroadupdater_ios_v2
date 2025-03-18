import SwiftUI

struct SettingsView: View {
    @State private var showDialogSafeDisconnect = false
    @State private var showPrivacyPolicyDialog = false
    @State private var showTermsDialog = false

    let versionName = "1.0.0" // Sustituye por el método adecuado para obtener la versión en iOS
    let versionCode = "100" // Sustituye por el método adecuado para obtener el código de versión

    var body: some View {
        NavigationView {
            VStack {
                // Barra superior
                TopAppBarComponent(title: "Ajustes", onBackClick: {})

                List {
                    Section(header: Text("Preferencias de usuario").font(.headline)) {
                        SettingsOption(title: "Política de Privacidad") {
                            showPrivacyPolicyDialog = true
                        }
                        SettingsOption(title: "Términos y Condiciones") {
                            showTermsDialog = true
                        }
                        SettingsOption(title: "Eliminar archivos locales") {
                            deleteLocalFiles()
                        }
                        SettingsOption(title: "Cerrar sesión") {
                            showDialogSafeDisconnect = true
                        }
                    }
                }

                Text("Versión: \(versionName) (\(versionCode))")
                    .font(.footnote)
                    .padding()
            }
            .overlay {
                if showDialogSafeDisconnect {
                    disconnectDialog()
                }
            }
            /*
            .sheet(isPresented: $showPrivacyPolicyDialog) {
                DialogReadTextComponent(
                    title: "Política de Privacidad",
                    text: "Aquí va el contenido de la política de privacidad.",
                    onDismiss: { showPrivacyPolicyDialog = false }
                )
            }
            .sheet(isPresented: $showTermsDialog) {
                DialogReadTextComponent(
                    title: "Términos y Condiciones",
                    text: "Aquí van los términos y condiciones.",
                    onDismiss: { showTermsDialog = false }
                )
            }
             */
        }
    }

    func deleteLocalFiles() {
        print("Archivos locales eliminados") // Sustituye con la lógica real
    }

    @ViewBuilder
    private func disconnectDialog() -> some View {
        VStack {
            Text("¿Seguro que quieres cerrar sesión?")
                .font(.headline)
                .padding()

            HStack {
                Button("Cancelar") {
                    showDialogSafeDisconnect = false
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.gray.opacity(0.3))
                .cornerRadius(10)

                Button("Sí, cerrar sesión") {
                    signOut()
                    showDialogSafeDisconnect = false
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.red)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .padding()
        }
        .frame(maxWidth: 300)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 5)
    }

    func signOut() {
        print("Sesión cerrada") // Sustituye con la lógica real
    }
}

struct SettingsOption: View {
    var title: String
    var onClick: () -> Void

    var body: some View {
        Button(action: onClick) {
            HStack {
                Text(title)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
        }
    }
}
