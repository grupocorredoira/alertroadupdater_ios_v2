import SwiftUI

struct TopAppBarComponent: View {
    var title: String
    var onBackClick: () -> Void

    var body: some View {
        VStack {
            HStack {
                Button(action: onBackClick) {
                    Image(systemName: "arrow.left")
                        .foregroundColor(.white)
                        .font(.title2)
                }
                Spacer()
                Text(title)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                Spacer()
                // Espacio para centrar el título
                Button(action: {}) {
                    Image(systemName: "arrow.left")
                        .opacity(0) // Invisible para alinear con el botón izquierdo
                }
            }
            .padding()
            .background(Color.black)

            Spacer().frame(height: 16) // Margen inferior
        }
    }
}
