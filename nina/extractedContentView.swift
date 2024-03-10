import SwiftUI

struct ExtractedContentView: View {
    @Binding var isShowing: Bool
    @State private var isSearchBarExpanded: Bool = false
    @State private var searchText: String = ""
    @State private var hovered: String? = nil  // Keep track of which button is being hovered
    
    @State private var showProgressScreen = false
    @State private var textOffset: CGFloat = 600  // Start from below the visible area
    
    let drawerBackground = Color.white
    let shadowColor = Color.gray.opacity(0.5)

    // Define the data for the grid
    let gridItems = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    let boxes = [
        "Make a folder and put...",
        "What's the best practice for...",
        "I have a bug in SwiftData, can you...",
        "Can you explain this Xcode feature..."
    ]

    var body: some View {
        ZStack(alignment: .top) {
            VStack {
                Text("NINA")
                    .font(.system(size: 75, weight: .bold, design: .rounded))
                    .foregroundColor(.blue)
                    .offset(y: textOffset)  // Use the offset for the animation
                    .animation(.easeOut(duration: 2.0), value: textOffset)
                    .onAppear {
                        textOffset = 62  // Adjust this value to the final position offset
                    }
                    .zIndex(1)

                Spacer()
            }

            // Drawer for the search bar and buttons
            VStack(spacing: 20) {
                AnimatedSearchBar(isExpanded: $isSearchBarExpanded, searchText: $searchText,  onCommit: {
                        print(searchText) //TODO: call the right function
                        showProgressScreen = true
                    })
                    .padding()

                LazyVGrid(columns: gridItems, spacing: 15) {
                    ForEach(boxes, id: \.self) { box in
                        Button(action: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                searchText = box
                                isSearchBarExpanded = true
                            }
                        }) {
                            Text(box)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.blue.opacity(0.3)]), startPoint: .leading, endPoint: .trailing))
                                .cornerRadius(10)
                                .shadow(color: hovered == box ? .clear : shadowColor, radius: hovered == box ? 0 : 5, x: 0, y: hovered == box ? 0 : 5)
                                .scaleEffect(hovered == box ? 0.95 : 1)
                                .animation(.spring(), value: hovered)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .padding(.horizontal, 20)
                        .onHover { isHovering in
                            hovered = isHovering ? box : nil
                        }
                    }
                }

                Spacer()
            }
            .padding(.vertical, 20)
            .background(drawerBackground)
            .cornerRadius(30)
            .shadow(color: shadowColor, radius: 30, x: 0, y: -20)
            .offset(y: 150)
            .animation(.interactiveSpring(response: 0.6, dampingFraction: 0.8, blendDuration: 0.8), value: isSearchBarExpanded)
            
            .overlay(
                Button(action: {
                    isShowing = false
                }) {
                    Image(systemName: "arrow.left")
                         .foregroundColor(.blue)
                        .padding()
                        .clipShape(Rectangle())
                      .cornerRadius(10)
                   .shadow(color: shadowColor, radius: 30, x: 0, y: -20)

                }
                .padding([.top, .leading], 20), // This will position the button to the top left
                alignment: .topLeading // Changed from .top to .topLeading
            )
         }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white.opacity(0.95).edgesIgnoringSafeArea(.all))
        .sheet(isPresented: $showProgressScreen) {
            // Present the ProgressScreen as a sheet when showProgressScreen is true
            ProgressScreen(showProgressScreen: $showProgressScreen)
        }
    }
}

// Implement AnimatedSearchBar and other subviews as necessary

struct ExtractedContentView_Previews: PreviewProvider {
    static var previews: some View {
        ExtractedContentView(isShowing: .constant(true))
    }
}
