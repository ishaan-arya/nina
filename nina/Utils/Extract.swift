import Foundation
import AppKit
import PDFKit

class Extract {
    func extractTextFromFolder(_ folderURL: URL, completion: @escaping ([String]) -> Void) {
        var textContent: [String] = []
        
        let enumerator = FileManager.default.enumerator(at: folderURL, includingPropertiesForKeys: nil)
        
        while let fileURL = enumerator?.nextObject() as? URL {
            if fileURL.isFileURL {
                let fileExtension = fileURL.pathExtension.lowercased()
                
                switch fileExtension {
                case "txt":
                    if let fileContent = try? String(contentsOf: fileURL, encoding: .utf8) {
                        textContent.append(fileContent)
                    }
                case "rtf":
                    if let attributedString = try? NSAttributedString(url: fileURL, options: [:], documentAttributes: nil) {
                        let plainText = attributedString.string
                        textContent.append(plainText)
                    }
                case "pdf":
                    if let pdf = PDFDocument(url: fileURL) {
                        let plainText = (0..<pdf.pageCount).compactMap { pdf.page(at: $0)?.string }.joined(separator: "\n")
                        textContent.append(plainText)
                    }
                default:
                    break
                }
            }
        }
        
        completion(textContent)
    }
}
