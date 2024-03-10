//
//  openAi.swift
//  nina
//
//  Created by Alex Farmer on 3/9/24.
//

import Foundation
import OpenAI

// Assuming OpenAI is a correctly defined module and 'chats' is an async function within that module
func openAiChat() async -> String {
    let openAI = OpenAI(apiToken: "Token")
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
    let openAI = OpenAI(apiToken: "Token")
    let query = ChatQuery(model: .gpt3_5Turbo, messages: [.init(role: .system, content: "Extract at most 10 keywords from the user prompt and return as a comma separated list. Here is an example: User: I want my calculus homework files from fall semester. Assistant: Math, Homework, Calculus, Fall, School, HW."), .init(role: .user, content: userPrompt)], functions: nil, temperature: nil, topP: nil, n: nil, stop: nil, maxTokens: nil, presencePenalty: nil, frequencyPenalty: nil, logitBias: nil, user: nil)
    
    do {
        let result = try await openAI.chats(query: query)
        // Assuming 'result' is processed correctly to extract and return a string message
        return result.choices.first?.message.content ?? "nil" // Placeholder for actual result processing
    } catch {
        print("An error occurred: \(error)")
        return "An error occurred: \(error.localizedDescription)"
    }
}

func generateScript() async -> String {
    let fileTest = "/test/one, /test/two/"
    let openAI = OpenAI(apiToken: "Token")
    let query = ChatQuery(model: .gpt3_5Turbo, messages: [.init(role: .system, content: "Your task is to write a Bash script that processes a provided list of absolute file paths. The script should: 1. Create a new directory named 'homework' at the specified location: /test/path. 2. Move each file from the given list into this newly created 'homework' directory. \n Ensure your script is efficient and handles any necessary checks (e.g., verifying the directory doesn't already exist). Please provide the complete script that fulfills these requirements."), .init(role: .user, content: fileTest)], functions: nil, temperature: nil, topP: nil, n: nil, stop: nil, maxTokens: nil, presencePenalty: nil, frequencyPenalty: nil, logitBias: nil, user: nil)
    
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
