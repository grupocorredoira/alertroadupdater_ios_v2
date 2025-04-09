import SwiftUI

struct TopAppBarComponentWithLogoAndMenu: View {
    var showMenu: Bool = true
    var onMenuClick: () -> Void = {}

    var body: some View {
        HStack {
            // 🟩 Espacio invisible para compensar el botón de la derecha
            if showMenu {
                Color.clear
                    .frame(width: 44, height: 44)
            }

            Spacer()

            Image("logo_cabecera")
                .resizable()
                .scaledToFit()
                .frame(width: 250, height: 50) // Ajusta esto al tamaño de tu banner
                //.clipped()

            Spacer()

            if showMenu {
                Button(action: {
                    print("✅ Botón de menú pulsado")
                    onMenuClick()
                }) {
                    Image(systemName: "line.horizontal.3")
                        .foregroundColor(.white)
                        .font(.title2)
                        .padding(8)
                        .background(Color.black.opacity(0.2))
                        .clipShape(Circle())
                }//.zIndex(1)
                .frame(width: 44, height: 44)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color.black)
    }
}
