import SwiftUI

struct ContentView: View {
    @State private var selectedFolder: URL?
    @State private var isShowingExtractedContent = false

    var body: some View {
        ZStack {
            Color.white.opacity(0.95).edgesIgnoringSafeArea(.all)

            if isShowingExtractedContent {
                ExtractedContentView(isShowing: $isShowingExtractedContent)
            } else {
                VStack {
                    Spacer()
                    if let selectedFolder = selectedFolder {
                        Text("Selected Folder: \(selectedFolder.path)")
                            .foregroundColor(.black)
                            .padding()
                    } else {
                        Text("Drag and drop a folder here or select one using the button")
                            .font(.title)
                            .foregroundColor(.black)
                            .padding()
                    }
                    
                    DropView(selectedFolder: $selectedFolder)
                        .frame(width: 200, height: 150)
                          .background(Color.white)
                          .cornerRadius(10)
                          .shadow(color: .blue, radius: 2, x: 0, y: 0)
                          .overlay(
                              RoundedRectangle(cornerRadius: 10)
                                  .stroke(Color.blue, lineWidth: 2)
                          )
                          .padding()
                    
                    Button("📁 Select Folder") {
                        let openPanel = NSOpenPanel()
                        openPanel.allowsMultipleSelection = false
                        openPanel.canChooseDirectories = true
                        openPanel.canChooseFiles = false

                        if openPanel.runModal() == .OK {
                            selectedFolder = openPanel.url
                        }
                    }
                    .padding()
                    .buttonStyle(PlainButtonStyle())
                    .foregroundColor(.black)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.blue, lineWidth: 2)
                    )
                    .padding()

                    Button("Extract Text") {
                        if let _ = selectedFolder {
                            // Assume extraction is done here, and we want to show the result
                            isShowingExtractedContent = true
                        }
                    }
                    .padding()
                    .buttonStyle(PlainButtonStyle())
                    .foregroundColor(.white) // Text color of the button
                    .background(Color.gray) // Background color of the button
                    .cornerRadius(10) // Rounded corners of the button
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray, lineWidth: 2) // Blue border for the button
                    )
                    .padding()


                    Spacer()
                }
            }
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
        
        let uploadIcon = NSImageView(image: NSImage(systemSymbolName: "arrow.up.doc", accessibilityDescription: "Upload") ?? NSImage())
        uploadIcon.contentTintColor = .gray // Set the color of the upload icon
        uploadIcon.translatesAutoresizingMaskIntoConstraints = false
        nsView.addSubview(uploadIcon)

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
