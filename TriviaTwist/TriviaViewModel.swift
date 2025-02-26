//
//  TriviaViewModel.swift
//  TriviaTwist
//
//  Created by Ben Zhou on 2025-02-25.
//

import Foundation
import SwiftUI

class TriviaViewModel: ObservableObject {
    @Published var questions: [TriviaQuestion] = []
    @Published var currentQuestionIndex = 0
    @Published var score = 0
    @Published var selectedAnswer: String?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var gameOver = false
    
    private let triviaService = TriviaService()
    
    var currentQuestion: TriviaQuestion? {
        guard questions.indices.contains(currentQuestionIndex) else {
            return nil
        }
        return questions[currentQuestionIndex]
    }
    
    func loadQuestions(amount: Int = 10) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let newQuestions = try await triviaService.fetchTrivia(amount: amount)
            await MainActor.run {
                self.questions = newQuestions
                self.currentQuestionIndex = 0
                self.score = 0
                self.selectedAnswer = nil
                self.gameOver = false
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = "Failed to load questions: \(error.localizedDescription)"
                self.isLoading = false
            }
        }
    }
    
    func checkAnswer(answer: String) {
        guard let currentQuestion = currentQuestion else { return }
        
        selectedAnswer = answer
        
        if answer == currentQuestion.correctAnswer {
            score += 1
        }
    }
    
    func nextQuestion() {
        if currentQuestionIndex < questions.count - 1 {
            currentQuestionIndex += 1
            selectedAnswer = nil
        } else {
            gameOver = true
        }
    }
    
    func restartGame() async {
        await loadQuestions()
    }
}
