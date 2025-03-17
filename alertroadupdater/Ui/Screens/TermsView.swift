import SwiftUI

struct TermsView: View {
    var onAccept: () -> Void

    var body: some View {
        NavigationStack {
            VStack {
                // Barra superior con logo
                TopAppBarComponentWithLogo(showMenu: false)

                Text("Términos y Condiciones")
                    .font(.title)
                    .bold()
                    .multilineTextAlignment(.center)
                    .padding(.top, 16)

                ScrollView {
                    Text("""
                    Aquí va el contenido de los términos y condiciones. Puedes cargarlo desde un archivo o una cadena larga.
                    """)
                    .font(.body)
                    .padding()
                }

                Button(action: onAccept) {
                    Text("Aceptar")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()
            }
            .padding()
        }
    }
}
