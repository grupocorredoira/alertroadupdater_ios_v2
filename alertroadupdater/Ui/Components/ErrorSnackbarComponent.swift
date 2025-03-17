import SwiftUI

struct ErrorSnackbarComponent: View {
    var message: String
    var actionLabel: String = "Aceptar"
    var onAction: (() -> Void)? = nil
    var onDismiss: (() -> Void)? = nil

    @State private var isSnackbarVisible = true

    var body: some View {
        if isSnackbarVisible {
            VStack {
                Text(message)
                    .foregroundColor(.red)
                    .bold()
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(10)

                Button(action: {
                    onAction?()
                    onDismiss?()
                    isSnackbarVisible = false
                }) {
                    Text(actionLabel)
                        .foregroundColor(.blue)
                        .bold()
                }
                .padding()
            }
            .padding()
            .background(Color.white)
            .cornerRadius(10)
            .shadow(radius: 5)
        }
    }
}
