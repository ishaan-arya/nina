import SwiftUI

struct ExtractedContentView: View {
    @Binding var isShowing: Bool
  @State private var isSearchBarExpanded: Bool = false
  @State private var searchText: String = ""
    // Define the data for the grid
    let gridItems = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    let boxes = [
        "How do I use SwiftUI to...",
        "What's the best practice for...",
        "I have a bug in SwiftData, can you...",
        "Can you explain this Xcode feature..."
    ]

    var body: some View {
        ZStack {
            Color.white.opacity(0.95).edgesIgnoringSafeArea(.all)

            VStack {
                Text("✨ NINA ✨")
                    .font(.system(size: 36, weight: .bold, design: .default))
                    .foregroundColor(.blue)
                    .padding(.top, 100)

                AnimatedSearchBar(isExpanded: $isSearchBarExpanded, searchText: $searchText)
                                 .padding(.horizontal, 20)
                                 .padding(.top, 30)

                LazyVGrid(columns: gridItems, spacing: 20) {
                    ForEach(boxes, id: \.self) { box in
                        Button(action: {
                            withAnimation(.spring()) {
                                self.searchText = box
                                self.isSearchBarExpanded = true
                            }
                        }) {
                            Text(box)
                                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 50)
                                .background(LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.5), Color.blue.opacity(0.3)]), startPoint: .top, endPoint: .bottom))
                                .cornerRadius(10)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .padding(.horizontal, 16)
                    }
                }
                .padding(.top, 20)


                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }.overlay(
            Button(action: {
                self.isShowing = false
            }) {
                Image(systemName: "arrow.left")
                    .foregroundColor(.blue)
                    .shadow(color: .blue, radius: 2, x: 0, y: 0)

            }
            .padding([.top, .leading], 16), alignment: .topLeading
            
        )
    }
}



struct ExtractedContentView_Previews: PreviewProvider {
    static var previews: some View {
        ExtractedContentView(isShowing: .constant(true))
    }
}
