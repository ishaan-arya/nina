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
    let openAI = OpenAI(apiToken: "TOKEN")
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
