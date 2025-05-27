import SwiftUI

struct TopAppBarViewWithLogo: View {

    var body: some View {
        HStack {
            Color.clear
                .frame(width: 44, height: 44)
            Spacer()



            Image("logo_cabecera")
                .resizable()
                .scaledToFit()
                .frame(width: 250, height: 50)
            
            Spacer()
            Color.clear
                .frame(width: 44, height: 44)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color.black)
    }
}
