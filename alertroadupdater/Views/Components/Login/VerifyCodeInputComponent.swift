import SwiftUI

// NO BORRAR
/// clase para un futuro por si hay que reenviar el código, de momento en ios no es necesario


/*
struct VerifyCodeInputComponent: View {
    var onCodeComplete: (String) -> Void = { _ in }
    let numDigits = 6 // Número de dígitos del código

    @State private var codeDigits: [String] = Array(repeating: "", count: 6)
    @FocusState private var focusedIndex: Int?

    var body: some View {
        VStack(spacing: 16) {
            // Cajas para ingresar el código
            HStack(spacing: 8) {
                ForEach(0..<numDigits, id: \.self) { index in
                    TextField("", text: Binding(
                        get: { codeDigits[index] },
                        set: { newValue in
                            if newValue.count <= 1 && newValue.allSatisfy(\.isNumber) {
                                codeDigits[index] = newValue

                                if !newValue.isEmpty, index < numDigits - 1 {
                                    focusedIndex = index + 1 // Mover foco a la siguiente caja
                                }

                                let fullCode = codeDigits.joined()
                                if fullCode.count == numDigits {
                                    onCodeComplete(fullCode)
                                }
                            }
                        }
                    ))
                    .keyboardType(.numberPad)
                    .frame(width: 48, height: 56)
                    .multilineTextAlignment(.center)
                    .textFieldStyle(.roundedBorder)
                    .focused($focusedIndex, equals: index)
                }
            }

            // Botón para limpiar
            Text("Limpiar código")
                .foregroundColor(.blue)
                .onTapGesture {
                    codeDigits = Array(repeating: "", count: numDigits)
                    focusedIndex = 0
                }
        }
        .onAppear {
            focusedIndex = 0 // Poner foco en la primera caja al cargar
        }
    }
}
*/
