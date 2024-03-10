import Foundation
import AppKit
import PDFKit
import OpenAI

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
    func extractKeywordsFromText(text: String, completion: @escaping ([String]?) -> Void) {
        let openAI = OpenAI(apiToken: "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")
        let query = ChatQuery(model: .gpt3_5Turbo, messages: [.init(role: .system, content: "Extract at most 10 keywords from this text and return as a comma separated list. Here is an example: User: I love math homework, and I especially love calculus. Assistant: Math, Homework, Calculus."), .init(role: .user, content: " Here is the text: \(text)")], functions: nil, temperature: nil, topP: nil, n: nil, stop: nil, maxTokens: nil, presencePenalty: nil, frequencyPenalty: nil, logitBias: nil, user: nil)
        openAI.chats(query: query) { result in
            switch result {
            case .success(let completionResult):
                let keywords = completionResult.choices.first?.message.content!.split(separator: ",").map(String.init)
                completion(keywords)
            case .failure(let error):
                print("Failed to extract keywords: \(error.localizedDescription)")
                completion(nil)
            }
        }
    }
    func createDictionary(folderURL: URL, completion: @escaping ([String: [String]]) -> Void) {
            var resultDictionary: [String: [String]] = [:]
            
            extractTextFromFolder(folderURL) { textContents in
                let group = DispatchGroup()
                
                for textContent in textContents {
                    group.enter()
                    
                    self.extractKeywordsFromText(text: textContent) { keywords in
                        if let keywords = keywords {
                            resultDictionary[textContent] = keywords
                        }
                        group.leave()
                    }
                }
                
                group.notify(queue: .main) {
                    completion(resultDictionary)
                }
            }
        }

}
