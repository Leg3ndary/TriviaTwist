//
//  Views.swift
//  TriviaTwist
//
//  Created by Ben Zhou on 2025-02-25.
//

import SwiftUI

// Main Content View
struct ContentView: View {
    @StateObject private var viewModel = TriviaViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                if viewModel.isLoading {
                    ProgressView("Loading Questions...")
                        .padding()
                } else if let errorMessage = viewModel.errorMessage {
                    ErrorView(errorMessage: errorMessage) {
                        Task {
                            await viewModel.loadQuestions()
                        }
                    }
                } else if viewModel.gameOver {
                    GameOverView(score: viewModel.score, totalQuestions: viewModel.questions.count) {
                        Task {
                            await viewModel.restartGame()
                        }
                    }
                } else if let question = viewModel.currentQuestion {
                    QuestionView(
                        question: question,
                        selectedAnswer: viewModel.selectedAnswer,
                        onAnswerSelected: { answer in
                            viewModel.checkAnswer(answer: answer)
                        },
                        onNext: {
                            viewModel.nextQuestion()
                        }
                    )
                } else {
                    WelcomeView {
                        Task {
                            await viewModel.loadQuestions()
                        }
                    }
                }
            }
            .navigationTitle("Trivia Challenge")
            .padding()
        }
    }
}

struct WelcomeView: View {
    let onStartGame: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Welcome to Trivia Challenge!")
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            
            Text("Test your knowledge with random trivia questions!")
                .font(.title2)
                .multilineTextAlignment(.center)
            
            Spacer()
            
            Button("Start Game") {
                onStartGame()
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            
            Spacer()
        }
        .padding()
    }
}

// Question View
struct QuestionView: View {
    let question: TriviaQuestion
    let selectedAnswer: String?
    let onAnswerSelected: (String) -> Void
    let onNext: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            // Question Counter
            HStack {
                Text("Category: \(question.category)")
                    .font(.headline)
                Spacer()
                Text("Difficulty: \(question.difficulty.capitalized)")
                    .font(.subheadline)
            }
            
            // Question
            Text(question.question)
                .font(.title2)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
                .padding()
            
            Spacer()
            
            // Answers
            VStack(spacing: 12) {
                ForEach(question.allAnswers, id: \.self) { answer in
                    AnswerButton(
                        answer: answer,
                        isSelected: selectedAnswer == answer,
                        isCorrect: selectedAnswer != nil ? answer == question.correctAnswer : nil,
                        isEnabled: selectedAnswer == nil,
                        action: {
                            onAnswerSelected(answer)
                        }
                    )
                }
            }
            
            Spacer()
            
            // Next button
            if selectedAnswer != nil {
                Button("Next Question") {
                    onNext()
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .padding()
            }
        }
        .padding()
    }
}

// Answer Button
struct AnswerButton: View {
    let answer: String
    let isSelected: Bool
    let isCorrect: Bool?
    let isEnabled: Bool
    let action: () -> Void
    
    var backgroundColor: Color {
        if let isCorrect = isCorrect {
            return isCorrect ? .green : (isSelected ? .red : .secondary)
        } else {
            return isSelected ? .blue : .secondary
        }
    }
    
    var body: some View {
        Button {
            action()
        } label: {
            Text(answer)
                .fontWeight(.medium)
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(backgroundColor)
                .cornerRadius(10)
        }
        .disabled(!isEnabled)
    }
}

// Game Over View
struct GameOverView: View {
    let score: Int
    let totalQuestions: Int
    let onPlayAgain: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Game Over!")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Your Score")
                .font(.title2)
            
            Text("\(score) / \(totalQuestions)")
                .font(.system(size: 70, weight: .bold))
                .foregroundColor(scoreColor)
            
            Text(resultMessage)
                .font(.title3)
                .multilineTextAlignment(.center)
                .padding()
            
            Spacer()
            
            Button("Play Again") {
                onPlayAgain()
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            
            Spacer()
        }
        .padding()
    }
    
    var percentage: Double {
        Double(score) / Double(totalQuestions) * 100
    }
    
    var scoreColor: Color {
        if percentage >= 80 {
            return .green
        } else if percentage >= 50 {
            return .yellow
        } else {
            return .red
        }
    }
    
    var resultMessage: String {
        if percentage >= 80 {
            return "Excellent! You're a trivia master!"
        } else if percentage >= 50 {
            return "Good job! You know your stuff!"
        } else if percentage >= 30 {
            return "Nice try! Keep learning!"
        } else {
            return "Better luck next time!"
        }
    }
}

// Error View
struct ErrorView: View {
    let errorMessage: String
    let onRetry: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 70))
                .foregroundColor(.yellow)
            
            Text("Oops!")
                .font(.title)
                .fontWeight(.bold)
            
            Text(errorMessage)
                .font(.body)
                .multilineTextAlignment(.center)
                .padding()
            
            Button("Try Again") {
                onRetry()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

// Preview Provider
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
