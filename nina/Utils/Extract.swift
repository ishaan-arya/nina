import Foundation
import AppKit
import PDFKit
import NaturalLanguage


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
    func extractKeywords(from fileURL: URL) -> Set<String> {
        let text = try! String(contentsOf: fileURL, encoding: .utf8)
        let tagger = NLTagger(tagSchemes: [.lexicalClass])
        tagger.string = text

        var keywords: Set<String> = []
        var currentWord = ""

        tagger.enumerateTags(in: text.startIndex..<text.endIndex, unit: .word, scheme: .lexicalClass, options: []) { tag, tokenRange in
            if let tag = tag, (tag.rawValue == "Noun" && tag.rawValue != "Determiner") || tag.rawValue == "Adjective" || tag.rawValue == "ProperNoun" {
                currentWord = String(text[tokenRange]).lowercased()
                keywords.insert(currentWord)
            }
            return true
        }

        return keywords
    }

    func jaccardSimilarity(setA: Set<String>, setB: Set<String>) -> Double {
        let intersection = setA.intersection(setB)
        let union = setA.union(setB)
        return Double(intersection.count) / Double(union.count)
    }

    func determineFileSimilarity(fileURLA: URL, fileURLB: URL) -> Double {
        let keywordsA = extractKeywords(from: fileURLA)
        let keywordsB = extractKeywords(from: fileURLB)
        return jaccardSimilarity(setA: keywordsA, setB: keywordsB)
    }
}
