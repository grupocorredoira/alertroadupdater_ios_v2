import SwiftUI

struct SmsResendSection: View {
    var onClickHere: () -> Void
    var initialTime: Int = 180 // Tiempo inicial en segundos (3 minutos)

    @State private var remainingTime: Int

    init(onClickHere: @escaping () -> Void, initialTime: Int = 180) {
        self.onClickHere = onClickHere
        self.initialTime = initialTime
        self._remainingTime = State(initialValue: initialTime)
    }

    var body: some View {
        VStack(alignment: .center) {
            Text(
                remainingTime > 0 ?
                "Por favor, espera \(remainingTime / 60) min \(remainingTime % 60) seg para reenviar el SMS." :
                "Si no recibiste el SMS, puedes reenviarlo ahora."
            )
            .font(.body)

            if remainingTime > 0 {
                Text("Espera...")
                    .foregroundColor(.gray)
            } else {
                Text("Haz clic aquí")
                    .foregroundColor(.blue)
                    .onTapGesture {
                        onClickHere()
                    }
            }
        }
        .onAppear {
            startCountdown()
        }
    }

    private func startCountdown() {
        if remainingTime > 0 {
            Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
                if self.remainingTime > 0 {
                    self.remainingTime -= 1
                } else {
                    timer.invalidate()
                }
            }
        }
    }
}
