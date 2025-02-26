//
//  TrivaService.swift
//  TriviaTwist
//
//  Created by Ben Zhou on 2025-02-25.
//

import Foundation

class TriviaService {
    let baseURL = "https://opentdb.com/api.php"
    
    func fetchTrivia(amount: Int = 10) async throws -> [TriviaQuestion] {
        guard let url = URL(string: "\(baseURL)?amount=\(amount)&encode=base64") else {
            throw URLError(.badURL)
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        let triviaResponse = try JSONDecoder().decode(TriviaResponse.self, from: data)

        return triviaResponse.results.map { question in
            let decodedCategory = decodeBase64(question.category)
            let decodedType = decodeBase64(question.type)
            let decodedDifficulty = decodeBase64(question.difficulty)
            let decodedQuestion = decodeBase64(question.question)
            let decodedCorrectAnswer = decodeBase64(question.correctAnswer)
            let decodedIncorrectAnswers = question.incorrectAnswers.map { decodeBase64($0) }
            
            return TriviaQuestion(
                category: decodedCategory,
                type: decodedType,
                difficulty: decodedDifficulty,
                question: decodedQuestion,
                correctAnswer: decodedCorrectAnswer,
                incorrectAnswers: decodedIncorrectAnswers
            )
        }
    }
    
    private func decodeBase64(_ string: String) -> String {
        guard let data = Data(base64Encoded: string),
              let decodedString = String(data: data, encoding: .utf8) else {
            return string
        }
        return decodedString
    }
}
