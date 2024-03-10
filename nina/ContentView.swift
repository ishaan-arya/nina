import SwiftUI

struct ContentView: View {
    @State private var selectedFolder: URL?

    var body: some View {
        VStack {
            Text("Drag and drop a folder here or select one using the button")
                .font(.title)
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
                .padding()
            
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.gray, lineWidth: 2)
                .overlay(
                    DropView(selectedFolder: $selectedFolder)
                )
                .frame(height: 200)
                .padding()
            
            Button(action: {
                let openPanel = NSOpenPanel()
                openPanel.allowsMultipleSelection = false
                openPanel.canChooseDirectories = true
                openPanel.canChooseFiles = false
                
                if openPanel.runModal() == .OK {
                    selectedFolder = openPanel.url
                }
            }) {
                HStack {
                    Image(systemName: "folder")
                    Text("Select Folder")
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .buttonStyle(PlainButtonStyle())
            
            Button("Extract Text") {
                if let selectedFolder = selectedFolder {
                    let extractor = Extract()
                            
                    extractor.createDictionary(folderURL: selectedFolder) { keywordsByFilePath in
                        DispatchQueue.main.async {
                            for (filePath, keywords) in keywordsByFilePath {
                                print("File: \(filePath)")
                                print("Keywords: \(keywords.joined(separator: ", "))")
                            }
                        }
                    }
                }
            }
            .padding()
            .background(Color.green)
            .foregroundColor(.white)
            .cornerRadius(10)
            .buttonStyle(PlainButtonStyle())
        }
        .padding()
    }
}


struct DropView: NSViewRepresentable {
    @Binding var selectedFolder: URL?
    
    func makeNSView(context: Context) -> NSView {
        let view = DroppableView(selectedFolder: $selectedFolder)
        view.registerForDraggedTypes([.fileURL])
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.clear.cgColor
        return view
    }
    
    func updateNSView(_ nsView: NSView, context: Context) {
        nsView.subviews.forEach { $0.removeFromSuperview() }
    }
}

class DroppableView: NSView {
    @Binding var selectedFolder: URL?
    
    init(selectedFolder: Binding<URL?>) {
        _selectedFolder = selectedFolder
        super.init(frame: .zero)
        registerForDraggedTypes([.fileURL])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        return .copy
    }
    
    override func draggingUpdated(_ sender: NSDraggingInfo) -> NSDragOperation {
        return .copy
    }
    
    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        guard let item = sender.draggingPasteboard.pasteboardItems?.first else { return false }
        guard let fileURL = item.string(forType: .fileURL).flatMap(URL.init(string:)) else { return false }
        
        selectedFolder = fileURL
        
        return true
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
