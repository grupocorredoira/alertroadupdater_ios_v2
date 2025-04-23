import SwiftUI

struct TermsView: View {
    @EnvironmentObject var coordinator: NavigationCoordinator
    @ObservedObject var prefs: PreferencesManager

    var body: some View {
        VStack(spacing: 16) {
            TopAppBarComponentWithLogo()

            Spacer()

            Text("Términos y condiciones")
                .font(.title)
                .bold()
                .padding(.top)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Aquí van tus términos y condiciones completos...")

                    Button("Aceptar") {
                        prefs.saveTermsAccepted(true)
                        coordinator.navigate(to: .privacyPolicy)
                    }
                    .buttonStyle(.borderedProminent)
                    .padding(.top, 20)
                }
                .padding()
            }
        }
    }
}

struct TermsDialogView: View {
    var onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Text("Términos y Condiciones")
                .font(.headline)
                .padding(.top)

            ScrollView {
                Text("""
                Aquí van los términos y condiciones completos de uso de la aplicación...
                """)
                    .font(.body)
                    .padding()
            }

            Button("Cerrar") {
                onDismiss()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .frame(maxWidth: 350, maxHeight: 500)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 10)
    }
}
