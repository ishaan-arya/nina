import SwiftUI

struct AnimatedSearchBar: View {
    @Binding var isExpanded: Bool
      @Binding var searchText: String
    var onCommit: () -> Void = {}

    var body: some View {
        ZStack {
            HStack {
                if isExpanded {
                    TextField("Search...", text: $searchText)
                                           .foregroundColor(.gray)
                                           .textFieldStyle(PlainTextFieldStyle())
                                           .padding(8)
                                           .frame(height: 40)
                                           .background(RoundedRectangle(cornerRadius: 10).fill(Color.white))
                                           .transition(.opacity)
                                           .onSubmit {
                                               onCommit() // Invoke the onCommit closure when the user presses Enter
                                           }
                }

                Spacer()
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
        AnimatedSearchBar(isExpanded: .constant(false), searchText: .constant(""))
    }
}
