import SwiftUI

struct ToggleOptionView: View {
    let title: String
    let description: String
    @Binding var isOn: Bool
    let onToggle: (Bool) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                if !title.isEmpty {
                    Text(title)
                        .font(.body)
                        .bold()
                }
                Spacer()
                Toggle("", isOn: Binding(
                    get: { isOn },
                    set: { newValue in
                        onToggle(newValue)
                    }
                ))
                .labelsHidden()
            }

            if !description.isEmpty {
                Text(description)
                    .font(.footnote)
                    .foregroundColor(.gray)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
}
