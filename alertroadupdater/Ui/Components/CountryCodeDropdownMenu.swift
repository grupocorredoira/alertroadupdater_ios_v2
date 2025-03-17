import SwiftUI

struct CountryCodeDropdownMenu: View {
    var selectedPrefix: String
    var onPrefixSelected: (String) -> Void

    @State private var isExpanded = false

    let countryOptions: [(String, String)] = [
        ("España", "+34"),
        ("México", "+52"),
        ("Argentina", "+54")
    ] // Agrega más opciones según necesites.

    var body: some View {
        Menu {
            ForEach(countryOptions, id: \.1) { country in
                Button(action: { onPrefixSelected(country.1) }) {
                    Text("\(country.0) (\(country.1))")
                }
            }
        } label: {
            HStack {
                Text(countryOptions.first { $0.1 == selectedPrefix }?.0 ?? "Seleccionar")
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
