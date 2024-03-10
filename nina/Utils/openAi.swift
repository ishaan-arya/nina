//
//  openAi.swift
//  nina
//
//  Created by Alex Farmer on 3/9/24.
//

import Foundation
import OpenAI

let apiToken = "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"

// Assuming OpenAI is a correctly defined module and 'chats' is an async function within that module
func openAiChat() async -> String {
    let openAI = OpenAI(apiToken: apiToken)
    let query = ChatQuery(model: .gpt3_5Turbo, messages: [.init(role: .user, content: "who are you")], functions: nil, temperature: nil, topP: nil, n: nil, stop: nil, maxTokens: nil, presencePenalty: nil, frequencyPenalty: nil, logitBias: nil, user: nil)
    
    do {
        let result = try await openAI.chats(query: query)
        // Assuming 'result' is processed correctly to extract and return a string message
        return result.choices.first?.message.content ?? "nil" // Placeholder for actual result processing
    } catch {
        print("An error occurred: \(error)")
        return "An error occurred: \(error.localizedDescription)"
    }
}

func getUserKeywords(userPrompt: String) async -> String {
    let openAI = OpenAI(apiToken: apiToken)
    let query = ChatQuery(model: .gpt3_5Turbo, messages: [.init(role: .system, content: "Extract at most 10 keywords from the user prompt and return as a comma separated list. Here is an example: User: I want my calculus homework files from fall semester. Assistant: Math, Homework, Calculus, Fall, School, HW"), .init(role: .user, content: userPrompt)], functions: nil, temperature: nil, topP: nil, n: nil, stop: nil, maxTokens: nil, presencePenalty: nil, frequencyPenalty: nil, logitBias: nil, user: nil)
    
    do {
        let result = try await openAI.chats(query: query)
        // Assuming 'result' is processed correctly to extract and return a string message
        return result.choices.first?.message.content ?? "nil" // Placeholder for actual result processing
    } catch {
        print("An error occurred: \(error)")
        return "An error occurred: \(error.localizedDescription)"
    }
}

func getUserAction(userPrompt: String) async -> String {
    print("getUserAction")
    let openAI = OpenAI(apiToken: apiToken)
    let query = ChatQuery(model: .gpt3_5Turbo, messages: [.init(role: .system, content: "Identify and list the actions needed to fulfill the user's request regarding file management, focusing only on the essential details required for crafting a Bash script. Present the actions in a numbered list, outlining the specific Bash script commands needed. Example: User: \"I want to move my calculus homework files into a new folder called homework.\" Assistant: \"Actions required: 1. Create a new folder named 'homework'. 2. Move calculus homework files into the 'homework' folder.\""
), .init(role: .user, content: userPrompt)], functions: nil, temperature: nil, topP: nil, n: nil, stop: nil, maxTokens: nil, presencePenalty: nil, frequencyPenalty: nil, logitBias: nil, user: nil)
    
    do {
        let result = try await openAI.chats(query: query)
        // Assuming 'result' is processed correctly to extract and return a string message
        return result.choices.first?.message.content ?? "nil" // Placeholder for actual result processing
    } catch {
        print("An error occurred: \(error)")
        return "An error occurred: \(error.localizedDescription)"
    }
}

func getFilesToModify(userKeywords: String, fileKeywords: String) async -> String {
    print("getFilesToModify")
    let openAI = OpenAI(apiToken: apiToken)
    let query = ChatQuery(model: .gpt3_5Turbo, messages: [.init(role: .system, content: "Given a list of files and user-specified keywords, identify and return a list of the absolute paths of the files that best match the provided keywords. Prioritize the similarity between file contents and the keywords in determining the match."
), .init(role: .user, content: "User Keywords:\(userKeywords)\n File Infomation: \(fileKeywords)")], functions: nil, temperature: nil, topP: nil, n: nil, stop: nil, maxTokens: nil, presencePenalty: nil, frequencyPenalty: nil, logitBias: nil, user: nil)
    
    do {
        let result = try await openAI.chats(query: query)
        // Assuming 'result' is processed correctly to extract and return a string message
        return result.choices.first?.message.content ?? "nil" // Placeholder for actual result processing
    } catch {
        print("An error occurred: \(error)")
        return "An error occurred: \(error.localizedDescription)"
    }
}
func generateDirectoryTree(from path: String, level: Int = 0) -> String {
    print("generateDirectoryTree")
    do {
        var directoryTree = ""
        let fileManager = FileManager.default
        let files = try fileManager.contentsOfDirectory(atPath: path)

        for file in files {
            let currentPath = "\(path)/\(file)"
            let fileAttributes = try fileManager.attributesOfItem(atPath: currentPath)

            if let fileType = fileAttributes[.type] as? FileAttributeType {
                if fileType == .typeDirectory {
                    directoryTree += "\(String(repeating: " ", count: level * 4))\(file)/\n"
                    directoryTree += generateDirectoryTree(from: currentPath, level: level + 1)
                } else {
                    directoryTree += "\(String(repeating: " ", count: level * 4))\(file)\n"
                }
            }
        }
        return directoryTree
    } catch {
        print("Error generating directory tree: \(error)")
        return ""
    }
}


func generateScript(userActions: String, files: String, path: String) async -> String {
    let openAI = OpenAI(apiToken: apiToken)
    let tree = generateDirectoryTree(from: path)
    let prompt = "Actions: \(userActions) \n Absolute Paths: \(files) \n Tree: \(tree)"
    print("PROMPT: \(prompt)")
    let query = ChatQuery(model: .gpt4_0125_preview, messages: [.init(role: .system, content: "Given specific actions to perform, the absolute paths of the associated files, and the folder directory tree, craft a Bash script for MacOS that efficiently executes these actions. Output only the Bash script without additional commentary. If you create a file or a directory, give it read and write permission with chmod 777. Always use sudo wherever you can."), .init(role: .user, content: "Actions: \(userActions) \n Absolute Paths: \(files) \n Tree: \(tree)")], functions: nil, temperature: nil, topP: nil, n: nil, stop: nil, maxTokens: nil, presencePenalty: nil, frequencyPenalty: nil, logitBias: nil, user: nil)
    
    do {
        let result = try await openAI.chats(query: query)
        // Assuming 'result' is processed correctly to extract and return a string message
        print(result.choices.first?.message.content ?? "nil")
        return result.choices.first?.message.content ?? "nil" // Placeholder for actual result processing
    } catch {
        print("An error occurred: \(error)")
        return "An error occurred: \(error.localizedDescription)"
    }
}
