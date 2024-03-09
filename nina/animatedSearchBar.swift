import SwiftUI

struct AnimatedSearchBar: View {
    @State private var isExpanded: Bool = false
    @State private var searchText: String = ""

    var body: some View {
        ZStack {
            
        
        
            // The animated search bar itself
            HStack {
                // This part will be hidden initially and will only show after the animation
                if isExpanded {
                    TextField("Search...", text: $searchText)
                                .foregroundColor(.gray) // Text color
                               
                               .textFieldStyle(PlainTextFieldStyle()) // Removes any default styling
                               .padding(8)
                               .frame(height: 40) // Set the height to match the search bar
                               .background(RoundedRectangle(cornerRadius: 10).fill(Color.white))
                               .transition(.opacity) //
                }
                
                Spacer()
                
                // Magnifying glass button
                Button(action: {
                    withAnimation(.spring()) {
                        self.isExpanded.toggle()
                    }
                }) {
                    Image(systemName: isExpanded ? "xmark" : "magnifyingglass")
                        .foregroundColor(Color.blue)
                        .padding(10)
                }
                .background(Color.white)
                .cornerRadius(isExpanded ? 10 : 20)
            }
            .frame(maxWidth: isExpanded ? 300 : 50)
            .padding(isExpanded ? 10 : 0)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.white, lineWidth: isExpanded ? 1 : 0)
            )
            .shadow(color: Color.blue.opacity(0.5), radius: 10, x: 0, y: 0)
            .padding()
        }
    }
}

struct AnimatedSearchBar_Previews: PreviewProvider {
    static var previews: some View {
        AnimatedSearchBar()
    }
}
