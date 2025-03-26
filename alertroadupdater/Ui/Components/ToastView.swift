import SwiftUI

struct ToastView: View {
    var message: String
    var icon: String? = nil

    var body: some View {
        HStack(spacing: 10) {
            if let icon = icon {
                Image(systemName: icon)
                    .foregroundColor(.white)
            }
            Text(message)
                .foregroundColor(.white)
                .font(.subheadline)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(Color.black.opacity(0.85))
        .cornerRadius(12)
        .shadow(radius: 5)
        .padding(.bottom, 40)
    }
}
