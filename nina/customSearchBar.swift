import SwiftUI

// MARK: - Extension for Hex Colors
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt64()
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(.sRGB, red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255, opacity: Double(a) / 255)
    }
}

// MARK: - CustomSearchBar View
struct CustomSearchBar: View {
    // Add your @State or @Binding properties as needed for your search logic
    @State private var searchText: String = ""

    var body: some View {
        ZStack {
            Color.black.opacity(0.95).edgesIgnoringSafeArea(.all)
            
            // Place the search bar at the top
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    searchBar
                    Spacer()
                }
                .padding(.top, 20)
                Spacer()
                Text("Hello, world!")
                    .foregroundColor(.white)
                Spacer()
            }
        }
    }

    var searchBar: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white)
                .shadow(color: Color(hex: "#1A73E8").opacity(0.5), radius: 10, x: 0, y: 0)
                .frame(width: 350, height: 50)

            HStack {
                TextField("Search...", text: $searchText)
                    .padding(.leading, 20)

                Spacer()

                Button(action: {
                    // Perform search or any action here
                }) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(Color(hex: "#1A73E8"))
                }
                .padding(.trailing, 20)
            }
            .frame(width: 330, height: 50)
        }
    }
}

// MARK: - Preview
struct CustomSearchBar_Previews: PreviewProvider {
    static var previews: some View {
        CustomSearchBar()
            .preferredColorScheme(.dark)
    }
}

