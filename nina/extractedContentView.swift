import SwiftUI

struct ExtractedContentView: View {
    @Binding var isShowing: Bool
    @State private var isSearchBarExpanded: Bool = false
    @State private var searchText: String = ""
    @State private var isNinaTextVisible: Bool = false
    @State private var isExpanded = false
    @State private var showProgressScreen = false
    @Binding var selectedFolder: URL?
    
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
                    .scaleEffect(isNinaTextVisible ? 1 : 0.5)
                    .opacity(isNinaTextVisible ? 1 : 0)
                    .onAppear {
                        withAnimation(.easeOut(duration: 1.5)) {
                            self.isNinaTextVisible = true
                        }
                    }
                AnimatedSearchBar(
                    isExpanded: $isSearchBarExpanded,
                    searchText: $searchText,
                    onCommit: {
                        //print("COMMITTING")
                        Task {
                            await processSearchText()
                        }
                    }
                )
                
                .sheet(isPresented: $showProgressScreen) {
                    ProgressScreen(showProgressScreen: $showProgressScreen)
                }
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
                                .background(LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.blue.opacity(0.3)]), startPoint: .top, endPoint: .bottom))
                                .cornerRadius(10)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .padding(.horizontal, 20)
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
        .sheet(isPresented: $showProgressScreen) {
            ProgressScreen(showProgressScreen: $showProgressScreen)
        }
    }
    private func processSearchText() async {
        let userPrompt = searchText
        print("User prompt: \(userPrompt)")

        let userKeywords = await getUserKeywords(userPrompt: userPrompt)
        print("User keywords: \(userKeywords)")

        let userAction = await getUserAction(userPrompt: userPrompt)
        print("User action: \(userAction)")

        if let selectedFolder = selectedFolder {
            selectedFolder.startAccessingSecurityScopedResource()
            print("Selected folder: \(selectedFolder.path)")

            let extractor = Extract()
            extractor.createDictionary(folderURL: selectedFolder) { keywordsByFilePath in
                Task {
                    var scriptPaths: [String] = []

                    for (filePath, keywords) in keywordsByFilePath {
                        print("File: \(filePath)")
                        let fileKeywords = "File: \(filePath) Keywords: \(keywords.joined(separator: ", "))"

                        let filesToModify = await getFilesToModify(userKeywords: userKeywords, fileKeywords: fileKeywords)
                        let script = await generateScript(userActions: userAction, files: filesToModify, path: selectedFolder.path)
                        print("Generated script: \(script)")

                        if let scriptPath = createShellScript(with: script, at: selectedFolder.path) {
                            scriptPaths.append(scriptPath)
                        }
                    }

                    // Execute the generated scripts
                    for scriptPath in scriptPaths {
                        print("Executing script at: \(scriptPath)")
                        executeShellScript(at: scriptPath)
                    }

                    selectedFolder.stopAccessingSecurityScopedResource()
                }
            }
        } else {
            print("No selected folder")
        }
    }
}

struct ExtractedContentView_Previews: PreviewProvider {
    static var previews: some View {
        ExtractedContentView(
            isShowing: .constant(true),
            selectedFolder: .constant(URL(fileURLWithPath: "/path/to/sample/folder"))
        )
    }
}
