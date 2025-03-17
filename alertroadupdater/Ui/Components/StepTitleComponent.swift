import SwiftUI

struct StepTitleComponent: View {
    var text: String

    var body: some View {
        Text(text)
            .font(.system(size: 20, weight: .bold))
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 8)
    }
}
