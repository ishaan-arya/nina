import Foundation
import AppKit
import PDFKit
import OpenAI

class Extract {
    func extractTextFromFolder(_ folderURL: URL, completion: @escaping ([String], [String]) -> Void) {
        var textContent: [String] = []
        var filePaths: [String] = []

        let enumerator = FileManager.default.enumerator(at: folderURL, includingPropertiesForKeys: nil)

        while let fileURL = enumerator?.nextObject() as? URL {
            if fileURL.isFileURL {
                let fileExtension = fileURL.pathExtension.lowercased()

                switch fileExtension {
                case "txt":
                    if let fileContent = try? String(contentsOf: fileURL, encoding: .utf8) {
                        textContent.append(fileContent)
                        filePaths.append(fileURL.path)
                    }
                case "rtf":
                    if let attributedString = try? NSAttributedString(url: fileURL, options: [:], documentAttributes: nil) {
                        let plainText = attributedString.string
                        textContent.append(plainText)
                        filePaths.append(fileURL.path)
                    }
                case "pdf":
                    if let pdf = PDFDocument(url: fileURL) {
                        let plainText = (0..<pdf.pageCount).compactMap { pdf.page(at: $0)?.string }.joined(separator: "\n")
                        textContent.append(plainText)
                        filePaths.append(fileURL.path)
                    }
                default:
                    break
                }
            }
        }

        completion(textContent, filePaths)
    }

    func extractKeywordsFromText(text: String, completion: @escaping ([String]?) -> Void) {
        let openAI = OpenAI(apiToken: "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")
        let query = ChatQuery(model: .gpt3_5Turbo, messages: [.init(role: .system, content: "Extract at most 10 keywords from this text and return as a comma separated list. Here is an example: User: I love math homework, and I especially love calculus. Assistant: Math, Homework, Calculus"), .init(role: .user, content: " Here is the text: \(text)")], functions: nil, temperature: nil, topP: nil, n: nil, stop: nil, maxTokens: nil, presencePenalty: nil, frequencyPenalty: nil, logitBias: nil, user: nil)
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
        print("in createDictionary")
        
        extractTextFromFolder(folderURL) { textContents, filePaths in
            var resultDictionary: [String: [String]] = [:]
            let group = DispatchGroup()
            
            for (textContent, filePath) in zip(textContents, filePaths) {
                group.enter()
                self.extractKeywordsFromText(text: textContent) { keywords in
                    if let keywords = keywords {
                        resultDictionary[filePath] = keywords
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
