import SwiftUI

struct CountryCodeDropdownMenu: View {
    var selectedPrefix: String
    var onPrefixSelected: (String) -> Void

    @State private var isExpanded = false

    var body: some View {
        Menu {
            ForEach(CountryUtils.countryOptions, id: \.code) { country in
                Button(action: { onPrefixSelected(country.code) }) {
                    Text(country.name)
                }
            }
        } label: {
            HStack {
                Text(CountryUtils.countryOptions.first { $0.code == selectedPrefix }?.name ?? "Seleccionar")
                Spacer()
                Image(systemName: "chevron.down")
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.gray.opacity(0.2))
            .cornerRadius(10)
        }
    }
}
