import SwiftUI

struct ContentView: View {
    @State private var selectedFolder: URL?
    
    var body: some View {
        VStack {
            if let selectedFolder = selectedFolder {
                Text("Selected Folder: \(selectedFolder.path)")
                    .padding()
            } else {
                Text("Drag and drop a folder here or select one using the button")
                    .font(.title)
                    .foregroundColor(.gray)
                    .padding()
            }
            
            DropView(selectedFolder: $selectedFolder)
                .frame(minWidth: 200, minHeight: 200)
                .border(Color.gray, width: 2)
                .cornerRadius(10)
                .padding()
            
            Button("Select Folder") {
                let openPanel = NSOpenPanel()
                openPanel.allowsMultipleSelection = false
                openPanel.canChooseDirectories = true
                openPanel.canChooseFiles = false
                
                if openPanel.runModal() == .OK {
                    selectedFolder = openPanel.url
                }
            }
            .padding()
        }
        .padding()
    }
}

struct DropView: NSViewRepresentable {
    @Binding var selectedFolder: URL?
    
    func makeNSView(context: Context) -> NSView {
        let view = NSView()
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
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, NSDraggingDestination {
        let parent: DropView
        
        init(_ parent: DropView) {
            self.parent = parent
        }
        
        func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
            guard let item = sender.draggingPasteboard.pasteboardItems?.first else { return false }
            guard let fileURL = item.string(forType: .fileURL).flatMap(URL.init(string:)) else { return false }
            
            parent.selectedFolder = fileURL
            
            return true
        }
        
        func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
            return .copy
        }
        
        func draggingUpdated(_ sender: NSDraggingInfo) -> NSDragOperation {
            return .copy
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
