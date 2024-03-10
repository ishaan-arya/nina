import SwiftUI


struct ExtractedContentView: View {
     @State private var keywordsByFilePath: [String: [String]] = [:]

    private func createDictionary() {
        if let selectedFolder = selectedFolder {
            selectedFolder.startAccessingSecurityScopedResource()
            print("Selected folder: \(selectedFolder.path)")

            let extractor = Extract()
            extractor.createDictionary(folderURL: selectedFolder) { keywordsByFilePath in
                self.keywordsByFilePath = keywordsByFilePath
            }

            selectedFolder.stopAccessingSecurityScopedResource()
        } else {
            print("No selected folder")
        }
    }
    @Binding var isShowing: Bool
    @State private var isSearchBarExpanded: Bool = false
    @State private var searchText: String = ""
    @State private var isNinaTextVisible: Bool = false
    @State private var isExpanded = false
     @State private var isLoading = false
    @State private var showProgressScreen = false
    @Binding var selectedFolder: URL?
    @State private var hovered: String? = nil  // Keep track of which button is being hovered

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
        "Create a new file called...",
        "Move files related to...",
        "Copy the contents of..."
    ]

    var body: some View {
        ZStack {
            Color.white.opacity(0.95).edgesIgnoringSafeArea(.all)
            VStack {
                Text("NINA")
                    .font(.system(size: 75, weight: .bold, design: .rounded))
                    .foregroundColor(.blue)
                    .offset(y: textOffset)  // Use the offset for the animation
                    .animation(.easeOut(duration: 1.0), value: textOffset)
                    .onAppear {
                        textOffset = 62

                        createDictionary()
                    }
                    .padding(.top, 5)
                    .zIndex(1)

                Spacer()
            }

            // Drawer for the search bar and buttons
            VStack(spacing: 20) {
                 AnimatedSearchBar(isExpanded: $isSearchBarExpanded, searchText: $searchText, onCommit: {
                    isLoading = true // Start loading and show the progress screen
                    showProgressScreen = true
                    Task {
                        await processSearchText()
                        // After the search process is done, update the UI on the main thread
                        DispatchQueue.main.async {
                            isLoading = false // Set loading to false to trigger the sparkle screen
                        }
                    }
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
            .offset(y: 200)
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
                }
                .shadow(color: shadowColor, radius: 30, x: 0, y: -20)
                .padding([.top, .leading], 20), // This will position the button to the top left
                alignment: .topLeading // Changed from .top to .topLeading

            )
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white.opacity(0.95).edgesIgnoringSafeArea(.all))
       .sheet(isPresented: $showProgressScreen) {
    if let path = selectedFolder?.path {
        let folderURL = "file://\(path)"
        ProgressScreen(showProgressScreen: $showProgressScreen, isLoading: $isLoading, folderPath: folderURL)
    } else {
        ProgressScreen(showProgressScreen: $showProgressScreen, isLoading: $isLoading, folderPath: "")
    }
}
    }

private func processSearchText() async {
    let userPrompt = searchText
    print("User prompt: \(userPrompt)")

    let userKeywords = await getUserKeywords(userPrompt: userPrompt)
    print("User keywords: \(userKeywords)")

    let userAction = await getUserAction(userPrompt: userPrompt)
    print("User action: \(userAction)")

    // Update the keywordsByFilePath dictionary with new files
    updateDictionary()

    var completeDictString = ""
    for (filePath, keywords) in keywordsByFilePath {
        print("File: \(filePath)")
        print("Keywords: \(keywords)")
        let fileKeywords = "File: \(filePath) Keywords: \(keywords.joined(separator: ", "))"
        completeDictString += fileKeywords
    }

    let script = await generateScript(userActions: userPrompt, files: completeDictString, path: selectedFolder?.path ?? "")
    createShellScript(with: script, at: selectedFolder!.path)
    executeShellScript(at: selectedFolder!.path + "/script.sh")
    deleteFile(at: selectedFolder!.path + "/script.sh")
}

private func updateDictionary() {
    guard let selectedFolder = selectedFolder else {
        print("No selected folder")
        return
    }

    selectedFolder.startAccessingSecurityScopedResource()
    print("Selected folder: \(selectedFolder.path)")

    let extractor = Extract()
    let fileManager = FileManager.default

    func processDirectory(_ directoryURL: URL) {
        let enumerator = fileManager.enumerator(at: directoryURL, includingPropertiesForKeys: nil)
        while let fileURL = enumerator?.nextObject() as? URL {
            if fileURL.isFileURL {
                let filePath = fileURL.path
                if !keywordsByFilePath.keys.contains(filePath) {
                    extractor.extractKeywordsFromText(text: fileURL.path) { keywords in
                        if let keywords = keywords {
                            keywordsByFilePath[filePath] = keywords
                        }
                    }
                }
            }
        }
    }

    processDirectory(selectedFolder)

    selectedFolder.stopAccessingSecurityScopedResource()
}
}


// Implement AnimatedSearchBar and other subviews as necessary

struct ExtractedContentView_Previews: PreviewProvider {
    static var previews: some View {
        ExtractedContentView(
            isShowing: .constant(true),
            selectedFolder: .constant(URL(fileURLWithPath: "/path/to/sample/folder"))
        )
    }
}
