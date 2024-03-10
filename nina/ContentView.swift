import SwiftUI


struct ContentView: View {
    @State private var selectedFolder: URL?
    @State private var isShowingExtractedContent = false

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(gradient: Gradient(colors: [Color.white, Color.blue.opacity(0.2)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                .edgesIgnoringSafeArea(.all)

            if isShowingExtractedContent {
                ExtractedContentView(isShowing: $isShowingExtractedContent, selectedFolder: $selectedFolder)
            } else {
                VStack(spacing: 20) {
                    Spacer()

                    Text("Drag and drop a folder here or select one using the button")
                        .font(.title)
                        .fontWeight(.medium)
                        .foregroundColor(.black)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)

                    DropView(selectedFolder: $selectedFolder)
                        .frame(width: 250, height: 200)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [10]))
                                .foregroundColor(Color.gray.opacity(0.5))
                        )
                        .overlay(
                            FolderIcon()
                        )
                        .padding()

                    Button(action: {
                        selectFolder()
                    }) {
                        Label("Browse files", systemImage: "folder")
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.horizontal, 40)

                    Spacer()
                }
                .padding(.top, 20)
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

struct FolderIcon: View {
    var body: some View {
        Image(systemName: "folder.fill")
            .resizable()
            .scaledToFit()
            .frame(width: 64, height: 48)
            .foregroundColor(.blue)
            .padding(.bottom, 100)
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
