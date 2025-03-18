import SwiftUI

struct ButtonStateComponent: View {
    var text: String
    var enabled: Bool = true
    var onClick: () -> Void

    var body: some View {
        Button(action: onClick) {
            Text(text)
                .frame(maxWidth: .infinity)
                .padding()
                .background(enabled ? Color.blue : Color.gray)
                .foregroundColor(.white)
                .cornerRadius(10)
        }
        .disabled(!enabled)
    }
}
