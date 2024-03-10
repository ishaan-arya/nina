import SwiftUI

struct ContentView: View {
    @State private var selectedFolder: URL?
    @State private var isShowingExtractedContent = false
    var body: some View {
        ZStack {
            Color.white.opacity(0.95).edgesIgnoringSafeArea(.all)
            if isShowingExtractedContent {
                ExtractedContentView(isShowing: $isShowingExtractedContent, selectedFolder: $selectedFolder)
            } else {
                VStack {
                    Spacer()

                    Text("Drag and drop a folder here or select one using the button")
                        .font(.title)
                        .foregroundColor(.black)
                        .padding(.horizontal)

                    DropView(selectedFolder: $selectedFolder)
                        .frame(width: 200, height: 150)
                        .border(Color.gray, width: 2)
                        .cornerRadius(10)
                        .padding()

                    Button(action: {
                        selectFolder()
                    }) {
                        HStack {
                            Image(systemName: "folder")
                            Text("Select Folder")
                        }
                        .frame(width: 200, height: 50)
                        .background(Color.gray)
                        .foregroundColor(.black)
                        .cornerRadius(10)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding()

                    Spacer()
                }
            }
        }
    }
    
    private func selectFolder() {
        let openPanel = NSOpenPanel()
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = true
        openPanel.canChooseFiles = false
        
        if openPanel.runModal() == .OK {
            isShowingExtractedContent = true
            selectedFolder = openPanel.url
        }
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
        
        let dropIndicator = NSImageView(image: NSImage(named: NSImage.folderName)!)
        dropIndicator.frame = NSRect(x: (nsView.bounds.width - dropIndicator.bounds.width) / 2,
                                     y: (nsView.bounds.height - dropIndicator.bounds.height) / 2,
                                     width: dropIndicator.bounds.width,
                                     height: dropIndicator.bounds.height)
        nsView.addSubview(dropIndicator)
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
